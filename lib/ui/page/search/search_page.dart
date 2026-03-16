import 'package:flutter/material.dart';
import 'search_toolbar/search_toolbar.dart';
// import 'search_history/search_history_list.dart';
import 'search_results/search_results_success/search_results_success_list.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      constraints: const BoxConstraints(maxHeight: 400),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.5,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //Todo: 有搜索记录时展示搜索记录，没有时不展示
          // Flexible(child: SearchHistoryList()),
          //Todo: 有搜索结果时展示搜索结果，没有时不展示
          Flexible(child: SearchResultsSuccessList()),
          SearchToolbar(),
        ],
      ),
    );
  }
}
