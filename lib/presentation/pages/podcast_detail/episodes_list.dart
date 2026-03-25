import 'package:flutter/widgets.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_item.dart';

class EpisodesList extends StatelessWidget {
  final List<Episode> episodes;

  const EpisodesList({super.key, required this.episodes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        final episode = episodes[index];
        final isLast = index == episodes.length - 1;

        return EpisodeItem(episode: episode, showDivider: !isLast);
      },
    );
  }
}
