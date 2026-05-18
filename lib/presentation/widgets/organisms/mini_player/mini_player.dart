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
    final playerState = ref.watch(playbackProvider);
    final episode = playerState.currentEpisode;
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
          EpisodeControlBar(
            isPlaying: playerState.isPlaying,
            onPlayPause: () =>
                ref.read(playbackProvider.notifier).togglePlayPause(),
            onSeekForward: () =>
                ref.read(playbackProvider.notifier).seekForward(),
            onSeekBackward: () =>
                ref.read(playbackProvider.notifier).seekBackward(),
          ),
          EpisodeProgress(
            position: playerState.currentPosition,
            duration: playerState.duration,
            onSeek: (position) {
              ref.read(playbackProvider.notifier).seekTo(position);
            },
          ),
        ],
      ),
    );
  }
}
