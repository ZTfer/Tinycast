import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/features/subscribe/subscribe_search_result/subscribe_search_list.dart';
import 'package:tinycast/presentation/features/subscribe/subscribe_search_result/subscribe_search_list_title.dart';
import 'package:tinycast/presentation/features/subscribe/subscribe_search_result/subscribe_search_result_error.dart';
import 'package:tinycast/presentation/features/search/podcast_search_provider.dart';

class SubscribeSearchResult extends ConsumerWidget {
  const SubscribeSearchResult({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(podcastSearchProvider);

    if (searchState.status == PodcastSearchStatus.loading) {
      return const Center(
        child: SizedBox(
          width: 24.0,
          height: 24.0,
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
      );
    }

    if (searchState.status == PodcastSearchStatus.error) {
      return const SubscribeSearchResultError();
    }

    if (searchState.status == PodcastSearchStatus.success &&
        (searchState.searchResults == null || searchState.searchResults!.isEmpty)) {
      return const SubscribeSearchResultError();
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        const SubscribeSearchListTitle(),
        const SizedBox(height: 12),
        Expanded(child: const SubscribeSearchList()),
      ],
    );
  }
}
