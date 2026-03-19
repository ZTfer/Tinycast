import 'package:flutter/widgets.dart';
import 'search_results_success_item.dart';

class SearchResultsSuccessList extends StatelessWidget {
  const SearchResultsSuccessList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder: (context, index) {
        return SearchResultsSuccessItem(
          episodeTitle: '剧集标题$index',
          podcastName: '播客名称$index',
          episodeDescription: '剧集简介$index',
        );
      },
    );
  }
}