import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tinycast/domain/entities/podcast.dart';

class SubscribeEpisodeInfo extends StatelessWidget {
  /// 播客信息
  final Podcast podcast;

  const SubscribeEpisodeInfo({
    super.key,
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 40,
            height: 40,
            child: CachedNetworkImage(
              imageUrl: podcast.artworkUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 40,
                height: 40,
                color: const Color(0xFFE0E0E0),
                child: const Center(
                  child: Text('Cover', style: TextStyle(fontSize: 8)),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 40,
                height: 40,
                color: const Color(0xFFE0E0E0),
                child: const Center(
                  child: Text('Cover', style: TextStyle(fontSize: 8)),
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
                podcast.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                podcast.description.isNotEmpty ? podcast.description : podcast.author,
                style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
