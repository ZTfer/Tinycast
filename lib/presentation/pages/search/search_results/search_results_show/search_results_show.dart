import 'package:flutter/widgets.dart';
import 'search_results_show_item.dart';

class SearchResultsPodcastList extends StatelessWidget {
  const SearchResultsPodcastList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder: (context, index) {
        return SearchResultsShowItem(
          podcastName: '节目名称$index',
          podcastDescription: '节目简介$index',
        );
      },
    );
  }
}