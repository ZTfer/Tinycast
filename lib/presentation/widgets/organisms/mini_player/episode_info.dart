import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ArtworkImage(
            artworkUrl: artworkUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            borderRadius: 4,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? '未播放节目',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                    decoration: TextDecoration.none,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  podcastTitle ?? '未知播客',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.normal,
                  ),
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
