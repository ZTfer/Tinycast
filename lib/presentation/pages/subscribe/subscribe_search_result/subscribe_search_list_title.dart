import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/providers/podcast_search_provider.dart';
import 'package:tinycast/presentation/pages/subscribe/subscribe_search_result/batch_add_button.dart';

class SubscribeSearchListTitle extends ConsumerWidget {
  const SubscribeSearchListTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(podcastSearchProvider);
    final podcasts = searchState.searchResults ?? [];
    final addingStatus = searchState.addingStatus;
    final isAnyAdding = addingStatus.values.any((isAdding) => isAdding);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '搜索结果 (${podcasts.length})',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        BatchAddButton(
          label: '全部关注',
          onPressed: isAnyAdding ? () {} : () {
            ref.read(podcastSearchProvider.notifier).addAllPodcasts();
          },
        ),
      ],
    );
  }
}
