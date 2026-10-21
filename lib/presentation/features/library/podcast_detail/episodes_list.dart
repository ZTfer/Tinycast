import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/core/utils/toast_utils.dart';
import 'package:tinycast/data/repositories/play_history_repository_impl.dart';
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
import 'package:tinycast/presentation/features/library/podcast_detail/show_info.dart';

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
    if (podcast == null) {
      Logger.error('🚫 [UNFOLLOW] podcast 为 null，无法取消关注');
      return;
    }

    Logger.info('🚫 [UNFOLLOW] 开始取消关注 podcast: ${podcast.title} (id: ${podcast.id})');
    try {
      Logger.info('🚫 [UNFOLLOW] 步骤 1/7: 清理播放历史记录...');
      final playHistoryRepo = PlayHistoryRepositoryImpl();
      await playHistoryRepo.removeByPodcastId(podcast.id);
      Logger.info('✅ [UNFOLLOW] 播放历史记录清理完成');

      Logger.info('🚫 [UNFOLLOW] 步骤 2/7: 清理队列记录...');
      final queueRepo = QueueRepositoryImpl();
      await queueRepo.removeFromQueueByPodcast(podcast.id, podcastITunesId: podcast.itunesId);
      Logger.info('✅ [UNFOLLOW] 队列记录清理完成');

      Logger.info('🚫 [UNFOLLOW] 步骤 3/7: 取消关注播客（删除文件）...');
      final downloadService = AudioDownloadService.instance;
      await downloadService.unfollowPodcast(podcast.id);
      Logger.info('✅ [UNFOLLOW] 文件删除完成');

      Logger.info('🚫 [UNFOLLOW] 步骤 4/7: 从数据库删除播客...');
      await ref.read(podcastProvider.notifier).unsubscribe(podcast.id);
      Logger.info('✅ [UNFOLLOW] 数据库删除完成');

      Logger.info('🚫 [UNFOLLOW] 步骤 5/7: 清理内存状态...');
      ref.read(queueNotifierProvider.notifier).removeByPodcastId(podcast.id);
      ref
          .read(completedHistoriesProvider.notifier)
          .removeByPodcastId(podcast.id);
      Logger.info('✅ [UNFOLLOW] 内存状态清理完成');

      Logger.info('🚫 [UNFOLLOW] 步骤 6/7: Invalidate providers...');
      ref.invalidate(queueNotifierProvider);
      ref.invalidate(completedHistoriesProvider);
      ref.invalidate(favoriteEpisodesNotifierProvider);
      ref.invalidate(downloadedEpisodesNotifierProvider);
      ref.invalidate(unplayedEpisodesNotifierProvider);
      Logger.info('✅ [UNFOLLOW] Providers invalidate 完成');

      // 重新加载播客列表（从已清理的数据库）
      Logger.info('🚫 [UNFOLLOW] 步骤 7/7: 重新加载播客列表...');
      await ref.read(podcastProvider.notifier).loadSubscribedPodcasts();
      ref.read(downloadNotifierProvider.notifier).manualRefresh();
      Logger.info('✅ [UNFOLLOW] 播客列表重新加载完成');

      if (!mounted) return;
      // 先弹 Toast 再关闭页面：pop 后本页 context 失活，Overlay.maybeOf 不再可用。
      ToastUtils.showSuccessToast(context, message: '已取消关注');
      Navigator.of(context).pop();
      Logger.info('✅ [UNFOLLOW] 取消关注流程全部完成');
    } catch (e, stackTrace) {
      Logger.error('❌ [UNFOLLOW] 取消关注失败', error: e, stackTrace: stackTrace);
      if (!mounted) return;
      ToastUtils.showErrorToast(context, message: '取消关注失败: $e');
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
