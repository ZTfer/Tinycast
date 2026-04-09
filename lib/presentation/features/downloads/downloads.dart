import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_item.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';
import 'package:tinycast/presentation/features/downloads/downloaded_episodes_provider.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/presentation/providers/navigation_provider.dart';

class Downloads extends ConsumerWidget {
  const Downloads({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodes = ref.watch(downloadedEpisodesProvider);
    final isLoading = ref.watch(downloadedEpisodesLoadingProvider);

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
      return const Center(
        child: Text('暂无已下载的内容'),
      );
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
