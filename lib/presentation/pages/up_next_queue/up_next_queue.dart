import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/pages/up_next_queue/queue_empty_page/queue_empty_page.dart';
import 'package:tinycast/presentation/pages/up_next_queue/queue_item/queue_item.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';
import 'package:tinycast/presentation/providers/unplayed_episodes_provider.dart';

/// 待播放队列页面
///
/// 显示用户待播放的节目列表。
/// 每个列表项包含节目封面、文本信息（时间、标题、描述）和操作区域（播放按钮、更多选项）。

class UpNextQueue extends ConsumerWidget {
  const UpNextQueue({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodes = ref.watch(unplayedEpisodesProvider);
    final isLoading = ref.watch(unplayedEpisodesLoadingProvider);

    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (episodes.isEmpty) {
      return const QueueEmptyPage();
    }

    return ListView.builder(
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        final episode = episodes[index];
        final isLast = index == episodes.length - 1;

        return QueueItem(
          episode: episode,
          showDivider: !isLast,
          onPlayPressed: () {
            ref.read(playbackProvider.notifier).playEpisode(episode);
          },
        );
      },
    );
  }
}
