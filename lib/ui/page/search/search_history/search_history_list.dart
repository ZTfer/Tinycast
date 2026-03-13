import 'package:flutter/widgets.dart';
import 'search_history_item.dart';

class SearchHistoryList extends StatelessWidget {
  const SearchHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return SearchHistoryItem(historyKeyword: '关键词$index');
      },
    );
  }
}