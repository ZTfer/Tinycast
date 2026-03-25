import 'package:flutter/widgets.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'episode_info.dart';
import 'show_info.dart';
import 'episode_description.dart';

class EpisodeDetail extends StatelessWidget {
  final Episode? episode;
  final Podcast? podcast;

  const EpisodeDetail({
    super.key,
    this.episode,
    this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFFFFFFFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          EpisodeInfo(episode: episode),
          const SizedBox(height: 4),
          ShowInfo(podcast: podcast),
          const SizedBox(height: 4),
          EpisodeDescription(description: episode?.description),
        ],
      ),
    );
  }
}
