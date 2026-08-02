import 'package:isar_community/isar.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/models/play_history_model.dart';
import 'package:tinycast/data/models/episode_model.dart';
import 'package:flutter/foundation.dart';

class PlayHistoryRepository {
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

  Future<List<PlayHistory>> getCompletedHistories() async {
    final isar = IsarService.instance.isar;

    final allRecords = await isar.playHistorys.where().findAll();
    debugPrint('📊 [PlayHistory] 总记录数: ${allRecords.length}');
    for (final record in allRecords) {
      debugPrint('   - ID: ${record.id}, Status: ${record.status}, Title: ${record.title}, isDeleted: ${record.isDeleted}');
    }

    final completedRecords = allRecords
        .where((record) =>
            record.status == PlayHistoryStatus.completed &&
            record.isDeleted == false)
        .toList()
      ..sort((a, b) => b.lastUpdateTime.compareTo(a.lastUpdateTime));

    debugPrint('✅ [PlayHistory] Completed 记录数: ${completedRecords.length}');

    return completedRecords;
  }

  Future<PlayHistory?> getLatestPlayingHistory() async {
    final isar = IsarService.instance.isar;
    return isar.playHistorys
        .filter()
        .group((q) => q
            .statusEqualTo(PlayHistoryStatus.playing)
            .or()
            .isPlayedEqualTo(false))
        .and()
        .isDeletedEqualTo(false)
        .sortByLastUpdateTimeDesc()
        .findFirst();
  }

  Future<PlayHistory?> getByEpisodeId(int episodeId, {String? episodeGuid, String? episodeITunesId}) async {
    final isar = IsarService.instance.isar;
    return _findHistoryByEpisode(isar, episodeId, episodeGuid, episodeITunesId);
  }

  Future<void> saveOrUpdate(PlayHistory history) async {
    final isar = IsarService.instance.isar;
    
    final existing = _findHistoryByEpisode(isar, history.episodeId, history.episodeGuid, history.episodeITunesId);
    
    if (existing != null) {
      history.id = existing.id;
    }
    
    await isar.writeTxn(() async {
      await isar.playHistorys.put(history);
    });
  }

  Future<void> updateProgress(int episodeId, int positionMs, int duration, {String? episodeGuid, String? episodeITunesId}) async {
    final isar = IsarService.instance.isar;
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
  /// PlayHistory 是播放状态的唯一数据源，Episode 中的对应字段为缓存
  Future<void> updatePlayProgress(int episodeId, int positionMs, double progressRatio, {String? episodeGuid, String? episodeITunesId}) async {
    final isar = IsarService.instance.isar;
    final history = _findHistoryByEpisode(isar, episodeId, episodeGuid, episodeITunesId);
    if (history != null) {
      history.lastPlayedPositionMs = positionMs;
      history.playProgress = progressRatio;
      history.lastUpdateTime = DateTime.now();
      await isar.writeTxn(() async {
        await isar.playHistorys.put(history);
      });
    }
  }

  /// 获取 episode 的播放进度（playProgress）
  Future<double?> getPlayProgress(int episodeId, {String? episodeGuid, String? episodeITunesId}) async {
    final isar = IsarService.instance.isar;
    final history = _findHistoryByEpisode(isar, episodeId, episodeGuid, episodeITunesId);
    return history?.playProgress;
  }

  /// 检查 episode 是否已播放（从 PlayHistory 判断，PlayHistory 是唯一数据源）
  Future<bool> isEpisodePlayed(int episodeId, {String? episodeGuid, String? episodeITunesId}) async {
    final isar = IsarService.instance.isar;
    final history = _findHistoryByEpisode(isar, episodeId, episodeGuid, episodeITunesId);
    return history?.isPlayed ?? false;
  }

  /// 标记 episode 为已播放并设置 playProgress=1.0
  /// PlayHistory 是唯一数据源，调用方应同时更新 Episode 缓存字段
  Future<void> markAsPlayedWithProgress(int episodeId, double progressRatio, {String? episodeGuid, String? episodeITunesId, String? podcastGuid, String? podcastITunesId}) async {
    final isar = IsarService.instance.isar;
    final existing = _findHistoryByEpisode(isar, episodeId, episodeGuid, episodeITunesId);

    if (existing != null) {
      existing.isPlayed = true;
      existing.playProgress = progressRatio;
      existing.status = PlayHistoryStatus.completed;
      existing.lastUpdateTime = DateTime.now();
      await isar.writeTxn(() async {
        await isar.playHistorys.put(existing);
      });
      debugPrint('✅ [PlayHistory] markAsPlayedWithProgress: 已更新 episodeId=$episodeId, playProgress=$progressRatio');
    } else {
      Episode? episode;
      if (episodeGuid != null && episodeGuid.isNotEmpty) {
        final episodes = isar.episodes
            .filter()
            .guidIsNotNull()
            .and()
            .guidIsNotEmpty()
            .findAllSync();
        for (final ep in episodes) {
          if (ep.guid == episodeGuid) {
            episode = ep;
            break;
          }
        }
      } else if (episodeITunesId != null && episodeITunesId.isNotEmpty) {
        final episodes = isar.episodes
            .filter()
            .itunesIdIsNotNull()
            .and()
            .itunesIdIsNotEmpty()
            .findAllSync();
        for (final ep in episodes) {
          if (ep.itunesId == episodeITunesId) {
            episode = ep;
            break;
          }
        }
      } else {
        episode = isar.episodes.getSync(episodeId);
      }

      if (episode == null) {
        debugPrint('⚠️ [PlayHistory] markAsPlayedWithProgress: 未找到 episode: $episodeId，无法创建 PlayHistory 记录');
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
        ..playProgress = progressRatio
        ..status = PlayHistoryStatus.completed
        ..playedDuration = 0
        ..lastUpdateTime = DateTime.now()
        ..isDeleted = false;

      await isar.writeTxn(() async {
        await isar.playHistorys.put(newHistory);
      });
      debugPrint('🆕 [PlayHistory] markAsPlayedWithProgress: 已创建新记录 episodeId=$episodeId, playProgress=$progressRatio');
    }
  }

  /// 获取所有已播放的 episode ID 集合（用于交叉过滤未播放列表）
  Future<Set<int>> getPlayedEpisodeIds() async {
    final isar = IsarService.instance.isar;
    final playedHistories = isar.playHistorys
        .filter()
        .isPlayedEqualTo(true)
        .and()
        .isDeletedEqualTo(false)
        .findAllSync();
    return playedHistories.map((h) => h.episodeId).toSet();
  }

  Future<void> markAsCompleted(int episodeId, {String? episodeGuid, String? episodeITunesId}) async {
    final isar = IsarService.instance.isar;
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

  Future<void> updateOrCreatePlayHistoryAsCompleted(int episodeId, {String? episodeGuid, String? episodeITunesId, String? podcastGuid, String? podcastITunesId}) async {
    final isar = IsarService.instance.isar;
    final existing = _findHistoryByEpisode(isar, episodeId, episodeGuid, episodeITunesId);
    
    if (existing != null) {
      existing.isPlayed = true;
      existing.status = PlayHistoryStatus.completed;
      existing.lastUpdateTime = DateTime.now();
      await isar.writeTxn(() async {
        await isar.playHistorys.put(existing);
      });
      debugPrint('✅ [PlayHistory] 已更新 episodeId=$episodeId 为 completed 状态');
    } else {
      Episode? episode;
      if (episodeGuid != null && episodeGuid.isNotEmpty) {
        final episodes = isar.episodes
            .filter()
            .guidIsNotNull()
            .and()
            .guidIsNotEmpty()
            .findAllSync();
        for (final ep in episodes) {
          if (ep.guid == episodeGuid) {
            episode = ep;
            break;
          }
        }
      } else if (episodeITunesId != null && episodeITunesId.isNotEmpty) {
        final episodes = isar.episodes
            .filter()
            .itunesIdIsNotNull()
            .and()
            .itunesIdIsNotEmpty()
            .findAllSync();
        for (final ep in episodes) {
          if (ep.itunesId == episodeITunesId) {
            episode = ep;
            break;
          }
        }
      } else {
        episode = isar.episodes.getSync(episodeId);
      }

      if (episode == null) {
        debugPrint('⚠️ [PlayHistory] 未找到 episode: $episodeId，无法创建 PlayHistory 记录');
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
        ..status = PlayHistoryStatus.completed
        ..playedDuration = 0
        ..lastUpdateTime = DateTime.now()
        ..isDeleted = false;
      
      await isar.writeTxn(() async {
        await isar.playHistorys.put(newHistory);
      });
      debugPrint('🆕 [PlayHistory] 已创建新记录 episodeId=$episodeId, 标题: ${episode.title}, 状态为 completed');
    }
  }

  Future<void> softDelete(int episodeId, {String? episodeGuid, String? episodeITunesId}) async {
    final isar = IsarService.instance.isar;
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

  Future<void> removeByPodcastId(int podcastId, {String? podcastGuid, String? podcastITunesId}) async {
    debugPrint('🗑️ [PlayHistory] 开始清理 podcastId=$podcastId 的历史记录, podcastITunesId: $podcastITunesId');
    final isar = IsarService.instance.isar;
    await isar.writeTxn(() async {
      List<PlayHistory> histories;
      if (podcastITunesId != null && podcastITunesId.isNotEmpty) {
        histories = isar.playHistorys
            .filter()
            .podcastITunesIdEqualTo(podcastITunesId)
            .findAllSync();
      } else if (podcastGuid != null && podcastGuid.isNotEmpty) {
        histories = isar.playHistorys
            .filter()
            .podcastGuidEqualTo(podcastGuid)
            .findAllSync();
      } else {
        histories = isar.playHistorys
            .filter()
            .podcastIdEqualTo(podcastId)
            .findAllSync();
      }

      debugPrint('🗑️ [PlayHistory] 找到 ${histories.length} 条记录待清理');
      for (final history in histories) {
        await isar.playHistorys.delete(history.id);
      }
      debugPrint('✅ [PlayHistory] 已清理 ${histories.length} 条历史记录');
    });
  }
}
