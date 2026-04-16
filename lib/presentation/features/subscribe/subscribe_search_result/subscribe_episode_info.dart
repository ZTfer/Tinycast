import 'package:flutter/widgets.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/widgets/atoms/artwork_image/artwork_image.dart';

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
            child: ArtworkImage(
              artworkUrl: podcast.artworkUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              placeholder: Container(
                width: 40,
                height: 40,
                color: const Color(0xFFE0E0E0),
                child: const Center(
                  child: Text('Cover', style: TextStyle(fontSize: 8)),
                ),
              ),
              errorWidget: Container(
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
