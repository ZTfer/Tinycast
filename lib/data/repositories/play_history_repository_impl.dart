import 'package:isar_community/isar.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/mappers/play_history_mapper.dart';
import 'package:tinycast/data/models/play_history_model.dart';
import 'package:tinycast/data/models/episode_model.dart';
import 'package:tinycast/domain/entities/play_history.dart' as entity;
import 'package:tinycast/domain/repositories/play_history_repository.dart';

/// PlayHistoryRepository 的 Isar 实现
class PlayHistoryRepositoryImpl implements PlayHistoryRepository {
  final IsarService _isarService;

  PlayHistoryRepositoryImpl({IsarService? isarService})
    : _isarService = isarService ?? IsarService.instance;

  PlayHistory? _findHistoryByEpisode(Isar isar, int episodeId, String? episodeGuid, String? episodeITunesId) {
    if (episodeITunesId != null && episodeITunesId.isNotEmpty) {
      final byItunesId = isar.playHistorys
          .filter()
          .episodeITunesIdEqualTo(episodeITunesId)
          .and()
          .isDeletedEqualTo(false)
          .findFirstSync();
      if (byItunesId != null) return byItunesId;
    }

    if (episodeGuid != null && episodeGuid.isNotEmpty) {
      final byGuid = isar.playHistorys
          .filter()
          .episodeGuidEqualTo(episodeGuid)
          .and()
          .isDeletedEqualTo(false)
          .findFirstSync();
      if (byGuid != null) return byGuid;
    }

    return isar.playHistorys
        .filter()
        .episodeIdEqualTo(episodeId)
        .and()
        .isDeletedEqualTo(false)
        .findFirstSync();
  }

  @override
  Future<List<entity.PlayHistory>> getCompletedHistories() async {
    final isar = _isarService.isar;
    final records = await isar.playHistorys
        .filter()
        .statusEqualTo(PlayHistoryStatus.completed)
        .and()
        .isDeletedEqualTo(false)
        .sortByLastUpdateTimeDesc()
        .findAll();
    return PlayHistoryMapper.toEntityList(records);
  }

  @override
  Future<entity.PlayHistory?> getLatestPlayingHistory() async {
    final isar = _isarService.isar;
    final record = await isar.playHistorys
        .filter()
        .group((q) => q
            .statusEqualTo(PlayHistoryStatus.playing)
            .or()
            .isPlayedEqualTo(false))
        .and()
        .isDeletedEqualTo(false)
        .sortByLastUpdateTimeDesc()
        .findFirst();
    return record == null ? null : PlayHistoryMapper.toEntity(record);
  }

  @override
  Future<entity.PlayHistory?> getByEpisodeId(int episodeId, {String? episodeGuid, String? episodeITunesId}) async {
    final isar = _isarService.isar;
    final record = _findHistoryByEpisode(isar, episodeId, episodeGuid, episodeITunesId);
    return record == null ? null : PlayHistoryMapper.toEntity(record);
  }

  @override
  Future<void> saveOrUpdate(entity.PlayHistory history) async {
    final isar = _isarService.isar;

    final model = PlayHistoryMapper.toModel(history);
    final existing = _findHistoryByEpisode(isar, history.episodeId, history.episodeGuid, history.episodeITunesId);

    if (existing != null) {
      model.id = existing.id;
    }

    await isar.writeTxn(() async {
      await isar.playHistorys.put(model);
    });
  }

  @override
  Future<void> updateProgress(int episodeId, int positionMs, int duration, {String? episodeGuid, String? episodeITunesId}) async {
    final isar = _isarService.isar;
    final history = _findHistoryByEpisode(isar, episodeId, episodeGuid, episodeITunesId);
    if (history != null) {
      history.lastPlayedPositionMs = positionMs;
      history.playedDuration += duration;
      history.lastUpdateTime = DateTime.now();
      await isar.writeTxn(() async {
        await isar.playHistorys.put(history);
      });
    }
  }

  /// 更新播放进度（同时更新 lastPlayedPositionMs 和 playProgress）
  /// PlayHistory 是播放状态的唯一数据源，Episode 中的对应字段为缓存。
  /// 两者在同一事务内写入，避免历史与缓存进度不一致。
  @override
  Future<void> updatePlayProgress(int episodeId, int positionMs, double progressRatio, {String? episodeGuid, String? episodeITunesId}) async {
    final isar = _isarService.isar;
    final now = DateTime.now();

    await isar.writeTxn(() async {
      final history = _findHistoryByEpisode(isar, episodeId, episodeGuid, episodeITunesId);
      if (history != null) {
        history.lastPlayedPositionMs = positionMs;
        history.playProgress = progressRatio;
        history.lastUpdateTime = now;
        await isar.playHistorys.put(history);
      }

      final episode = _findEpisodeByFallback(isar, episodeId, episodeGuid, episodeITunesId);
      if (episode != null) {
        episode.playProgress = progressRatio;
        episode.lastPlayedAt = now;
        episode.updatedAt = now;
        await isar.episodes.put(episode);
      }
    });
  }

  /// 获取 episode 的播放进度（playProgress）
  @override
  Future<double?> getPlayProgress(int episodeId, {String? episodeGuid, String? episodeITunesId}) async {
    final isar = _isarService.isar;
    final history = _findHistoryByEpisode(isar, episodeId, episodeGuid, episodeITunesId);
    return history?.playProgress;
  }

  /// 检查 episode 是否已播放（从 PlayHistory 判断，PlayHistory 是唯一数据源）
  @override
  Future<bool> isEpisodePlayed(int episodeId, {String? episodeGuid, String? episodeITunesId}) async {
    final isar = _isarService.isar;
    final history = _findHistoryByEpisode(isar, episodeId, episodeGuid, episodeITunesId);
    return history?.isPlayed ?? false;
  }

  /// 标记 episode 为已播放并设置 playProgress
  /// PlayHistory 是唯一数据源，Episode 缓存字段在同一事务内同步更新
  @override
  Future<void> markAsPlayedWithProgress(int episodeId, double progressRatio, {String? episodeGuid, String? episodeITunesId, String? podcastGuid, String? podcastITunesId}) async {
    await _updateOrCreateCompletedHistory(
      episodeId,
      episodeGuid: episodeGuid,
      episodeITunesId: episodeITunesId,
      podcastGuid: podcastGuid,
      podcastITunesId: podcastITunesId,
      progressRatio: progressRatio,
    );
  }

  /// 共享实现：更新或创建 completed 状态的 PlayHistory 记录
  /// [progressRatio] 非 null 时同时写入 playProgress
  Future<void> _updateOrCreateCompletedHistory(
    int episodeId, {
    String? episodeGuid,
    String? episodeITunesId,
    String? podcastGuid,
    String? podcastITunesId,
    double? progressRatio,
  }) async {
    final isar = _isarService.isar;

    await isar.writeTxn(() async {
      final now = DateTime.now();
      final existing = _findHistoryByEpisode(isar, episodeId, episodeGuid, episodeITunesId);

      if (existing != null) {
        existing.isPlayed = true;
        existing.status = PlayHistoryStatus.completed;
        if (progressRatio != null) {
          existing.playProgress = progressRatio;
        }
        existing.lastUpdateTime = now;
        await isar.playHistorys.put(existing);

        await _syncEpisodePlayedCache(
          isar,
          episodeId,
          episodeGuid,
          episodeITunesId,
          progressRatio ?? existing.playProgress,
          now,
        );

        Logger.info('[HISTORY] episodeId=$episodeId 已更新为 completed，playProgress=${existing.playProgress}');
        return;
      }

      final episode = _findEpisodeByFallback(isar, episodeId, episodeGuid, episodeITunesId);
      if (episode == null) {
        Logger.warning('[HISTORY] 未找到 episode: $episodeId，无法创建 PlayHistory 记录');
        return;
      }

      final newHistory = PlayHistory()
        ..episodeId = episodeId
        ..episodeGuid = episodeGuid
        ..episodeITunesId = episodeITunesId
        ..podcastId = episode.podcastId
        ..podcastGuid = podcastGuid
        ..podcastITunesId = podcastITunesId
        ..title = episode.title
        ..description = episode.description
        ..artworkUrl = episode.artworkUrl
        ..isPlayed = true
        ..playProgress = progressRatio ?? 0.0
        ..status = PlayHistoryStatus.completed
        ..playedDuration = 0
        ..lastUpdateTime = now
        ..isDeleted = false;

      await isar.playHistorys.put(newHistory);

      episode.isPlayed = true;
      if (progressRatio != null) {
        episode.playProgress = progressRatio;
      }
      episode.updatedAt = now;
      await isar.episodes.put(episode);

      Logger.info('[HISTORY] 已创建新的 completed 记录 episodeId=$episodeId');
    });
  }

  Future<void> _syncEpisodePlayedCache(
    Isar isar,
    int episodeId,
    String? episodeGuid,
    String? episodeITunesId,
    double progressRatio,
    DateTime now,
  ) async {
    final episode = _findEpisodeByFallback(
      isar,
      episodeId,
      episodeGuid,
      episodeITunesId,
    );
    if (episode == null) return;
    episode
      ..isPlayed = true
      ..playProgress = progressRatio
      ..updatedAt = now;
    await isar.episodes.put(episode);
  }

  /// 按 Fallback 优先级查找 Episode：guid > iTunesId > episodeId
  Episode? _findEpisodeByFallback(
    Isar isar,
    int episodeId,
    String? episodeGuid,
    String? episodeITunesId,
  ) {
    if (episodeGuid != null && episodeGuid.isNotEmpty) {
      final byGuid = isar.episodes.filter().guidEqualTo(episodeGuid).findFirstSync();
      if (byGuid != null) return byGuid;
    }
    if (episodeITunesId != null && episodeITunesId.isNotEmpty) {
      final byItunesId = isar.episodes.filter().itunesIdEqualTo(episodeITunesId).findFirstSync();
      if (byItunesId != null) return byItunesId;
    }
    return isar.episodes.getSync(episodeId);
  }

  /// 获取所有已播放的 episode ID 集合（用于交叉过滤未播放列表）
  @override
  Future<Set<int>> getPlayedEpisodeIds() async {
    final isar = _isarService.isar;
    final playedHistories = isar.playHistorys
        .filter()
        .isPlayedEqualTo(true)
        .and()
        .isDeletedEqualTo(false)
        .findAllSync();
    return playedHistories.map((h) => h.episodeId).toSet();
  }

  @override
  Future<void> markAsCompleted(int episodeId, {String? episodeGuid, String? episodeITunesId}) async {
    final isar = _isarService.isar;
    final history = _findHistoryByEpisode(isar, episodeId, episodeGuid, episodeITunesId);
    if (history != null) {
      history.isPlayed = true;
      history.status = PlayHistoryStatus.completed;
      history.lastUpdateTime = DateTime.now();
      await isar.writeTxn(() async {
        await isar.playHistorys.put(history);
      });
    }
  }

  @override
  Future<void> updateOrCreatePlayHistoryAsCompleted(int episodeId, {String? episodeGuid, String? episodeITunesId, String? podcastGuid, String? podcastITunesId}) async {
    await _updateOrCreateCompletedHistory(
      episodeId,
      episodeGuid: episodeGuid,
      episodeITunesId: episodeITunesId,
      podcastGuid: podcastGuid,
      podcastITunesId: podcastITunesId,
    );
  }

  @override
  Future<void> softDelete(int episodeId, {String? episodeGuid, String? episodeITunesId}) async {
    final isar = _isarService.isar;
    final histories = isar.playHistorys
        .where()
        .episodeIdEqualTo(episodeId)
        .findAllSync();

    await isar.writeTxn(() async {
      for (final history in histories) {
        history.isDeleted = true;
        await isar.playHistorys.put(history);
      }
    });
  }

  @override
  Future<void> removeByPodcastId(int podcastId, {String? podcastGuid, String? podcastITunesId}) async {
    Logger.info('[HISTORY] 开始清理 podcastId=$podcastId 的历史记录, podcastITunesId: $podcastITunesId');
    final isar = _isarService.isar;
    final List<PlayHistory> histories;
    if (podcastITunesId != null && podcastITunesId.isNotEmpty) {
      histories = await isar.playHistorys
          .filter()
          .podcastITunesIdEqualTo(podcastITunesId)
          .findAll();
    } else if (podcastGuid != null && podcastGuid.isNotEmpty) {
      histories = await isar.playHistorys
          .filter()
          .podcastGuidEqualTo(podcastGuid)
          .findAll();
    } else {
      histories = await isar.playHistorys
          .filter()
          .podcastIdEqualTo(podcastId)
          .findAll();
    }

    Logger.info('[HISTORY] 找到 ${histories.length} 条记录待清理');
    await isar.writeTxn(() async {
      await isar.playHistorys.deleteAll(histories.map((h) => h.id).toList());
    });
    Logger.info('[HISTORY] 已清理 ${histories.length} 条历史记录');
  }
}
