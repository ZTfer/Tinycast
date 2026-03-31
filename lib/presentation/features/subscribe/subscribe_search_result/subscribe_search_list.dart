import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/features/subscribe/subscribe_search_result/subscribe_search_list_item.dart';
import 'package:tinycast/presentation/features/search/podcast_search_provider.dart';

class SubscribeSearchList extends ConsumerWidget {
  const SubscribeSearchList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(podcastSearchProvider);
    final podcasts = searchState.searchResults ?? [];

    if (searchState.status == PodcastSearchStatus.loading) {
      return const Center(
        child: SizedBox(
          width: 24.0,
          height: 24.0,
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
      );
    }

    if (podcasts.isEmpty) {
      return const Center(
        child: Text(
          '暂无搜索结果',
          style: TextStyle(fontSize: 14.0, color: Color(0x80000000)),
        ),
      );
    }

    return ListView.builder(
      itemCount: podcasts.length,
      itemBuilder: (context, index) {
        final podcast = podcasts[index];
        return SubscribeSearchListItem(
          podcast: podcast,
          onAddPressed: () {
            ref.read(podcastSearchProvider.notifier).addPodcast(podcast);
          },
        );
      },
    );
  }
}
