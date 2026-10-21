import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/theme/app_theme.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';
import 'package:tinycast/presentation/widgets/organisms/mini_player/episode_control_bar/episode_control_bar.dart';
import 'package:tinycast/presentation/widgets/organisms/mini_player/episode_info.dart';
import 'package:tinycast/presentation/widgets/organisms/mini_player/episode_progress.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episode = ref.watch(currentEpisodeProvider);
    final theme = AppTheme.fromBrightness(
      MediaQuery.platformBrightnessOf(context),
    );

    return Container(
      decoration: BoxDecoration(color: theme.miniPlayerBackground),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: theme.miniPlayerPadding,
            child: EpisodeInfo(
              title: episode?.title,
              artworkUrl: episode?.artworkUrl,
              podcastId: episode?.podcastId,
            ),
          ),
          const _PlaybackControls(),
          const _PlaybackProgress(),
        ],
      ),
    );
  }
}

/// 只订阅播放状态，避免进度更新时重建控制栏。
class _PlaybackControls extends ConsumerWidget {
  const _PlaybackControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(isPlayingProvider);
    return EpisodeControlBar(
      isPlaying: isPlaying,
      onPlayPause: () => ref.read(playbackProvider.notifier).togglePlayPause(),
      onSeekForward: () => ref.read(playbackProvider.notifier).seekForward(),
      onSeekBackward: () =>
          ref.read(playbackProvider.notifier).seekBackward(),
    );
  }
}

/// 只订阅进度与时长，播放进度更新时仅重建进度条。
class _PlaybackProgress extends ConsumerWidget {
  const _PlaybackProgress();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(currentPositionProvider);
    final duration = ref.watch(durationProvider);
    return EpisodeProgress(
      position: position,
      duration: duration,
      onSeek: (position) {
        ref.read(playbackProvider.notifier).seekTo(position);
      },
    );
  }
}
