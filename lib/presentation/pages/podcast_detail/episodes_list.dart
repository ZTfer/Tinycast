import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_item.dart';
import 'package:tinycast/presentation/providers/navigation_provider.dart';
import 'show_info.dart';

class EpisodesList extends ConsumerWidget {
  final Podcast? podcast;
  final List<Episode> episodes;

  const EpisodesList({
    super.key,
    this.podcast,
    required this.episodes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: episodes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ShowInfo(
            title: podcast?.title,
            artworkUrl: podcast?.artworkUrl,
            description: podcast?.description,
          );
        }

        final episodeIndex = index - 1;
        final episode = episodes[episodeIndex];
        final isLast = episodeIndex == episodes.length - 1;

        return EpisodeItem(
          episode: episode,
          showDivider: !isLast,
          showCover: false,
          onEpisodeTap: () {
            if (podcast != null) {
              ref.read(navigationProvider.notifier).showEpisodeDetail(episode, podcast!);
            }
          },
        );
      },
    );
  }
}
