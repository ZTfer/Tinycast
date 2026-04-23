import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tinycast/domain/entities/episode.dart' as domain;
import 'package:tinycast/data/models/episode_model.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/datasources/local_podcast_datasource.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/data/services/audio_download_service.dart';
import 'package:tinycast/data/services/settings_service.dart';

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
      _audioHandler = await AudioService.init(
        builder: () => _AudioPlayerHandler(_player),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.tinycast.app.audio',
          androidNotificationChannelName: 'Tinycast Audio Playback',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );

      _player.playbackEventStream.listen(_onPlaybackEvent);
      _player.playerStateStream.listen(_onPlayerStateChange);
      _player.positionStream.listen((_) => _updateProgress());

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
  /// 1. 标记当前音频为已播放
  /// 2. 检查自动删除设置，如果需要则删除音频文件
  /// 3. 播放下一个未播放的音频
  Future<void> _onPlaybackCompleted() async {
    if (_currentEpisode == null) return;

    final completedEpisodeId = _currentEpisode!.id;
    Logger.info('播放完成: ${_currentEpisode!.title}');

    // 标记当前音频为已播放
    await _markEpisodeAsPlayed(completedEpisodeId);

    // 检查并自动删除下载的音频文件
    await _handleAutoDeleteDownload(completedEpisodeId);

    // 发送播放完成事件
    if (!_episodeCompletedController.isClosed) {
      _episodeCompletedController.add(completedEpisodeId);
    }

    // 播放下一个未播放的音频
    await _playNextUnplayedEpisode();
  }

  /// 检查设置并在需要时自动删除已播放的下载文件
  Future<void> _handleAutoDeleteDownload(int episodeId) async {
    try {
      Logger.info('🗑️ [AUTO-DELETE] ====== 开始检查自动删除 episodeId: $episodeId ======');

      final removePlayedDownloads = await _getRemovePlayedDownloadsSetting();
      Logger.info('🗑️ [AUTO-DELETE] 设置项 removePlayedDownloads = $removePlayedDownloads');

      if (!removePlayedDownloads) {
        Logger.info('🗑️ [AUTO-DELETE] 自动删除已禁用，跳过');
        return;
      }

      final episode = await _isarService.isar.episodes.get(episodeId);
      Logger.info('🗑️ [AUTO-DELETE] 从数据库读取 episode: isNull=${episode == null}, downloadedPath=${episode?.downloadedPath}, isDownloaded=${episode?.isDownloaded}');

      if (episode == null || !episode.isDownloaded || episode.downloadedPath == null) {
        Logger.info('🗑️ [AUTO-DELETE] episode 未下载或无路径，跳过');
        return;
      }

      Logger.info('🗑️ [AUTO-DELETE] 调用 AudioDownloadService 删除 episodeId: $episodeId');
      await AudioDownloadService.instance.deleteDownloadedEpisode(
        episodeId.toString(),
      );
      Logger.info('🗑️ [AUTO-DELETE] ====== episodeId: $episodeId 自动删除完成 ======');
    } catch (e, stackTrace) {
      Logger.error('🗑️ [AUTO-DELETE] 自动删除失败', error: e, stackTrace: stackTrace);
    }
  }

  Future<bool> _getRemovePlayedDownloadsSetting() async {
    try {
      return await SettingsService.instance.getRemovePlayedDownloads();
    } catch (e) {
      Logger.error('🗑️ [AUTO-DELETE] 读取设置失败', error: e);
      return false;
    }
  }

  /// 标记 episode 为已播放
  Future<void> _markEpisodeAsPlayed(int episodeId) async {
    try {
      await _isarService.isar.writeTxn(() async {
        final episode = await _isarService.isar.episodes.get(episodeId);

        if (episode != null) {
          episode.isPlayed = true;
          episode.playProgress = 1.0;
          episode.updatedAt = DateTime.now();
          await _isarService.isar.episodes.put(episode);
          Logger.info('已标记为已播放: ${episode.title}');
        }
      });
    } catch (e, stackTrace) {
      Logger.error('标记已播放失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 播放下一个未播放的音频
  Future<void> _playNextUnplayedEpisode() async {
    try {
      // 使用 LocalPodcastDataSource 获取所有未播放的 episode
      final localDataSource = LocalPodcastDataSource();
      final unplayedEpisodes = await localDataSource.getUnplayedEpisodes();

      if (unplayedEpisodes.isEmpty) {
        Logger.info('没有更多未播放的音频');
        _currentEpisode = null;
        if (!_currentEpisodeController.isClosed) {
          _currentEpisodeController.add(null);
        }
        return;
      }

      // 播放第一个未播放的 episode
      final nextEpisode = unplayedEpisodes.first;
      final domainEpisode = domain.Episode(
        id: nextEpisode.id,
        podcastId: nextEpisode.podcastId,
        title: nextEpisode.title,
        description: nextEpisode.description,
        link: nextEpisode.link,
        guid: nextEpisode.guid,
        author: nextEpisode.author,
        pubDate: nextEpisode.pubDate,
        audioUrl: nextEpisode.audioUrl,
        audioType: nextEpisode.audioType,
        duration: nextEpisode.duration,
        artworkUrl: nextEpisode.artworkUrl,
        isExplicit: nextEpisode.isExplicit,
        isPlayed: nextEpisode.isPlayed,
        isDownloaded: nextEpisode.isDownloaded,
        downloadedPath: nextEpisode.downloadedPath,
        downloadProgress: nextEpisode.downloadProgress,
        playProgress: nextEpisode.playProgress,
        lastPlayedAt: nextEpisode.lastPlayedAt,
        createdAt: nextEpisode.createdAt,
        updatedAt: nextEpisode.updatedAt,
      );

      Logger.info('自动播放下一个: ${domainEpisode.title}');
      await playEpisode(domainEpisode);
    } catch (e, stackTrace) {
      Logger.error('自动播放下一个失败', error: e, stackTrace: stackTrace);
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
    try {
      final audioPath = episode.downloadedPath ?? episode.audioUrl;
      final action = autoPlay ? 'Playing' : 'Loading';

      Logger.info('$action episode: ${episode.title} from $audioPath');

      if (audioPath.startsWith('http://') || audioPath.startsWith('https://')) {
        await _player.setUrl(audioPath);
      } else {
        final file = File(audioPath);
        if (await file.exists()) {
          await _player.setFilePath(audioPath);
        } else {
          Logger.warning(
            'Local file not found: $audioPath, falling back to remote URL',
          );
          await _player.setUrl(episode.audioUrl);
        }
      }

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
            milliseconds: (playProgress * (episode.duration ?? 0) * 1000).round(),
          );
          await _player.seek(savedPosition);
        }
      }

      if (autoPlay) {
        await _player.play();
      }

      if (updateLastPlayedAt) {
        await _updateEpisodeLastPlayedAt(episode.id);
      }

      await _updateMediaItem(episode);

      Logger.info('${autoPlay ? "Started playing" : "Loaded"} episode: ${episode.title}');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to ${autoPlay ? "play" : "load"} episode: ${episode.title}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
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
    if (_currentEpisode == null) return;

    final duration = _player.duration?.inSeconds ?? 0;
    if (duration == 0) return;

    final position = _player.position.inSeconds;
    final progress = position / duration;

    try {
      await _isarService.isar.writeTxn(() async {
        final episode = await _isarService.isar.episodes.get(
          _currentEpisode!.id,
        );

        if (episode != null) {
          episode.playProgress = progress;
          episode.isPlayed = progress >= 0.95;
          episode.updatedAt = DateTime.now();
          await _isarService.isar.episodes.put(episode);
        }
      });

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
      await _player.dispose();
      await _playbackStateController.close();
      await _progressController.close();
      await _speedController.close();
      await _volumeController.close();
      await _currentEpisodeController.close();

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

  _AudioPlayerHandler(this._player) {
    _player.playbackEventStream.listen(_broadcastState);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

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
