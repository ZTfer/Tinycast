import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/utils/logger.dart';
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
import 'package:tinycast/presentation/providers/playback_provider.dart';
import 'package:tinycast/presentation/providers/play_history_provider.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/presentation/providers/queue_provider.dart';
import 'package:tinycast/presentation/providers/unplayed_episodes_provider.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_item.dart';
import 'show_info.dart';

class EpisodesList extends ConsumerWidget {
  final Podcast? podcast;
  final List<Episode> episodes;

  const EpisodesList({super.key, this.podcast, required this.episodes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: episodes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _ShowInfoWithDownloadStatus(podcast: podcast);
        }

        final episodeIndex = index - 1;
        final episode = episodes[episodeIndex];
        final isLast = episodeIndex == episodes.length - 1;

        return EpisodeItem(
          episode: episode,
          showDivider: !isLast,
          showCover: false,
          onPlayPressed: () {
            ref.read(playbackProvider.notifier).playEpisode(episode);
          },
          onEpisodeTap: () {
            if (podcast != null) {
              ref
                  .read(navigationProvider.notifier)
                  .showEpisodeDetail(episode, podcast!);
            }
          },
        );
      },
    );
  }
}

class _ShowInfoWithDownloadStatus extends ConsumerStatefulWidget {
  final Podcast? podcast;

  const _ShowInfoWithDownloadStatus({required this.podcast});

  @override
  ConsumerState<_ShowInfoWithDownloadStatus> createState() =>
      _ShowInfoWithDownloadStatusState();
}

class _ShowInfoWithDownloadStatusState
    extends ConsumerState<_ShowInfoWithDownloadStatus> {
  bool _hasDownloads = false;

  @override
  void initState() {
    super.initState();
    _checkDownloads();
  }

  Future<void> _checkDownloads() async {
    if (widget.podcast != null) {
      final hasDownloads = await AudioDownloadService.instance
          .hasDownloadedEpisodesForPodcast(widget.podcast!.id);
      if (mounted) {
        setState(() => _hasDownloads = hasDownloads);
      }
    }
  }

  Future<void> _handleRemoveDownloads() async {
    final podcast = widget.podcast;
    if (podcast == null) return;

    await AudioDownloadService.instance.removeAllDownloadsForPodcast(
      podcast.id,
    );
    ref.invalidate(downloadedEpisodesNotifierProvider);
    if (!mounted) return;
    ToastUtils.showSuccessToast(context, message: '已移除所有下载');
    await _checkDownloads();
  }

  Future<void> _handleUnfollow() async {
    final podcast = widget.podcast;
    if (podcast == null) return;

    try {
      final playHistoryRepo = PlayHistoryRepository();
      await playHistoryRepo.removeByPodcastId(podcast.id);

      final queueRepo = QueueRepositoryImpl();
      await queueRepo.removeFromQueueByPodcast(podcast.id, podcastITunesId: podcast.itunesId);

      final downloadService = AudioDownloadService.instance;
      await downloadService.unfollowPodcast(podcast.id);
      await ref.read(podcastProvider.notifier).unsubscribe(podcast.id);

      ref.read(queueNotifierProvider.notifier).removeByPodcastId(podcast.id);
      ref
          .read(completedHistoriesProvider.notifier)
          .removeByPodcastId(podcast.id);

      ref.invalidate(queueNotifierProvider);
      ref.invalidate(completedHistoriesProvider);
      ref.invalidate(favoriteEpisodesNotifierProvider);
      ref.invalidate(downloadedEpisodesNotifierProvider);
      ref.invalidate(unplayedEpisodesNotifierProvider);

      // 重新加载播客列表（从已清理的数据库）
      await ref.read(podcastProvider.notifier).loadSubscribedPodcasts();
      ref.read(downloadNotifierProvider.notifier).manualRefresh();

      if (!mounted) return;
      Navigator.of(context).pop();
      ToastUtils.showSuccessToast(context, message: '已取消关注');
    } catch (e) {
      Logger.error('取消关注失败', error: e);
      if (!mounted) return;
      ToastUtils.showErrorToast(context, message: '取消关注失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    final podcast = widget.podcast;

    return ShowInfo(
      title: podcast?.title,
      artworkUrl: podcast?.artworkUrl,
      description: podcast?.description,
      rssUrl: podcast?.rssUrl,
      hasDownloadedEpisodes: _hasDownloads,
      onViewDetails: () {},
      onCopyLinkSuccess: () {
        if (mounted) {
          ToastUtils.showCopySuccessToast(context);
        }
      },
      onRemoveDownloads: _handleRemoveDownloads,
      onUnfollow: _handleUnfollow,
    );
  }
}
