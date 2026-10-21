import 'package:flutter/foundation.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/models/episode_model.dart' show GetEpisodeCollection;
import 'package:tinycast/data/repositories/play_history_repository_impl.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/play_history.dart';
import 'package:tinycast/domain/repositories/play_history_repository.dart';
import 'package:tinycast/core/utils/logger.dart';

class PlayProgressService {
  PlayProgressService._()
    : _playHistoryRepository = PlayHistoryRepositoryImpl(),
      _isarService = IsarService.instance;

  @visibleForTesting
  PlayProgressService.forTesting({
    PlayHistoryRepository? playHistoryRepository,
    IsarService? isarService,
  }) : _playHistoryRepository =
           playHistoryRepository ?? PlayHistoryRepositoryImpl(),
       _isarService = isarService ?? IsarService.instance;

  static final PlayProgressService _instance = PlayProgressService._();
  static PlayProgressService get instance => _instance;

  final PlayHistoryRepository _playHistoryRepository;
  final IsarService _isarService;

  Future<void> updatePlayProgress({
    required int episodeId,
    required int positionMs,
    required double progressRatio,
    String? episodeGuid,
    String? episodeITunesId,
  }) async {
    try {
      await _playHistoryRepository.updatePlayProgress(
        episodeId,
        positionMs,
        progressRatio,
        episodeGuid: episodeGuid,
        episodeITunesId: episodeITunesId,
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to update play progress for episode $episodeId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> markEpisodeAsPlayed({
    required int episodeId,
    String? episodeGuid,
    String? episodeITunesId,
    String? podcastGuid,
    String? podcastITunesId,
  }) async {
    try {
      await _playHistoryRepository.markAsPlayedWithProgress(
        episodeId,
        1.0,
        episodeGuid: episodeGuid,
        episodeITunesId: episodeITunesId,
        podcastGuid: podcastGuid,
        podcastITunesId: podcastITunesId,
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to mark episode $episodeId as played',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> createOrUpdatePlayHistory({
    required Episode episode,
    required int positionMs,
    required double progressRatio,
  }) async {
    try {
      final history = PlayHistory(
        episodeId: episode.id,
        episodeGuid: episode.guid,
        episodeITunesId: episode.itunesId,
        podcastId: episode.podcastId,
        podcastITunesId: episode.podcastITunesId,
        title: episode.title,
        description: episode.description,
        artworkUrl: episode.artworkUrl,
        lastPlayedPositionMs: positionMs,
        playProgress: progressRatio,
        isPlayed: false,
        playedDuration: 0,
        status: PlayHistoryStatus.playing,
        lastUpdateTime: DateTime.now(),
        createdAt: DateTime.now(),
        isDeleted: false,
      );

      await _playHistoryRepository.saveOrUpdate(history);
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to create or update play history for episode ${episode.id}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 将播放状态（isPlayed / playProgress）同步到 Episode 缓存
  Future<void> syncEpisodePlaybackState(
    int episodeId, {
    required bool isPlayed,
    required double playProgress,
  }) async {
    try {
      await _isarService.isar.writeTxn(() async {
        final episode = await _isarService.isar.episodes.get(episodeId);
        if (episode != null &&
            (episode.isPlayed != isPlayed ||
                episode.playProgress != playProgress)) {
          episode.isPlayed = isPlayed;
          episode.playProgress = playProgress;
          episode.updatedAt = DateTime.now();
          await _isarService.isar.episodes.put(episode);
        }
      });
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to sync episode playback state for episode $episodeId',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

}
