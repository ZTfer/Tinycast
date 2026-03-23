import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class EpisodeInfo extends StatelessWidget {
  final String? title;
  final String? artworkUrl;
  final String? podcastTitle;

  const EpisodeInfo({
    super.key,
    this.title,
    this.artworkUrl,
    this.podcastTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 40,
              height: 40,
              color: const Color(0xFFE0E0E0),
              child: artworkUrl != null
                  ? CachedNetworkImage(
                      imageUrl: artworkUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Text(
                          'Cover',
                          style: TextStyle(
                            fontSize: 8,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text(
                        'Cover',
                        style: TextStyle(
                          fontSize: 8,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
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
}
