import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tinycast/domain/repositories/play_history_repository.dart';
import 'package:tinycast/domain/entities/app_settings.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/data/services/audio_download_service.dart';
import 'package:tinycast/data/services/audio_player_service.dart';
import 'package:tinycast/data/services/settings_service.dart';
import 'package:tinycast/presentation/providers/play_history_provider.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/presentation/providers/queue_provider.dart';
import 'package:tinycast/presentation/providers/unplayed_episodes_provider.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/presentation/providers/sync_provider.dart';
import 'package:tinycast/presentation/providers/settings_provider.dart';
import 'package:tinycast/core/services/play_progress_service.dart';
import 'package:tinycast/core/utils/app_window_context.dart';

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
  PlayHistoryRepository get _playHistoryRepository =>
      ref.read(playHistoryRepositoryProvider);
  Timer? _progressSaveTimer;
  Timer? _sleepTimerCheck;
  int _lastSavedPositionMs = 0;
  DateTime? _lastSaveTime;
  int? _currentEpisodeId;
  int _restoreGeneration = 0;
  bool _userInitiatedPlayback = false;
  // 状态快照：Riverpod 3 禁止在 onDispose 生命周期内访问 state，
  // dispose 时的进度保存只能依赖此快照
  PlayerState _playerState = PlayerState();

  void _updateState(PlayerState newState) {
    _playerState = newState;
    state = newState;
  }

  @override
  PlayerState build() {
    _initListeners();
    _initProgressAutoSave();
    _initSleepTimerCheck();

    if (AppWindowContext.isMainWindow) {
      _restoreLastPlaybackState();
    }
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
        Logger.info('⏰ [SleepTimer] Timer expired, pausing playback');
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
        _updateState(_playerState.copyWith(isPlaying: isPlaying));
      },
    );

    _progressSubscription = _audioPlayerService.progressStream.listen((
      progress,
    ) {
      _updateState(_playerState.copyWith(
        currentPosition: progress.position,
        duration: progress.duration,
      ));
    });

    _speedSubscription = _audioPlayerService.speedStream.listen((speed) {
      _updateState(_playerState.copyWith(speed: speed));
    });

    _volumeSubscription = _audioPlayerService.volumeStream.listen((volume) {
      _updateState(_playerState.copyWith(volume: volume));
    });

    _currentEpisodeSubscription = _audioPlayerService.currentEpisodeStream
        .listen((episode) {
          _updateState(_playerState.copyWith(currentEpisode: episode));
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
      Logger.info('🎯 [Playback] Episode $episodeId completed, removing from queue...');
      try {
        await ref.read(queueNotifierProvider.notifier)
            .removeFromQueueByEpisodeId(queueEpisode);
      } catch (e, stackTrace) {
        Logger.error('❌ [Playback] Failed to remove episode $episodeId from queue', error: e, stackTrace: stackTrace);
      }
    } else {
      Logger.warning('⚠️ [Playback] Episode $episodeId not in queue (already removed or not queued), skipping queue removal');
    }

    // 2. 标记当前音频为已播放
    await _markEpisodeAsPlayed(episodeId);

    // 3. 检查并自动删除下载的音频文件
    await _handleAutoDeleteDownload(episodeId);

    // 4. 刷新未播放剧集列表（必须等待刷新完成，否则后续会获取到旧的列表）
    Logger.info('🎯 [Playback] Episode $episodeId completed, refreshing unplayed episodes...');
    try {
      await ref.read(unplayedEpisodesNotifierProvider.notifier).refresh();
      Logger.info('✅ [Playback] Unplayed episodes list refreshed');
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
      Logger.info('⏰ [SleepTimer] Episode ended, pausing playback');
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

      Logger.info('✅ [Playback] Marked episode $episodeId as played (cache synced)');
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

      final episodes = await ref
          .read(podcastRepositoryProvider)
          .getEpisodesByIds([episodeId]);
      final episode = episodes.isEmpty ? null : episodes.first;
      if (episode == null || !episode.isDownloaded || episode.downloadedPath == null) {
        return;
      }

      Logger.info('🗑️ [Playback] Auto-deleting downloaded episode: $episodeId');
      await AudioDownloadService.instance.deleteDownloadedEpisode(episodeId.toString());
      Logger.info('✅ [Playback] Auto-deleted episode: $episodeId');
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
        Logger.info('⏸️ [Playback] Continuous play disabled, staying at completed episode');
        return;
      }

      // 优先从队列中获取下一集
      final queueState = ref.read(queueNotifierProvider);
      if (queueState.queueEpisodes.isNotEmpty) {
        final nextFromQueue = queueState.queueEpisodes.first;
        Logger.info('🎯 [Playback] Next from queue: ${nextFromQueue.title} (id: ${nextFromQueue.id})');
        await playEpisode(nextFromQueue);
        return;
      }

      // 队列空则从未播放列表中获取
      final unplayedState = ref.read(unplayedEpisodesNotifierProvider);
      final nextEpisode = unplayedState.episodes.isNotEmpty
          ? unplayedState.episodes.first
          : null;

      if (nextEpisode == null) {
        Logger.info('🎯 [Playback] No more episodes in queue or unplayed list');
        return;
      }

      Logger.info('🔄 [Playback] Continuous play enabled, auto-playing next: ${nextEpisode.title}');
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
    // 暂停时位置不会变化，无需周期性写入；暂停/停止会显式保存。
    if (!state.isPlaying) return;

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
    final currentEpisode = _playerState.currentEpisode;
    if (currentEpisode == null) return;

    final positionMs = _playerState.currentPosition.inMilliseconds;
    final durationMs = _playerState.duration.inMilliseconds;

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
    } catch (e, stackTrace) {
      Logger.error('Error saving play progress', error: e, stackTrace: stackTrace);
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
    } catch (e, stackTrace) {
      Logger.error('Error creating play history', error: e, stackTrace: stackTrace);
    }
  }

  void _disposeAutoSave() {
    _progressSaveTimer?.cancel();
    _progressSaveTimer = null;
  }

  Future<void> _restoreLastPlaybackState() async {
    final restoreGeneration = ++_restoreGeneration;
    try {
      final latestHistory = await _playHistoryRepository
          .getLatestPlayingHistory();

      if (latestHistory == null) {
        Logger.info('No previous playback history found');
        return;
      }

      if (_isRestoreCancelled(restoreGeneration)) return;

      Logger.info('Restoring last playback: ${latestHistory.title}');

      final episodes = await ref
          .read(podcastRepositoryProvider)
          .getEpisodesByIds([latestHistory.episodeId]);
      final episode = episodes.isEmpty ? null : episodes.first;

      if (episode == null) {
        Logger.warning('Episode not found in database (may be deleted)');
        return;
      }

      if (_isRestoreCancelled(restoreGeneration)) return;

      final domainEpisode = episode.copyWith(
        isPlayed: latestHistory.isPlayed,
        playProgress: latestHistory.playProgress,
      );

      _currentEpisodeId = domainEpisode.id;
      _lastSavedPositionMs = latestHistory.lastPlayedPositionMs;
      _lastSaveTime = DateTime.now();

      // 同步 PlayHistory 的播放状态到 Episode 缓存
      await _playProgressService.syncEpisodePlaybackState(
        episode.id,
        isPlayed: latestHistory.isPlayed,
        playProgress: latestHistory.playProgress,
      );
      Logger.info('🔄 [Playback] Synced Episode cache from PlayHistory: isPlayed=${latestHistory.isPlayed}, playProgress=${latestHistory.playProgress}');

      _updateState(_playerState.copyWith(currentEpisode: domainEpisode));

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
        } catch (e, stackTrace) {
          Logger.error('Failed to check file existence', error: e, stackTrace: stackTrace);
          fileExists = false;
        }
      }

      // 如果本地文件存在则加载，否则仅恢复 UI 状态而不加载音频
      if (fileExists || domainEpisode.audioUrl.isNotEmpty) {
        final startPosition = Duration(
          milliseconds: latestHistory.lastPlayedPositionMs,
        );

        Logger.info('Initializing AudioPlayerService with restored episode...');
        try {
          if (_isRestoreCancelled(restoreGeneration)) return;
          await _audioPlayerService.loadEpisode(
            domainEpisode,
            startPosition: startPosition,
          );
          if (_isRestoreCancelled(restoreGeneration)) return;

          Logger.info(
            'Playback state restored successfully - all controls should work',
          );
        } catch (e, stackTrace) {
          Logger.error('Failed to load audio for restored episode',
              error: e, stackTrace: stackTrace);
          if (_isRestoreCancelled(restoreGeneration)) return;
          // 加载音频失败时，清除状态但保留 UI 显示
          _currentEpisodeId = null;
          _lastSavedPositionMs = 0;
          _updateState(PlayerState(
            speed: _playerState.speed,
            volume: _playerState.volume,
          ));
        }
      } else {
        Logger.info('Local file not found and no remote URL, skipping audio load');
      }
    } catch (e, stackTrace) {
      Logger.error('Error restoring playback state',
          error: e, stackTrace: stackTrace);
      if (_isRestoreCancelled(restoreGeneration)) return;
      // 恢复失败时，清除状态
      _currentEpisodeId = null;
      _lastSavedPositionMs = 0;
      _updateState(PlayerState(
        speed: _playerState.speed,
        volume: _playerState.volume,
      ));
    }
  }

  bool _isRestoreCancelled(int restoreGeneration) {
    return _userInitiatedPlayback || restoreGeneration != _restoreGeneration;
  }

  Future<void> playEpisode(Episode episode, {Duration? startPosition}) async {
    Logger.info('🎵 [PLAYBACK] playEpisode called: ${episode.title} (id: ${episode.id})');
    Logger.info('🎵 [PLAYBACK] _currentEpisodeId: $_currentEpisodeId, episode.id: ${episode.id}');

    _userInitiatedPlayback = true;
    _restoreGeneration++;
    
    if (_currentEpisodeId != null && _currentEpisodeId != episode.id) {
      Logger.info('🎵 [PLAYBACK] Different episode, saving current progress...');
      await _saveCurrentProgress();
    }

    Logger.info('🎵 [PLAYBACK] Creating play history...');
    await _createOrUpdatePlayHistory(episode);

    _currentEpisodeId = episode.id;
    Logger.info('🎵 [PLAYBACK] _currentEpisodeId updated to: $_currentEpisodeId');

    Logger.info('🎵 [PLAYBACK] Calling AudioPlayerService.playEpisode...');
    await _audioPlayerService.playEpisode(
      episode,
      startPosition: startPosition,
    );
    Logger.info('🎵 [PLAYBACK] AudioPlayerService.playEpisode completed');
  }

  Future<void> play() async {
    await _audioPlayerService.play();
  }

  Future<void> pause() async {
    await _audioPlayerService.pause();
    await _saveCurrentProgress();
    _requestSync();
  }

  Future<void> togglePlayPause() async {
    final wasPlaying = state.isPlaying;
    await _audioPlayerService.togglePlayPause();
    if (wasPlaying) {
      await _saveCurrentProgress();
      _requestSync();
    }
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

    final durationMs = state.duration.inMilliseconds;
    if (durationMs <= 0) return;

    final positionMs = state.currentPosition.inMilliseconds;
    final remainingMs = durationMs - positionMs;
    if (remainingMs < 0) return;

    final progressRatio = positionMs / durationMs;

    const shortEpisodeThreshold = 5 * 60 * 1000; // 5 分钟
    const longEpisodeRemainingThreshold = 60 * 1000; // 60 秒

    final bool isCompleted;
    final String reason;

    if (durationMs <= shortEpisodeThreshold) {
      final shortProgressThreshold = 0.95;
      isCompleted = progressRatio >= shortProgressThreshold;
      reason = 'Short episode (${durationMs ~/ 1000}s), progress ${((progressRatio) * 100).toStringAsFixed(1)}% >= 95%';
    } else {
      isCompleted = remainingMs <= longEpisodeRemainingThreshold;
      reason = 'Long episode (${durationMs ~/ 1000}s), remaining ${remainingMs ~/ 1000}s <= 60s';
    }

    if (!isCompleted) return;

    Logger.info('🎯 [Playback] $reason, marking as completed');

    try {
      await _playProgressService.markEpisodeAsPlayed(
        episodeId: currentEpisode.id,
        episodeGuid: currentEpisode.guid,
        episodeITunesId: currentEpisode.itunesId,
        podcastGuid: null,
        podcastITunesId: currentEpisode.podcastITunesId,
      );

      Logger.info('🔄 [Playback] Auto-refreshing History list...');
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
  return ref.watch(playbackProvider.select((s) => s.currentEpisode));
});

final isPlayingProvider = Provider<bool>((ref) {
  return ref.watch(playbackProvider.select((s) => s.isPlaying));
});

final currentPositionProvider = Provider<Duration>((ref) {
  return ref.watch(playbackProvider.select((s) => s.currentPosition));
});

final durationProvider = Provider<Duration>((ref) {
  return ref.watch(playbackProvider.select((s) => s.duration));
});

final speedProvider = Provider<double>((ref) {
  return ref.watch(playbackProvider.select((s) => s.speed));
});

final volumeProvider = Provider<double>((ref) {
  return ref.watch(playbackProvider.select((s) => s.volume));
});

final progressRatioProvider = Provider<double>((ref) {
  return ref.watch(playbackProvider.select((s) => s.progressRatio));
});
