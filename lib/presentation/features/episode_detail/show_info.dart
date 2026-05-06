import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/providers/navigation_provider.dart';
import 'package:tinycast/presentation/widgets/atoms/artwork_image/artwork_image.dart';

class ShowInfo extends ConsumerWidget {
  final Podcast? podcast;

  const ShowInfo({super.key, this.podcast});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (podcast != null) {
          ref.read(navigationProvider.notifier).showPodcastDetail(podcast!);
        }
      },
      child: Row(
        children: [
          _buildArtwork(),
          const SizedBox(width: 4),
          Text(
            podcast?.title ?? '',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Color(0xFF999999),
              height: 16 / 12,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(LucideIcons.chevronRight, size: 12),
        ],
      ),
    );
  }

  Widget _buildArtwork() {
    if (podcast != null) {
      return ArtworkImage.fromPodcast(
        podcast!,
        width: 24,
        height: 24,
        fit: BoxFit.cover,
        borderRadius: 4,
      );
    }
    return ArtworkImage.buildPlaceholder(width: 24, height: 24, borderRadius: 4);
  }
}
