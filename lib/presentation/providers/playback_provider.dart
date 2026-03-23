import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    this.volume = 1.0,
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

  @override
  PlayerState build() {
    _initListeners();
    ref.onDispose(_disposeListeners);
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

  Future<void> playEpisode(Episode episode, {Duration? startPosition}) async {
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
