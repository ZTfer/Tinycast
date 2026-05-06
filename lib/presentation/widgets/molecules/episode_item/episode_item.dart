import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/presentation/widgets/atoms/artwork_image/artwork_image.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_info.dart';

class EpisodeItem extends ConsumerWidget {
  final Episode episode;
  final bool showDivider;
  final bool showCover;
  final VoidCallback? onPlayPressed;
  final VoidCallback? onEpisodeTap;
  final bool showRemoveFromQueue;
  final VoidCallback? onRemoveFromQueue;
  final bool usePodcastArtwork;

  const EpisodeItem({
    super.key,
    required this.episode,
    this.showDivider = true,
    this.showCover = true,
    this.onPlayPressed,
    this.onEpisodeTap,
    this.showRemoveFromQueue = false,
    this.onRemoveFromQueue,
    this.usePodcastArtwork = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showCover) ...[
                    _buildArtwork(context, ref),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: EpisodeInfo(
                      episode: episode,
                      duration: _formatDuration(episode.duration),
                      onPlayPressed: onPlayPressed,
                      onTap: onEpisodeTap,
                      showRemoveFromQueue: showRemoveFromQueue,
                      onRemoveFromQueue: onRemoveFromQueue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (showDivider) _buildDivider(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArtwork(BuildContext context, WidgetRef ref) {
    if (usePodcastArtwork) {
      final podcastState = ref.watch(podcastByIdProvider(episode.podcastId));
      return podcastState.when(
        data: (podcast) {
          if (podcast == null) {
            return _buildEpisodeArtwork();
          }
          return ArtworkImage.fromPodcast(
            podcast,
            width: 34,
            height: 34,
            fit: BoxFit.cover,
            borderRadius: 6,
          );
        },
        loading: () => ArtworkImage.buildPlaceholder(
          width: 34,
          height: 34,
          borderRadius: 6,
        ),
        error: (_, _) => ArtworkImage.buildPlaceholder(
          width: 34,
          height: 34,
          borderRadius: 6,
        ),
      );
    } else {
      return _buildEpisodeArtwork();
    }
  }

  Widget _buildEpisodeArtwork() {
    return ArtworkImage.fromEpisode(
      episode,
      width: 34,
      height: 34,
      fit: BoxFit.cover,
      borderRadius: 6,
    );
  }

  String _formatDuration(int? durationInSeconds) {
    if (durationInSeconds == null || durationInSeconds <= 0) {
      return '';
    }

    final hours = durationInSeconds ~/ 3600;
    final minutes = (durationInSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours h $minutes min';
    } else {
      return '$minutes min';
    }
  }

  Widget _buildDivider() {
    return Container(height: 0.5, color: const Color(0xFFE0E0E0));
  }
}
