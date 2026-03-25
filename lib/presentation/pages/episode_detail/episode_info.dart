import 'package:flutter/widgets.dart';
import 'package:tinycast/core/utils/time_formatter.dart';
import 'package:tinycast/domain/entities/episode.dart';

class EpisodeInfo extends StatelessWidget {
  final Episode? episode;

  const EpisodeInfo({
    super.key,
    this.episode,
  });

  @override
  Widget build(BuildContext context) {
    final timeAgo = episode != null
        ? TimeFormatter.formatTimeAgo(episode!.pubDate)
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          timeAgo,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Color(0xFF999999),
            height: 16 / 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          episode?.title ?? '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 24 / 16,
          ),
        ),
      ],
    );
  }
}
