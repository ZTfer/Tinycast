import 'package:flutter/widgets.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_item.dart';
import 'show_info.dart';

class EpisodesList extends StatelessWidget {
  final List<Episode> episodes;

  const EpisodesList({super.key, required this.episodes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: episodes.length + 1,
      itemBuilder: (context, index) {
        // 第一项是 ShowInfo
        if (index == 0) {
          return const ShowInfo();
        }

        // 后续是剧集列表
        final episodeIndex = index - 1;
        final episode = episodes[episodeIndex];
        final isLast = episodeIndex == episodes.length - 1;

        return EpisodeItem(episode: episode, showDivider: !isLast);
      },
    );
  }
}
