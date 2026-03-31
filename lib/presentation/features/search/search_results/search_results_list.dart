import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../search_provider.dart';
import '../../../providers/navigation_provider.dart';
import 'search_results_show/search_results_show_item.dart';
import 'search_results_episode/search_results_episode_item.dart';

class SearchResultsList extends ConsumerWidget {
  const SearchResultsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResult = ref.watch(searchResultsProvider);
    final selectedIndex = ref.watch(selectedIndexProvider);

    if (searchResult == null || searchResult.isEmpty) {
      return const SizedBox.shrink();
    }

    final podcasts = searchResult.podcasts;
    final episodes = searchResult.episodes;
    final podcastsCount = podcasts.length;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: podcastsCount + episodes.length,
      itemBuilder: (context, index) {
        if (index < podcastsCount) {
          final podcast = podcasts[index];
          return SearchResultsShowItem(
            podcastName: podcast.title,
            podcastDescription: podcast.description,
            podcastId: podcast.id.toString(),
            isSelected: index == selectedIndex,
            onHover: (isHovering) {
              if (isHovering && index != selectedIndex) {
                ref.read(searchProvider.notifier).setSelectedIndex(index);
              }
            },
            onPressed: () {
              ref.read(navigationProvider.notifier).showPodcastDetail(podcast);
            },
          );
        } else {
          final episodeIndex = index - podcastsCount;
          final episode = episodes[episodeIndex];
          final podcast = podcasts.where((p) => p.id == episode.podcastId).firstOrNull;
          return SearchResultsEpisodeItem(
            episodeTitle: episode.title,
            podcastName: podcast?.title ?? '',
            episodeDescription: episode.description,
            episodeId: episode.id.toString(),
            podcastId: episode.podcastId.toString(),
            isSelected: index == selectedIndex,
            onHover: (isHovering) {
              if (isHovering && index != selectedIndex) {
                ref.read(searchProvider.notifier).setSelectedIndex(index);
              }
            },
            onPressed: () {
              if (podcast != null) {
                ref.read(navigationProvider.notifier).showEpisodeDetail(episode, podcast);
              }
            },
          );
        }
      },
    );
  }
}
