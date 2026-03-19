import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/pages/subscribe/subscribe_search_result/subscribe_search_list_item.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';

class SubscribeSearchList extends ConsumerWidget {
  const SubscribeSearchList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastState = ref.watch(podcastProvider);
    final podcasts = podcastState.podcasts ?? [];

    if (podcastState.status == PodcastStatus.loading) {
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
          '暂无订阅的播客',
          style: TextStyle(
            fontSize: 14.0,
            color: Color(0x80000000),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: podcasts.length,
      itemBuilder: (context, index) {
        final podcast = podcasts[index];
        return SubscribeSearchListItem(
          title: podcast.title,
          podcastName: podcast.author ?? '未知作者',
          onAddPressed: () {
            // 这里可以添加取消订阅的逻辑
            // 目前暂时不做处理
          },
        );
      },
    );
  }
}