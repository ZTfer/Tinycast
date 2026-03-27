import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/search_provider.dart';
import 'search_input.dart';
import 'search_history/search_history_list.dart';
import 'search_results/search_results_list.dart';
import 'search_results/search_results_empty/search_results_empty.dart';
import 'search_toolbar/search_toolbar.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(searchProvider.notifier).loadSearchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchStateProvider);
    final showToolbar = ref.watch(showToolbarProvider);

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
        spacing: 8.0,
        children: [
          const SearchInput(),
          ..._buildContent(searchState.status),
          if (showToolbar) const SearchToolbar(),
        ],
      ),
    );
  }

  List<Widget> _buildContent(SearchStatus status) {
    switch (status) {
      case SearchStatus.initial:
        return [];
      case SearchStatus.history:
        return [const Flexible(child: SearchHistoryList())];
      case SearchStatus.results:
        return [const Flexible(child: SearchResultsList())];
      case SearchStatus.empty:
        return [const Flexible(child: SearchResultsEmpty())];
    }
  }
}
