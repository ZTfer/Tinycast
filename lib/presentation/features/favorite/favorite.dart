import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/features/favorite/favorite_empty_page/favorite_empty_page.dart';
import 'package:tinycast/presentation/features/favorite/favorite_episodes_provider.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_item.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/presentation/providers/navigation_provider.dart';

/// 收藏页面
///
/// 显示用户收藏的节目列表。
/// 每个列表项包含节目封面、文本信息（时间、标题、描述）和操作区域（播放按钮、更多选项）。

class Favorite extends ConsumerWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodes = ref.watch(favoriteEpisodesProvider);
    final isLoading = ref.watch(favoriteEpisodesLoadingProvider);

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
      return const FavoriteEmptyPage();
    }

    return ListView.builder(
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        final episode = episodes[index];
        final isLast = index == episodes.length - 1;

        return EpisodeItem(
          episode: episode,
          showDivider: !isLast,
          onPlayPressed: () {
            ref.read(playbackProvider.notifier).playEpisode(episode);
          },
          onEpisodeTap: () async {
            final useCase = ref.read(getPodcastByIdUseCaseProvider);
            final podcast = await useCase(episode.podcastId);
            if (podcast != null) {
              ref.read(navigationProvider.notifier).showEpisodeDetail(episode, podcast);
            }
          },
        );
      },
    );
  }
}
