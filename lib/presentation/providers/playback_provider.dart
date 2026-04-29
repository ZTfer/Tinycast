import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/models/episode_model.dart' as episode_model;
import 'package:tinycast/data/models/play_history_model.dart';
import 'package:tinycast/data/repositories/play_history_repository.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/data/services/audio_download_service.dart';
import 'package:tinycast/data/services/audio_player_service.dart';
import 'package:tinycast/data/services/settings_service.dart';
import 'package:tinycast/presentation/providers/play_history_provider.dart';
import 'package:tinycast/presentation/providers/queue_provider.dart';
import 'package:tinycast/presentation/providers/unplayed_episodes_provider.dart';
import 'package:tinycast/core/utils/logger.dart';

class PlayerState {
  final Episode? currentEpisode;
  final bool isPlaying;
  final Duration currentPosition;
  final Duration duration;
  final double speed;
  final double volume;

  PlayerState({
    this.currentEpisode,
    this.isPlaying = false,
    this.currentPosition = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.volume = 0.3,
  });

  PlayerState copyWith({
    Episode? currentEpisode,
    bool? isPlaying,
    Duration? currentPosition,
    Duration? duration,
    double? speed,
    double? volume,
  }) {
    return PlayerState(
      currentEpisode: currentEpisode ?? this.currentEpisode,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
    );
  }

  double get progressRatio {
    if (duration.inMilliseconds == 0) return 0.0;
    return currentPosition.inMilliseconds / duration.inMilliseconds;
  }
}

class PlaybackNotifier extends Notifier<PlayerState> {
  StreamSubscription? _playbackStateSubscription;
  StreamSubscription? _progressSubscription;
  StreamSubscription? _speedSubscription;
  StreamSubscription? _volumeSubscription;
  StreamSubscription? _currentEpisodeSubscription;
  StreamSubscription? _episodeCompletedSubscription;

  AudioPlayerService get _audioPlayerService => AudioPlayerService.instance;
  PlayHistoryRepository get _playHistoryRepository => PlayHistoryRepository();
  Timer? _progressSaveTimer;
  int _lastSavedPositionMs = 0;
  DateTime? _lastSaveTime;
  int? _currentEpisodeId;

  @override
  PlayerState build() {
    _initListeners();
    _initProgressAutoSave();

    _restoreLastPlaybackState();
    _restoreSettingsFromPrefs();

    ref.onDispose(() {
      _disposeListeners();
      _disposeAutoSave();
      _saveCurrentProgress();
    });
    return PlayerState();
  }

  Future<void> _restoreSettingsFromPrefs() async {
    try {
      final settings = await SettingsService.instance.loadSettings();
      if (settings.playbackSpeed != 1.0) {
        await _audioPlayerService.setSpeed(settings.playbackSpeed);
      }
      if (settings.volume != 0.3) {
        await _audioPlayerService.setVolume(settings.volume);
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to restore settings from prefs',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _initListeners() {
    _playbackStateSubscription = _audioPlayerService.playbackStateStream.listen(
      (playbackState) {
        final isPlaying =
            playbackState == PlaybackState.playing ||
            playbackState == PlaybackState.buffering;
        state = state.copyWith(isPlaying: isPlaying);
      },
    );

    _progressSubscription = _audioPlayerService.progressStream.listen((
      progress,
    ) {
      state = state.copyWith(
        currentPosition: progress.position,
        duration: progress.duration,
      );
    });

    _speedSubscription = _audioPlayerService.speedStream.listen((speed) {
      state = state.copyWith(speed: speed);
    });

    _volumeSubscription = _audioPlayerService.volumeStream.listen((volume) {
      state = state.copyWith(volume: volume);
    });

    _currentEpisodeSubscription = _audioPlayerService.currentEpisodeStream
        .listen((episode) {
          state = state.copyWith(currentEpisode: episode);
        });

    _episodeCompletedSubscription = _audioPlayerService.episodeCompletedStream
        .listen((episodeId) {
          _onEpisodeCompleted(episodeId);
        });
  }

  void _disposeListeners() {
    _playbackStateSubscription?.cancel();
    _progressSubscription?.cancel();
    _speedSubscription?.cancel();
    _volumeSubscription?.cancel();
    _currentEpisodeSubscription?.cancel();
    _episodeCompletedSubscription?.cancel();
  }

  Future<void> _onEpisodeCompleted(int episodeId) async {
    // 1. 从队列中移除已完成的剧集
    final queueState = ref.read(queueNotifierProvider);
    final isInQueue = queueState.queueEpisodes.any((e) => e.id == episodeId);
    if (isInQueue) {
      debugPrint('🎯 [Playback] Episode $episodeId completed, removing from queue...');
      try {
        await ref.read(queueNotifierProvider.notifier)
            .removeFromQueueByEpisodeId(episodeId);
      } catch (e, stackTrace) {
        debugPrint('❌ [Playback] Failed to remove episode $episodeId from queue: $e\n$stackTrace');
      }
    }

    // 2. 标记当前音频为已播放
    await _markEpisodeAsPlayed(episodeId);

    // 3. 检查并自动删除下载的音频文件
    await _handleAutoDeleteDownload(episodeId);

    // 4. 刷新未播放剧集列表
    debugPrint('🎯 [Playback] Episode $episodeId completed, refreshing unplayed episodes...');
    ref.read(unplayedEpisodesNotifierProvider.notifier).refresh();

    // 5. 根据连续播放设置处理下一集播放
    await _handleNextEpisodePlayback();
  }

  /// 标记 episode 为已播放
  Future<void> _markEpisodeAsPlayed(int episodeId) async {
    try {
      final isar = IsarService.instance.isar;
      await isar.writeTxn(() async {
        final episode = await isar.episodes.get(episodeId);
        if (episode != null) {
          episode.isPlayed = true;
          episode.playProgress = 1.0;
          episode.updatedAt = DateTime.now();
          await isar.episodes.put(episode);
          debugPrint('✅ [Playback] Marked episode $episodeId as played');
        }
      });
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to mark episode as played',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 检查设置并在需要时自动删除已播放的下载文件
  Future<void> _handleAutoDeleteDownload(int episodeId) async {
    try {
      final removePlayedDownloads = await SettingsService.instance.getRemovePlayedDownloads();
      if (!removePlayedDownloads) {
        return;
      }

      final isar = IsarService.instance.isar;
      final episode = await isar.episodes.get(episodeId);
      if (episode == null || !episode.isDownloaded || episode.downloadedPath == null) {
        return;
      }

      debugPrint('🗑️ [Playback] Auto-deleting downloaded episode: $episodeId');
      await AudioDownloadService.instance.deleteDownloadedEpisode(episodeId.toString());
      debugPrint('✅ [Playback] Auto-deleted episode: $episodeId');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to auto-delete episode',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 根据连续播放设置处理下一集播放
  Future<void> _handleNextEpisodePlayback() async {
    try {
      final settings = await SettingsService.instance.loadSettings();
      final continuousPlay = settings.continuousPlay;

      final unplayedState = ref.read(unplayedEpisodesNotifierProvider);
      final nextEpisode = unplayedState.episodes.isNotEmpty
          ? unplayedState.episodes.first
          : null;

      if (nextEpisode == null) {
        debugPrint('🎯 [Playback] No more unplayed episodes');
        return;
      }

      if (continuousPlay) {
        debugPrint('🔄 [Playback] Continuous play enabled, auto-playing next: ${nextEpisode.title}');
        await playEpisode(nextEpisode);
      } else {
        debugPrint('⏸️ [Playback] Continuous play disabled, staying at completed episode');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to handle next episode playback',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _initProgressAutoSave() {
    _progressSaveTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _autoSaveProgressIfNeeded();
    });
  }

  Future<void> _autoSaveProgressIfNeeded() async {
    final currentEpisode = state.currentEpisode;
    if (currentEpisode == null) return;

    final positionMs = state.currentPosition.inMilliseconds;
    final now = DateTime.now();

    final timeCondition =
        _lastSaveTime == null || now.difference(_lastSaveTime!).inSeconds >= 10;

    final progressDelta = (positionMs - _lastSavedPositionMs).abs();
    final durationMs = state.duration.inMilliseconds;
    final progressCondition =
        durationMs > 0 &&
        (progressDelta >= durationMs * 0.05 || progressDelta >= 5000);

    if (timeCondition || progressCondition) {
      await _saveCurrentProgress();
    }
  }

  Future<void> _saveCurrentProgress() async {
    final currentEpisode = state.currentEpisode;
    if (currentEpisode == null) return;

    final positionMs = state.currentPosition.inMilliseconds;

    try {
      await _playHistoryRepository.updateProgress(
        currentEpisode.id,
        positionMs,
        positionMs - _lastSavedPositionMs,
      );

      _lastSavedPositionMs = positionMs;
      _lastSaveTime = DateTime.now();
    } catch (e) {
      debugPrint('Error saving play progress: $e');
    }
  }

  Future<void> _createOrUpdatePlayHistory(Episode episode) async {
    try {
      final history = PlayHistory()
        ..episodeId = episode.id
        ..podcastId = episode.podcastId
        ..title = episode.title
        ..description = episode.description
        ..artworkUrl = episode.artworkUrl
        ..lastPlayedPositionMs = state.currentPosition.inMilliseconds
        ..isPlayed = false
        ..playedDuration = 0
        ..status = PlayHistoryStatus.playing
        ..lastUpdateTime = DateTime.now()
        ..isDeleted = false;

      await _playHistoryRepository.saveOrUpdate(history);
      _currentEpisodeId = episode.id;
      _lastSavedPositionMs = state.currentPosition.inMilliseconds;
      _lastSaveTime = DateTime.now();
    } catch (e) {
      debugPrint('Error creating play history: $e');
    }
  }

  void _disposeAutoSave() {
    _progressSaveTimer?.cancel();
    _progressSaveTimer = null;
  }

  Future<void> _restoreLastPlaybackState() async {
    try {
      final latestHistory = await _playHistoryRepository
          .getLatestPlayingHistory();

      if (latestHistory == null) {
        debugPrint('No previous playback history found');
        return;
      }

      debugPrint('Restoring last playback: ${latestHistory.title}');

      final isar = IsarService.instance.isar;
      final episode = await isar.episodes.get(latestHistory.episodeId);

      if (episode == null) {
        debugPrint('Episode not found in database (may be deleted)');
        return;
      }

      final domainEpisode = Episode(
        id: episode.id,
        podcastId: episode.podcastId,
        title: episode.title,
        description: episode.description,
        link: episode.link,
        guid: episode.guid,
        author: episode.author,
        pubDate: episode.pubDate,
        audioUrl: episode.audioUrl,
        audioType: episode.audioType,
        duration: episode.duration,
        artworkUrl: episode.artworkUrl,
        isExplicit: episode.isExplicit,
        isPlayed: episode.isPlayed,
        isDownloaded: episode.isDownloaded,
        isFavorite: false,
        downloadedPath: episode.downloadedPath,
        downloadProgress: episode.downloadProgress,
        playProgress: episode.playProgress,
        lastPlayedAt: episode.lastPlayedAt,
        createdAt: episode.createdAt,
        updatedAt: episode.updatedAt,
      );

      _currentEpisodeId = domainEpisode.id;
      _lastSavedPositionMs = latestHistory.lastPlayedPositionMs;
      _lastSaveTime = DateTime.now();

      state = state.copyWith(currentEpisode: domainEpisode);

      final startPosition = Duration(
        milliseconds: latestHistory.lastPlayedPositionMs,
      );

      debugPrint('Initializing AudioPlayerService with restored episode...');
      await _audioPlayerService.loadEpisode(
        domainEpisode,
        startPosition: startPosition,
      );

      debugPrint(
        'Playback state restored successfully - all controls should work',
      );
    } catch (e) {
      debugPrint('Error restoring playback state: $e');
    }
  }

  Future<void> playEpisode(Episode episode, {Duration? startPosition}) async {
    if (_currentEpisodeId != null && _currentEpisodeId != episode.id) {
      await _saveCurrentProgress();
    }

    await _createOrUpdatePlayHistory(episode);

    await _audioPlayerService.playEpisode(
      episode,
      startPosition: startPosition,
    );
  }

  Future<void> play() async {
    await _audioPlayerService.play();
  }

  Future<void> pause() async {
    await _audioPlayerService.pause();
  }

  Future<void> togglePlayPause() async {
    await _audioPlayerService.togglePlayPause();
  }

  Future<void> seekForward({
    Duration? duration,
  }) async {
    final skipTime = duration?.inSeconds ??
        (await SettingsService.instance.getSkipForwardTime());
    await _audioPlayerService.seekForward(
      duration: Duration(seconds: skipTime),
    );
  }

  Future<void> seekBackward({
    Duration? duration,
  }) async {
    final skipTime = duration?.inSeconds ??
        (await SettingsService.instance.getSkipBackwardTime());
    await _audioPlayerService.seekBackward(
      duration: Duration(seconds: skipTime),
    );
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayerService.seek(position);
    await _saveCurrentProgress();

    final currentEpisode = state.currentEpisode;
    if (currentEpisode != null) {
      final durationMs = state.duration.inMilliseconds;
      if (durationMs > 0) {
        final progressRatio = position.inMilliseconds / durationMs;
        if (progressRatio >= 0.95) {
          debugPrint(
            '🎯 [Playback] Progress ${((progressRatio) * 100).toStringAsFixed(1)}% >= 95%, marking as completed',
          );
          await _playHistoryRepository.markAsCompleted(currentEpisode.id);

          debugPrint('🔄 [Playback] Auto-refreshing History list...');
          ref.read(completedHistoriesProvider.notifier).refresh();
        }
      }
    }
  }

  Future<void> setSpeed(double speed) async {
    await _audioPlayerService.setSpeed(speed);
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayerService.setVolume(volume);
  }

  Future<void> stop() async {
    await _saveCurrentProgress();

    final currentEpisode = state.currentEpisode;
    if (currentEpisode != null) {
      final progressRatio = state.progressRatio;
      if (progressRatio >= 0.95) {
        debugPrint(
          '🎯 [Playback] Stop: Progress ${((progressRatio) * 100).toStringAsFixed(1)}% >= 95%, marking as completed',
        );
        await _playHistoryRepository.markAsCompleted(currentEpisode.id);

        debugPrint('🔄 [Playback] Auto-refreshing History list...');
        ref.read(completedHistoriesProvider.notifier).refresh();
      }
    }

    _currentEpisodeId = null;

    await _audioPlayerService.stop();
  }
}

final playbackProvider = NotifierProvider<PlaybackNotifier, PlayerState>(
  PlaybackNotifier.new,
);

final currentEpisodeProvider = Provider<Episode?>((ref) {
  return ref.watch(playbackProvider).currentEpisode;
});

final isPlayingProvider = Provider<bool>((ref) {
  return ref.watch(playbackProvider).isPlaying;
});

final currentPositionProvider = Provider<Duration>((ref) {
  return ref.watch(playbackProvider).currentPosition;
});

final durationProvider = Provider<Duration>((ref) {
  return ref.watch(playbackProvider).duration;
});

final speedProvider = Provider<double>((ref) {
  return ref.watch(playbackProvider).speed;
});

final volumeProvider = Provider<double>((ref) {
  return ref.watch(playbackProvider).volume;
});

final progressRatioProvider = Provider<double>((ref) {
  return ref.watch(playbackProvider).progressRatio;
});
