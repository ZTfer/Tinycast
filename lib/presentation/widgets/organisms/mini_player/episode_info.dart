import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

    final podcastTitle = podcastAsync?.hasValue == true
        ? podcastAsync!.value?.title
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 40,
              height: 40,
              child: ArtworkImage(
                artworkUrl: artworkUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: _buildPlaceholder(),
                errorWidget: _buildPlaceholder(),
              ),
            ),
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

  /// 构建占位图
  Widget _buildPlaceholder() {
    return SvgPicture.asset(
      'assets/images/image_placeholder.svg',
      width: 40,
      height: 40,
      fit: BoxFit.cover,
    );
  }
}
