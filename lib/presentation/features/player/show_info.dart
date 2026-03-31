import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShowInfo extends StatelessWidget {
  final Podcast? podcast;

  const ShowInfo({
    super.key,
    this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }

  Widget _buildArtwork() {
    final artworkUrl = podcast?.artworkUrl;

    if (artworkUrl != null && artworkUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: artworkUrl,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildPlaceholder(),
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return SvgPicture.asset(
      'assets/images/image_placeholder.svg',
      width: 24,
      height: 24,
    );
  }
}
