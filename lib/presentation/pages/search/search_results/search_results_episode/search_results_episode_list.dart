import 'package:flutter/widgets.dart';
import 'search_results_episode_item.dart';

class SearchResultsEpisodeList extends StatelessWidget {
  const SearchResultsEpisodeList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder: (context, index) {
        return SearchResultsEpisodeItem(
          episodeTitle: '剧集标题$index',
          podcastName: '播客名称$index',
          episodeDescription: '剧集简介$index',
        );
      },
    );
  }
}