import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/theme/app_theme.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/presentation/widgets/atoms/artwork_image/artwork_image.dart';

class EpisodeInfo extends ConsumerWidget {
  final String? title;
  final String? artworkUrl;
  final int? podcastId;

  const EpisodeInfo({super.key, this.title, this.artworkUrl, this.podcastId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastAsync = podcastId != null
        ? ref.watch(podcastByIdProvider(podcastId!))
        : null;

    final podcastTitle = switch (podcastAsync) {
      AsyncLoading() => null,
      AsyncError() => null,
      AsyncValue<Podcast?>(:final value) when value != null => value.title,
      _ => null,
    };

    final theme = AppTheme.fromBrightness(
      MediaQuery.platformBrightnessOf(context),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ArtworkImage(
            artworkUrl: artworkUrl,
            width: theme.episodeInfoCoverWidth,
            height: theme.episodeInfoCoverHeight,
            fit: theme.episodeInfoCoverFit,
            borderRadius: theme.episodeInfoCoverBorderRadius,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? '未播放节目',
                  style: theme.episodeInfoEpisodeTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  podcastTitle ?? '未知播客',
                  style: theme.episodeInfoPodcastTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
