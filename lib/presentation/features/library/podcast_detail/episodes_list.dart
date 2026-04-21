import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/utils/toast_utils.dart';
import 'package:tinycast/data/repositories/play_history_repository.dart';
import 'package:tinycast/data/repositories/queue_repository_impl.dart';
import 'package:tinycast/data/services/audio_download_service.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/features/downloads/downloaded_episodes_provider.dart';
import 'package:tinycast/presentation/providers/download_provider.dart';
import 'package:tinycast/presentation/providers/favorite_episodes_provider.dart';
import 'package:tinycast/presentation/providers/navigation_provider.dart';
import 'package:tinycast/presentation/providers/play_history_provider.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/presentation/providers/queue_provider.dart';
import 'package:tinycast/presentation/providers/unplayed_episodes_provider.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_item.dart';
import 'show_info.dart';

class EpisodesList extends ConsumerWidget {
  final Podcast? podcast;
  final List<Episode> episodes;

  const EpisodesList({
    super.key,
    this.podcast,
    required this.episodes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: episodes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ShowInfo(
            title: podcast?.title,
            artworkUrl: podcast?.artworkUrl,
            description: podcast?.description,
            rssUrl: podcast?.rssUrl,
            onViewDetails: () {},
            onCopyLinkSuccess: () {
              if (context.mounted) {
                ToastUtils.showCopySuccessToast(context);
              }
            },
            onRemoveDownloads: () async {
              if (podcast != null) {
                await AudioDownloadService.instance
                    .removeAllDownloadsForPodcast(podcast!.id);
                ref.invalidate(downloadedEpisodesNotifierProvider);
                if (context.mounted) {
                  ToastUtils.showSuccessToast(context, message: '已移除所有下载');
                }
              }
            },
            onUnfollow: () async {
              if (podcast != null) {
                final playHistoryRepo = PlayHistoryRepository();
                await playHistoryRepo.removeByPodcastId(podcast!.id);

                final queueRepo = QueueRepositoryImpl();
                await queueRepo.removeFromQueueByPodcastId(podcast!.id);

                final downloadService = AudioDownloadService.instance;
                await downloadService.unfollowPodcast(podcast!.id);
                await ref
                    .read(podcastProvider.notifier)
                    .unsubscribe(podcast!.id);

                ref.read(queueNotifierProvider.notifier).removeByPodcastId(podcast!.id);
                ref.read(completedHistoriesProvider.notifier).removeByPodcastId(podcast!.id);

                ref.invalidate(queueNotifierProvider);
                ref.invalidate(completedHistoriesProvider);
                ref.invalidate(favoriteEpisodesNotifierProvider);
                ref.invalidate(downloadedEpisodesNotifierProvider);
                ref.invalidate(unplayedEpisodesNotifierProvider);
                ref.invalidate(podcastProvider);
                ref.read(downloadNotifierProvider.notifier).manualRefresh();

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ToastUtils.showSuccessToast(context, message: '已取消关注');
                }
              }
            },
          );
        }

        final episodeIndex = index - 1;
        final episode = episodes[episodeIndex];
        final isLast = episodeIndex == episodes.length - 1;

        return EpisodeItem(
          episode: episode,
          showDivider: !isLast,
          showCover: false,
          onEpisodeTap: () {
            if (podcast != null) {
              ref.read(navigationProvider.notifier).showEpisodeDetail(episode, podcast!);
            }
          },
        );
      },
    );
  }
}
