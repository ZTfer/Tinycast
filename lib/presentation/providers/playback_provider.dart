import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/models/episode_model.dart' as episode_model;
import 'package:tinycast/data/models/play_history_model.dart';
import 'package:tinycast/data/repositories/play_history_repository.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/data/services/audio_player_service.dart';

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

    ref.onDispose(() {
      _disposeListeners();
      _disposeAutoSave();
      _saveCurrentProgress();
    });
    return PlayerState();
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
  }

  void _disposeListeners() {
    _playbackStateSubscription?.cancel();
    _progressSubscription?.cancel();
    _speedSubscription?.cancel();
    _volumeSubscription?.cancel();
    _currentEpisodeSubscription?.cancel();
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

    final timeCondition = _lastSaveTime == null ||
        now.difference(_lastSaveTime!).inSeconds >= 10;

    final progressDelta = (positionMs - _lastSavedPositionMs).abs();
    final durationMs = state.duration.inMilliseconds;
    final progressCondition = durationMs > 0 &&
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
      final latestHistory =
          await _playHistoryRepository.getLatestPlayingHistory();

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

      final startPosition = Duration(milliseconds: latestHistory.lastPlayedPositionMs);

      debugPrint('Initializing AudioPlayerService with restored episode...');
      await _audioPlayerService.loadEpisode(
        domainEpisode,
        startPosition: startPosition,
      );

      _currentEpisodeId = domainEpisode.id;
      _lastSavedPositionMs = latestHistory.lastPlayedPositionMs;
      _lastSaveTime = DateTime.now();

      debugPrint('Playback state restored successfully - all controls should work');
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
    Duration duration = const Duration(seconds: 30),
  }) async {
    await _audioPlayerService.seekForward(duration: duration);
  }

  Future<void> seekBackward({
    Duration duration = const Duration(seconds: 30),
  }) async {
    await _audioPlayerService.seekBackward(duration: duration);
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayerService.seek(position);
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
        await _playHistoryRepository.markAsCompleted(currentEpisode.id);
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
