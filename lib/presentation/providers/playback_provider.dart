import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/models/episode_model.dart' as episode_model;
import 'package:tinycast/data/repositories/play_history_repository.dart';
import 'package:tinycast/domain/entities/app_settings.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/data/services/audio_download_service.dart';
import 'package:tinycast/data/services/audio_player_service.dart';
import 'package:tinycast/data/services/settings_service.dart';
import 'package:tinycast/presentation/providers/play_history_provider.dart';
import 'package:tinycast/presentation/providers/queue_provider.dart';
import 'package:tinycast/presentation/providers/unplayed_episodes_provider.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/core/providers/sync_provider.dart';
import 'package:tinycast/presentation/providers/settings_provider.dart';
import 'package:tinycast/core/services/play_progress_service.dart';

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
  PlayProgressService get _playProgressService => PlayProgressService.instance;
  PlayHistoryRepository get _playHistoryRepository => PlayHistoryRepository();
  Timer? _progressSaveTimer;
  Timer? _sleepTimerCheck;
  int _lastSavedPositionMs = 0;
  DateTime? _lastSaveTime;
  int? _currentEpisodeId;

  @override
  PlayerState build() {
    _initListeners();
    _initProgressAutoSave();
    _initSleepTimerCheck();

    _restoreLastPlaybackState();
    _restoreSettingsFromPrefs();

    ref.onDispose(() {
      _disposeListeners();
      _disposeAutoSave();
      _disposeSleepTimerCheck();
      _saveCurrentProgress();
    });
    return PlayerState();
  }

  void _initSleepTimerCheck() {
    ref.listen<AsyncValue<AppSettings>>(settingsProvider, (previous, next) {
      if (next.hasValue && next.value != previous?.value) {
        _evaluateSleepTimer();
      }
    });

    _sleepTimerCheck = Timer.periodic(const Duration(seconds: 1), (_) {
      _evaluateSleepTimer();
    });
  }

  void _disposeSleepTimerCheck() {
    _sleepTimerCheck?.cancel();
    _sleepTimerCheck = null;
  }

  Future<void> _evaluateSleepTimer() async {
    try {
      final settingsAsync = ref.read(settingsProvider);
      final settings = settingsAsync.value;
      if (settings == null) return;

      if (settings.sleepTimer == SleepTimerOption.off ||
          settings.sleepTimerEndTimeMillis == null) {
        return;
      }

      final endTime = DateTime.fromMillisecondsSinceEpoch(
        settings.sleepTimerEndTimeMillis!,
      );

      if (DateTime.now().isAfter(endTime)) {
        debugPrint('⏰ [SleepTimer] Timer expired, pausing playback');
        await pause();
        await SettingsService.instance.setSleepTimer(SleepTimerOption.off);
        await SettingsService.instance.setSleepTimerEndTimeMillis(null);
        _requestSync();
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to evaluate sleep timer',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _restoreSettingsFromPrefs() async {
    try {
      final settings = await SettingsService.instance.loadSettings();
      if (settings.playbackSpeed != AppSettings.defaultPlaybackSpeed) {
        await _audioPlayerService.setSpeed(settings.playbackSpeed);
      }
      if (settings.volume != AppSettings.defaultVolume) {
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
    final queueState = ref.read(queueNotifierProvider);
    final queueEpisode = queueState.queueEpisodes.where((e) => e.id == episodeId).firstOrNull;
    
    if (queueEpisode != null) {
      debugPrint('🎯 [Playback] Episode $episodeId completed, removing from queue...');
      try {
        await ref.read(queueNotifierProvider.notifier)
            .removeFromQueueByEpisodeId(queueEpisode);
      } catch (e, stackTrace) {
        debugPrint('❌ [Playback] Failed to remove episode $episodeId from queue: $e\n$stackTrace');
      }
    } else {
      debugPrint('⚠️ [Playback] Episode $episodeId not in queue (already removed or not queued), skipping queue removal');
    }

    // 2. 标记当前音频为已播放
    await _markEpisodeAsPlayed(episodeId);

    // 3. 检查并自动删除下载的音频文件
    await _handleAutoDeleteDownload(episodeId);

    // 4. 刷新未播放剧集列表（必须等待刷新完成，否则后续会获取到旧的列表）
    debugPrint('🎯 [Playback] Episode $episodeId completed, refreshing unplayed episodes...');
    try {
      await ref.read(unplayedEpisodesNotifierProvider.notifier).refresh();
      debugPrint('✅ [Playback] Unplayed episodes list refreshed');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to refresh unplayed episodes',
        error: e,
        stackTrace: stackTrace,
      );
    }

    // 5. 检查睡眠定时器（优先级高于连续播放）
    final settingsAsync = ref.read(settingsProvider);
    final settings = settingsAsync.value;
    if (settings != null && settings.sleepTimer == SleepTimerOption.episodeEnd) {
      debugPrint('⏰ [SleepTimer] Episode ended, pausing playback');
      await pause();
      await SettingsService.instance.setSleepTimer(SleepTimerOption.off);
      await SettingsService.instance.setSleepTimerEndTimeMillis(null);
      _requestSync();
      return;
    }

    // 6. 根据连续播放设置处理下一集播放
    await _handleNextEpisodePlayback();
  }

  /// 标记 episode 为已播放
  /// 使用 PlayProgressService 统一处理 PlayHistory 和 Episode 缓存同步
  Future<void> _markEpisodeAsPlayed(int episodeId) async {
    try {
      final currentEpisode = state.currentEpisode;

      await _playProgressService.markEpisodeAsPlayed(
        episodeId: episodeId,
        episodeGuid: currentEpisode?.guid,
        episodeITunesId: currentEpisode?.itunesId,
        podcastGuid: null,
        podcastITunesId: currentEpisode?.podcastITunesId,
      );

      debugPrint('✅ [Playback] Marked episode $episodeId as played (cache synced)');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to mark episode as played',
        error: e,
        stackTrace: stackTrace,
      );
    }
    _requestSync();
  }

  /// 检查设置并在需要时自动删除已播放的下载文件
  Future<void> _handleAutoDeleteDownload(int episodeId) async {
    try {
      final settingsAsync = ref.read(settingsProvider);
      final removePlayedDownloads = settingsAsync.value?.removePlayedDownloads ?? false;
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
      final settingsAsync = ref.read(settingsProvider);
      final continuousPlay = settingsAsync.value?.continuousPlay ?? true;

      if (!continuousPlay) {
        debugPrint('⏸️ [Playback] Continuous play disabled, staying at completed episode');
        return;
      }

      // 优先从队列中获取下一集
      final queueState = ref.read(queueNotifierProvider);
      if (queueState.queueEpisodes.isNotEmpty) {
        final nextFromQueue = queueState.queueEpisodes.first;
        debugPrint('🎯 [Playback] Next from queue: ${nextFromQueue.title} (id: ${nextFromQueue.id})');
        await playEpisode(nextFromQueue);
        return;
      }

      // 队列空则从未播放列表中获取
      final unplayedState = ref.read(unplayedEpisodesNotifierProvider);
      final nextEpisode = unplayedState.episodes.isNotEmpty
          ? unplayedState.episodes.first
          : null;

      if (nextEpisode == null) {
        debugPrint('🎯 [Playback] No more episodes in queue or unplayed list');
        return;
      }

      debugPrint('🔄 [Playback] Continuous play enabled, auto-playing next: ${nextEpisode.title}');
      await playEpisode(nextEpisode);
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
    final durationMs = state.duration.inMilliseconds;

    try {
      final progressRatio = durationMs > 0 ? positionMs / durationMs : 0.0;

      await _playProgressService.updatePlayProgress(
        episodeId: currentEpisode.id,
        positionMs: positionMs,
        progressRatio: progressRatio,
        episodeGuid: currentEpisode.guid,
        episodeITunesId: currentEpisode.itunesId,
      );

      _lastSavedPositionMs = positionMs;
      _lastSaveTime = DateTime.now();
    } catch (e) {
      debugPrint('Error saving play progress: $e');
    }
  }

  Future<void> _createOrUpdatePlayHistory(Episode episode) async {
    try {
      final durationMs = state.duration.inMilliseconds;
      final positionMs = state.currentPosition.inMilliseconds;
      final progressRatio = durationMs > 0 ? positionMs / durationMs : 0.0;

      await _playProgressService.createOrUpdatePlayHistory(
        episode: episode,
        positionMs: positionMs,
        progressRatio: progressRatio,
      );

      _currentEpisodeId = episode.id;
      _lastSavedPositionMs = positionMs;
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
        isPlayed: latestHistory.isPlayed,
        isDownloaded: episode.isDownloaded,
        isFavorite: false,
        downloadedPath: episode.downloadedPath,
        downloadProgress: episode.downloadProgress,
        playProgress: latestHistory.playProgress,
        lastPlayedAt: episode.lastPlayedAt,
        createdAt: episode.createdAt,
        updatedAt: episode.updatedAt,
        itunesId: episode.itunesId,
        podcastITunesId: episode.podcastITunesId,
        itunesArtworkUrl: episode.itunesArtworkUrl,
        itunesReleaseDate: episode.itunesReleaseDate,
        itunesExplicitness: episode.itunesExplicitness,
        itunesContentAdvisoryRating: episode.itunesContentAdvisoryRating,
      );

      _currentEpisodeId = domainEpisode.id;
      _lastSavedPositionMs = latestHistory.lastPlayedPositionMs;
      _lastSaveTime = DateTime.now();

      // 同步 PlayHistory 的播放状态到 Episode 缓存
      try {
        final isar = IsarService.instance.isar;
        await isar.writeTxn(() async {
          final ep = await isar.episodes.get(episode.id);
          if (ep != null && (ep.isPlayed != latestHistory.isPlayed || ep.playProgress != latestHistory.playProgress)) {
            ep.isPlayed = latestHistory.isPlayed;
            ep.playProgress = latestHistory.playProgress;
            ep.updatedAt = DateTime.now();
            await isar.episodes.put(ep);
            debugPrint('🔄 [Playback] Synced Episode cache from PlayHistory: isPlayed=${latestHistory.isPlayed}, playProgress=${latestHistory.playProgress}');
          }
        });
      } catch (e) {
        debugPrint('⚠️ [Playback] Failed to sync Episode cache from PlayHistory: $e');
      }

      state = state.copyWith(currentEpisode: domainEpisode);

      // 检查本地文件是否存在
      bool fileExists = false;
      if (domainEpisode.downloadedPath != null) {
        try {
          final supportDir = await getApplicationSupportDirectory();
          final primaryPath = '${supportDir.path}/${domainEpisode.downloadedPath!}';
          final primaryFile = File(primaryPath);
          fileExists = await primaryFile.exists();
          
          if (!fileExists) {
            final docsDir = await getApplicationDocumentsDirectory();
            final fallbackPath = '${docsDir.path}/${domainEpisode.downloadedPath!}';
            final fallbackFile = File(fallbackPath);
            fileExists = await fallbackFile.exists();
          }
        } catch (e) {
          debugPrint('Failed to check file existence: $e');
          fileExists = false;
        }
      }

      // 如果本地文件存在则加载，否则仅恢复 UI 状态而不加载音频
      if (fileExists || domainEpisode.audioUrl.isNotEmpty) {
        final startPosition = Duration(
          milliseconds: latestHistory.lastPlayedPositionMs,
        );

        debugPrint('Initializing AudioPlayerService with restored episode...');
        try {
          await _audioPlayerService.loadEpisode(
            domainEpisode,
            startPosition: startPosition,
          );

          debugPrint(
            'Playback state restored successfully - all controls should work',
          );
        } catch (e, stackTrace) {
          debugPrint('Failed to load audio for restored episode: $e');
          debugPrint('Stack trace: $stackTrace');
          // 加载音频失败时，清除状态但保留 UI 显示
          _currentEpisodeId = null;
          _lastSavedPositionMs = 0;
          state = state.copyWith(currentEpisode: null);
        }
      } else {
        debugPrint('Local file not found and no remote URL, skipping audio load');
      }
    } catch (e, stackTrace) {
      debugPrint('Error restoring playback state: $e');
      debugPrint('Stack trace: $stackTrace');
      // 恢复失败时，清除状态
      _currentEpisodeId = null;
      _lastSavedPositionMs = 0;
      state = state.copyWith(currentEpisode: null);
    }
  }

  Future<void> playEpisode(Episode episode, {Duration? startPosition}) async {
    debugPrint('🎵 [PLAYBACK] playEpisode called: ${episode.title} (id: ${episode.id})');
    debugPrint('🎵 [PLAYBACK] _currentEpisodeId: $_currentEpisodeId, episode.id: ${episode.id}');
    
    if (_currentEpisodeId != null && _currentEpisodeId != episode.id) {
      debugPrint('🎵 [PLAYBACK] Different episode, saving current progress...');
      await _saveCurrentProgress();
    }

    debugPrint('🎵 [PLAYBACK] Creating play history...');
    await _createOrUpdatePlayHistory(episode);

    _currentEpisodeId = episode.id;
    debugPrint('🎵 [PLAYBACK] _currentEpisodeId updated to: $_currentEpisodeId');

    debugPrint('🎵 [PLAYBACK] Calling AudioPlayerService.playEpisode...');
    await _audioPlayerService.playEpisode(
      episode,
      startPosition: startPosition,
    );
    debugPrint('🎵 [PLAYBACK] AudioPlayerService.playEpisode completed');
  }

  Future<void> play() async {
    await _audioPlayerService.play();
  }

  Future<void> pause() async {
    await _audioPlayerService.pause();
    _requestSync();
  }

  Future<void> togglePlayPause() async {
    await _audioPlayerService.togglePlayPause();
  }

  Future<void> seekForward({
    Duration? duration,
  }) async {
    final skipTime = duration?.inSeconds ??
        (ref.read(settingsProvider).value?.skipForwardTime ?? AppSettings.defaultSkipForwardTime);
    await _audioPlayerService.seekForward(
      duration: Duration(seconds: skipTime),
    );
  }

  Future<void> seekBackward({
    Duration? duration,
  }) async {
    final skipTime = duration?.inSeconds ??
        (ref.read(settingsProvider).value?.skipBackwardTime ?? AppSettings.defaultSkipBackwardTime);
    await _audioPlayerService.seekBackward(
      duration: Duration(seconds: skipTime),
    );
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayerService.seek(position);
    await _saveCurrentProgress();

    await _markEpisodeAsCompletedIfNeeded();
  }

  Future<void> setSpeed(double speed) async {
    await _audioPlayerService.setSpeed(speed);
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayerService.setVolume(volume);
  }

  Future<void> stop() async {
    await _saveCurrentProgress();

    await _markEpisodeAsCompletedIfNeeded();

    _currentEpisodeId = null;

    await _audioPlayerService.stop();
  }

  Future<void> _markEpisodeAsCompletedIfNeeded() async {
    final currentEpisode = state.currentEpisode;
    if (currentEpisode == null) return;

    final progressRatio = state.progressRatio;
    if (progressRatio < 0.95) return;

    debugPrint(
      '🎯 [Playback] Progress ${((progressRatio) * 100).toStringAsFixed(1)}% >= 95%, marking as completed',
    );

    try {
      await _playProgressService.markEpisodeAsPlayed(
        episodeId: currentEpisode.id,
        episodeGuid: currentEpisode.guid,
        episodeITunesId: currentEpisode.itunesId,
        podcastGuid: null,
        podcastITunesId: currentEpisode.podcastITunesId,
      );

      debugPrint('🔄 [Playback] Auto-refreshing History list...');
      ref.read(completedHistoriesProvider.notifier).refresh();
      _requestSync();
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to mark episode as completed',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _requestSync() {
    try {
      ref.read(syncProvider.notifier).requestSync();
    } catch (e) {
      Logger.warning('Sync request failed: $e', tag: 'PlaybackProvider');
    }
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
