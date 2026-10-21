import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/presentation/features/queue/queue_empty_page/queue_empty_page.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_item.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';
import 'package:tinycast/presentation/providers/unplayed_episodes_provider.dart';
import 'package:tinycast/presentation/providers/queue_provider.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/presentation/providers/navigation_provider.dart';

/// 待播放队列页面
///
/// 显示用户待播放的节目列表。
/// 包含两个区域：
/// 1. 队列区域 - 用户手动添加到队列的 episodes
/// 2. 继续播放区域 - 未播放的 episodes
/// 每个列表项包含节目封面、文本信息（时间、标题、描述）和操作区域（播放按钮、更多选项）。

class Queue extends ConsumerWidget {
  const Queue({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueEpisodes = ref.watch(queueEpisodesProvider);
    final unplayedEpisodes = ref.watch(unplayedEpisodesProvider);
    final isQueueLoading = ref.watch(queueLoadingProvider);
    final isUnplayedLoading = ref.watch(unplayedEpisodesLoadingProvider);

    if (isQueueLoading || isUnplayedLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (queueEpisodes.isEmpty && unplayedEpisodes.isEmpty) {
      return const QueueEmptyPage();
    }

    final List<Widget> slivers = [];

    if (queueEpisodes.isNotEmpty) {
      slivers.add(_buildSectionTitle('队列'));
      slivers.add(
        SliverList.builder(
          itemCount: queueEpisodes.length,
          itemBuilder: (context, index) {
            final episode = queueEpisodes[index];
            return _buildEpisodeItem(
              ref,
              episode,
              showDivider: index < queueEpisodes.length - 1,
              showRemoveFromQueue: true,
            );
          },
        ),
      );

      if (unplayedEpisodes.isNotEmpty) {
        slivers.add(_buildDivider());
      }
    }

    if (unplayedEpisodes.isNotEmpty) {
      slivers.add(_buildSectionTitle('继续播放'));
      slivers.add(
        SliverList.builder(
          itemCount: unplayedEpisodes.length,
          itemBuilder: (context, index) {
            final episode = unplayedEpisodes[index];
            return _buildEpisodeItem(
              ref,
              episode,
              showDivider: index < unplayedEpisodes.length - 1,
            );
          },
        ),
      );
    }

    return CustomScrollView(slivers: slivers);
  }

  Widget _buildEpisodeItem(
    WidgetRef ref,
    Episode episode, {
    required bool showDivider,
    bool showRemoveFromQueue = false,
  }) {
    return EpisodeItem(
      key: ValueKey(episode.id),
      episode: episode,
      showDivider: showDivider,
      showRemoveFromQueue: showRemoveFromQueue,
      onRemoveFromQueue: showRemoveFromQueue
          ? () async {
              await ref
                  .read(queueNotifierProvider.notifier)
                  .removeFromQueueByEpisodeId(episode);
            }
          : null,
      onPlayPressed: () {
        ref.read(playbackProvider.notifier).playEpisode(episode);
      },
      onEpisodeTap: () async {
        final useCase = ref.read(getPodcastByIdUseCaseProvider);
        final podcast = await useCase(episode.podcastId);
        if (podcast != null) {
          ref
              .read(navigationProvider.notifier)
              .showEpisodeDetail(episode, podcast);
        }
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Color(0xFF888888),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const SliverToBoxAdapter(
      child: SizedBox(
        height: 0.5,
        child: ColoredBox(color: Color(0xFFE0E0E0)),
      ),
    );
  }
}
