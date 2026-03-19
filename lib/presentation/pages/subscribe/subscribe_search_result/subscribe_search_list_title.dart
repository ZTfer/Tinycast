import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';

class SubscribeSearchListTitle extends ConsumerWidget {
  const SubscribeSearchListTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastState = ref.watch(podcastProvider);
    final podcasts = podcastState.podcasts ?? [];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '已订阅的播客 (${podcasts.length})',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        // Todo：后期变为一个按钮，点击后执行批量关注操作
        Text(
          '全部关注',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
