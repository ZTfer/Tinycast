import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tinycast/domain/entities/episode.dart' as domain;
import 'package:tinycast/data/models/episode_model.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/core/services/play_progress_service.dart';
import 'package:tinycast/core/utils/logger.dart';

enum PlaybackState { stopped, playing, paused, buffering }

class PlaybackProgress {
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;

  PlaybackProgress({
    required this.position,
    required this.duration,
    required this.bufferedPosition,
  });

  double get progressRatio {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }
}

class AudioPlayerService {
  AudioPlayerService._();

  static final AudioPlayerService _instance = AudioPlayerService._();

  static AudioPlayerService get instance => _instance;

  final AudioPlayer _player = AudioPlayer();
  AudioHandler? _audioHandler;
  final List<StreamSubscription> _subscriptions = [];

  // 加载序号守卫：每次加载递增，被更新的加载流程会使旧流程中止，
  // 避免恢复播放与用户主动播放并发操作同一个播放器
  int _loadGeneration = 0;

  final IsarService _isarService = IsarService.instance;

  domain.Episode? _currentEpisode;
  domain.Episode? get currentEpisode => _currentEpisode;

  final StreamController<PlaybackState> _playbackStateController =
      StreamController<PlaybackState>.broadcast();

  final StreamController<PlaybackProgress> _progressController =
      StreamController<PlaybackProgress>.broadcast();

  final StreamController<double> _speedController =
      StreamController<double>.broadcast();

  final StreamController<double> _volumeController =
      StreamController<double>.broadcast();

  final StreamController<domain.Episode?> _currentEpisodeController =
      StreamController<domain.Episode?>.broadcast();

  final StreamController<int> _episodeCompletedController =
      StreamController<int>.broadcast();

  Stream<PlaybackState> get playbackStateStream =>
      _playbackStateController.stream;

  Stream<PlaybackProgress> get progressStream => _progressController.stream;

  Stream<double> get speedStream => _speedController.stream;

  Stream<double> get volumeStream => _volumeController.stream;

  Stream<domain.Episode?> get currentEpisodeStream =>
      _currentEpisodeController.stream;

  Stream<int> get episodeCompletedStream => _episodeCompletedController.stream;

  PlaybackState get currentPlaybackState {
    if (_player.playing) {
      return _player.processingState == ProcessingState.buffering
          ? PlaybackState.buffering
          : PlaybackState.playing;
    } else if (_player.processingState == ProcessingState.idle) {
      return PlaybackState.stopped;
    }
    return PlaybackState.paused;
  }

  double get currentSpeed => _player.speed;

  double get currentVolume => _player.volume;

  Duration get position => _player.position;

  Duration get duration => _player.duration ?? Duration.zero;

  Duration get bufferedPosition => _player.bufferedPosition;

  Future<void> init() async {
    try {
      if (_audioHandler != null) {
        Logger.info('AudioPlayerService already initialized');
        return;
      }

      _audioHandler = await AudioService.init(
        builder: () => _AudioPlayerHandler(_player, _savePlayProgress),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.tinycast.app.audio',
          androidNotificationChannelName: 'Tinycast Audio Playback',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );

      _subscriptions.add(_player.playbackEventStream.listen(_onPlaybackEvent));
      _subscriptions.add(
        _player.playerStateStream.listen(_onPlayerStateChange),
      );
      _subscriptions.add(
        _player.positionStream.listen((_) => _updateProgress()),
      );

      // 设置默认音量为 30%
      await _player.setVolume(0.3);
      _volumeController.add(0.3);

      Logger.info('AudioPlayerService initialized');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to initialize AudioPlayerService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void _onPlaybackEvent(PlaybackEvent event) {
    _updateProgress();
  }

  void _onPlayerStateChange(PlayerState state) {
    _updatePlaybackState();

    // 监听播放完成事件
    if (state.processingState == ProcessingState.completed) {
      _onPlaybackCompleted();
    }
  }

  /// 播放完成后的处理
  /// 只发送播放完成事件，业务逻辑由 PlaybackProvider 处理
  Future<void> _onPlaybackCompleted() async {
    if (_currentEpisode == null) return;

    final completedEpisodeId = _currentEpisode!.id;
    Logger.info('播放完成: ${_currentEpisode!.title}');

    // 只发送播放完成事件，不处理业务逻辑
    if (!_episodeCompletedController.isClosed) {
      _episodeCompletedController.add(completedEpisodeId);
    }
  }

  void _updateProgress() {
    final progress = PlaybackProgress(
      position: _player.position,
      duration: _player.duration ?? Duration.zero,
      bufferedPosition: _player.bufferedPosition,
    );

    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }

  void _updatePlaybackState() {
    PlaybackState state;
    if (_player.playing) {
      state = _player.processingState == ProcessingState.buffering
          ? PlaybackState.buffering
          : PlaybackState.playing;
    } else if (_player.processingState == ProcessingState.idle) {
      state = PlaybackState.stopped;
    } else {
      state = PlaybackState.paused;
    }

    if (!_playbackStateController.isClosed) {
      _playbackStateController.add(state);
    }
  }

  Future<void> _loadEpisodeAudio(
    domain.Episode episode, {
    Duration? startPosition,
    bool autoPlay = true,
    bool updateLastPlayedAt = true,
  }) async {
    final generation = ++_loadGeneration;
    try {
      Logger.info('🎧 [AUDIO] _loadEpisodeAudio called: ${episode.title}');
      Logger.info('🎧 [AUDIO] downloadedPath: ${episode.downloadedPath}');
      Logger.info('🎧 [AUDIO] audioUrl: ${episode.audioUrl}');

      // 先停止当前播放，避免播放器处于错误状态
      try {
        if (_player.playing) {
          await _player.stop();
        }
      } catch (e) {
        Logger.warning('🎧 [AUDIO] Failed to stop player before loading: $e');
      }

      if (_isLoadSuperseded(generation, episode)) return;

      String? localAudioPath;
      if (episode.downloadedPath != null) {
        Logger.info(
          '🎧 [AUDIO] downloadedPath is not null, searching for local file...',
        );
        localAudioPath = await _findLocalAudioPath(episode.downloadedPath!);
        if (localAudioPath != null) {
          Logger.info('🎧 [AUDIO] Found local file: $localAudioPath');
        } else {
          Logger.warning(
            '🎧 [AUDIO] Local file not found, will use remote URL',
          );
        }
      } else {
        Logger.info('🎧 [AUDIO] downloadedPath is null, using remote URL');
      }

      if (_isLoadSuperseded(generation, episode)) return;

      final audioPath = localAudioPath ?? episode.audioUrl;
      final action = autoPlay ? 'Playing' : 'Loading';

      Logger.info('🎧 [AUDIO] $action episode from: $audioPath');

      if (audioPath.startsWith('http://') || audioPath.startsWith('https://')) {
        await _player.setUrl(audioPath);
      } else if (localAudioPath != null) {
        final file = File(localAudioPath);
        if (await file.exists()) {
          Logger.info('🎧 [AUDIO] Local file exists, playing: $localAudioPath');
          try {
            await _player.setFilePath(localAudioPath);
          } catch (e) {
            Logger.warning(
              '🎧 [AUDIO] setFilePath failed, falling back to remote: $e',
            );
            await _player.setUrl(episode.audioUrl);
          }
        } else {
          Logger.warning(
            '🎧 [AUDIO] Local file not found at playback time, '
            'falling back to remote: ${episode.audioUrl}',
          );
          await _player.setUrl(episode.audioUrl);
        }
      } else {
        Logger.error(
          '🎧 [AUDIO] No valid audio path available for episode: ${episode.title}',
        );
        throw Exception('No valid audio path');
      }

      if (_isLoadSuperseded(generation, episode)) return;

      _currentEpisode = episode;
      if (!_currentEpisodeController.isClosed) {
        _currentEpisodeController.add(episode);
      }

      if (startPosition != null) {
        await _player.seek(startPosition);
      } else if (autoPlay) {
        final playProgress = episode.playProgress;
        if (playProgress > 0 && playProgress < 1.0) {
          final savedPosition = Duration(
            milliseconds: (playProgress * (episode.duration ?? 0) * 1000)
                .round(),
          );
          await _player.seek(savedPosition);
        }
      }

      if (_isLoadSuperseded(generation, episode)) return;

      if (autoPlay) {
        await _player.play();
      }

      if (updateLastPlayedAt) {
        await _updateEpisodeLastPlayedAt(episode.id);
      }

      await _updateMediaItem(episode);

      Logger.info(
        '🎧 [AUDIO] ${autoPlay ? "Started playing" : "Loaded"} episode: ${episode.title}',
      );
    } catch (e, stackTrace) {
      // 已被更新的加载流程取代时，不重置播放器，交由新流程接管
      if (_loadGeneration != generation) {
        Logger.info('🎧 [AUDIO] Load superseded after error: ${episode.title}');
        rethrow;
      }
      Logger.error(
        '🎧 [AUDIO] Failed to ${autoPlay ? "play" : "load"} episode: ${episode.title}',
        error: e,
        stackTrace: stackTrace,
      );
      // 加载失败时重置播放器状态
      try {
        await _player.stop();
        _currentEpisode = null;
        if (!_currentEpisodeController.isClosed) {
          _currentEpisodeController.add(null);
        }
      } catch (resetError) {
        Logger.warning(
          '🎧 [AUDIO] Failed to reset player after error: $resetError',
        );
      }
      rethrow;
    }
  }

  /// 判断当前加载流程是否已被更新的加载取代；若是则记录日志并中止
  bool _isLoadSuperseded(int generation, domain.Episode episode) {
    if (_loadGeneration == generation) return false;
    Logger.info('🎧 [AUDIO] Load superseded, aborting: ${episode.title}');
    return true;
  }

  Future<void> playEpisode(
    domain.Episode episode, {
    Duration? startPosition,
  }) async {
    await _loadEpisodeAudio(
      episode,
      startPosition: startPosition,
      autoPlay: true,
      updateLastPlayedAt: true,
    );
  }

  Future<void> loadEpisode(
    domain.Episode episode, {
    Duration? startPosition,
  }) async {
    await _loadEpisodeAudio(
      episode,
      startPosition: startPosition,
      autoPlay: false,
      updateLastPlayedAt: false,
    );
  }

  Future<void> _updateMediaItem(domain.Episode episode) async {
    if (_audioHandler == null) return;

    final mediaItem = MediaItem(
      id: episode.id.toString(),
      title: episode.title,
      artist: episode.author ?? 'Unknown',
      album: '',
      artUri: episode.artworkUrl != null
          ? Uri.parse(episode.artworkUrl!)
          : null,
      duration: episode.duration != null
          ? Duration(seconds: episode.duration!)
          : null,
    );

    await _audioHandler!.updateMediaItem(mediaItem);
  }

  Future<void> play() async {
    try {
      await _player.play();
      Logger.info('Playback resumed');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to resume playback',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
      await _savePlayProgress();
      Logger.info('Playback paused');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to pause playback',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
      await _savePlayProgress();
      Logger.info('Seeked to position: ${position.inSeconds}s');
    } catch (e, stackTrace) {
      Logger.error('Failed to seek', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> seekForward({
    Duration duration = const Duration(seconds: 30),
  }) async {
    final newPosition = _player.position + duration;
    final maxPosition = _player.duration ?? Duration.zero;

    if (newPosition > maxPosition) {
      await seek(maxPosition);
    } else {
      await seek(newPosition);
    }

    Logger.info('Seeked forward ${duration.inSeconds}s');
  }

  Future<void> seekBackward({
    Duration duration = const Duration(seconds: 30),
  }) async {
    final newPosition = _player.position - duration;

    if (newPosition < Duration.zero) {
      await seek(Duration.zero);
    } else {
      await seek(newPosition);
    }

    Logger.info('Seeked backward ${duration.inSeconds}s');
  }

  Future<void> setSpeed(double speed) async {
    try {
      await _player.setSpeed(speed);

      if (!_speedController.isClosed) {
        _speedController.add(speed);
      }

      Logger.info('Playback speed set to: ${speed}x');
    } catch (e, stackTrace) {
      Logger.error('Failed to set speed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));

      if (!_volumeController.isClosed) {
        _volumeController.add(volume);
      }

      Logger.info('Volume set to: ${(volume * 100).round()}%');
    } catch (e, stackTrace) {
      Logger.error('Failed to set volume', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      await _savePlayProgress();
      await _player.stop();

      _currentEpisode = null;
      if (!_currentEpisodeController.isClosed) {
        _currentEpisodeController.add(null);
      }

      Logger.info('Playback stopped');
    } catch (e, stackTrace) {
      Logger.error('Failed to stop playback', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _savePlayProgress() async {
    final episode = _currentEpisode;
    if (episode == null) return;

    final durationMs = _player.duration?.inMilliseconds ?? 0;
    if (durationMs == 0) return;

    final positionMs = _player.position.inMilliseconds;
    final progress = positionMs / durationMs;

    try {
      await PlayProgressService.instance.updatePlayProgress(
        episodeId: episode.id,
        positionMs: positionMs,
        progressRatio: progress,
        episodeGuid: episode.guid,
        episodeITunesId: episode.itunesId,
      );

      if (progress >= 0.95) {
        await PlayProgressService.instance.markEpisodeAsPlayed(
          episodeId: episode.id,
          episodeGuid: episode.guid,
          episodeITunesId: episode.itunesId,
          podcastITunesId: episode.podcastITunesId,
        );
      }

      Logger.info(
        'Play progress saved: ${(progress * 100).toStringAsFixed(1)}%',
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to save play progress',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<String?> _findLocalAudioPath(String relativePath) async {
    // 优先检查应用支持目录（当前标准路径）
    try {
      final supportDir = await getApplicationSupportDirectory();
      final primaryPath = '${supportDir.path}/$relativePath';
      final primaryFile = File(primaryPath);
      if (await primaryFile.exists()) {
        Logger.info('Found in support directory: $primaryPath');
        return primaryPath;
      }
    } catch (e) {
      Logger.warning('Failed to check support directory: $e');
    }

    // 回退到文档目录（兼容旧版本下载的文件）
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final fallbackPath = '${docsDir.path}/$relativePath';
      final fallbackFile = File(fallbackPath);
      if (await fallbackFile.exists()) {
        Logger.info('Found in documents directory (legacy): $fallbackPath');
        return fallbackPath;
      }
    } catch (e) {
      Logger.warning('Failed to check documents directory: $e');
    }

    Logger.warning(
      'Local audio file not found in any directory: $relativePath',
    );
    return null;
  }

  Future<void> _updateEpisodeLastPlayedAt(int episodeId) async {
    try {
      await _isarService.isar.writeTxn(() async {
        final episode = await _isarService.isar.episodes.get(episodeId);

        if (episode != null) {
          episode.lastPlayedAt = DateTime.now();
          episode.updatedAt = DateTime.now();
          await _isarService.isar.episodes.put(episode);
        }
      });
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to update lastPlayedAt',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> dispose() async {
    try {
      await _savePlayProgress();
      for (final subscription in _subscriptions) {
        await subscription.cancel();
      }
      _subscriptions.clear();
      await _player.dispose();
      await _playbackStateController.close();
      await _progressController.close();
      await _speedController.close();
      await _volumeController.close();
      await _currentEpisodeController.close();
      await _episodeCompletedController.close();

      Logger.info('AudioPlayerService disposed');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to dispose AudioPlayerService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}

class _AudioPlayerHandler extends BaseAudioHandler {
  final AudioPlayer _player;
  final Future<void> Function() _onPauseOrSeek;

  _AudioPlayerHandler(this._player, this._onPauseOrSeek) {
    _player.playbackEventStream.listen(_broadcastState);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() async {
    await _player.pause();
    await _onPauseOrSeek();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    await _onPauseOrSeek();
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.rewind,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.fastForward,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.setSpeed,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ),
    );
  }
}
