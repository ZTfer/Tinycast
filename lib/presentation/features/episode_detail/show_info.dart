import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          Expanded(
            child: Text(
              podcast?.title ?? '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Color(0xFF999999),
                height: 16 / 12,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(LucideIcons.chevronRight, size: 12),
        ],
      ),
    );
  }

  Widget _buildArtwork() {
    final artworkUrl = podcast?.artworkUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 24,
        height: 24,
        child: ArtworkImage(
          artworkUrl: artworkUrl,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          placeholder: _buildPlaceholder(),
          errorWidget: _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return SvgPicture.asset(
      'assets/images/image_placeholder.svg',
      width: 24,
      height: 24,
    );
  }
}
