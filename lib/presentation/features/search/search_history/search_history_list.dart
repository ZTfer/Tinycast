import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/features/search/search_provider.dart';
import 'package:tinycast/presentation/features/search/search_history/search_history_item.dart';

class SearchHistoryList extends ConsumerWidget {
  const SearchHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchHistory = ref.watch(searchHistoryProvider);
    final selectedIndex = ref.watch(selectedIndexProvider);

    if (searchHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      shrinkWrap: true,
      itemCount: searchHistory.length,
      itemBuilder: (context, index) {
        final history = searchHistory[index];
        return SearchHistoryItem(
          historyKeyword: history.keyword,
          isSelected: index == selectedIndex,
          onHover: () {
            if (index != selectedIndex) {
              ref.read(searchProvider.notifier).setSelectedIndex(index);
            }
          },
          onPressed: () {
            ref.read(searchProvider.notifier).search(history.keyword);
          },
        );
      },
    );
  }
}
