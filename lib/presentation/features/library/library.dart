import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/router/app_router.dart';
import 'package:tinycast/core/router/app_routes.dart';
import 'package:tinycast/data/services/audio_download_service.dart';
import 'package:tinycast/data/repositories/play_history_repository.dart';
import 'package:tinycast/data/repositories/queue_repository_impl.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/features/library/library_list_item/library_list_item.dart';
import 'package:tinycast/presentation/features/library/library_empty_page/library_empty_page.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/presentation/providers/navigation_provider.dart';
import 'package:tinycast/presentation/providers/download_provider.dart';
import 'package:tinycast/presentation/providers/queue_provider.dart';
import 'package:tinycast/presentation/providers/play_history_provider.dart';
import 'package:tinycast/presentation/providers/favorite_episodes_provider.dart';
import 'package:tinycast/presentation/providers/unplayed_episodes_provider.dart';
import 'package:tinycast/presentation/features/downloads/downloaded_episodes_provider.dart';
import 'package:tinycast/presentation/widgets/common/error_toast.dart';
import 'package:tinycast/core/utils/app_exception.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/core/utils/toast_utils.dart';

class Library extends ConsumerStatefulWidget {
  const Library({super.key});

  @override
  ConsumerState<Library> createState() => _LibraryState();
}

class _LibraryState extends ConsumerState<Library> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPodcasts();
    });
  }

  @override
  void didUpdateWidget(Library oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPodcasts();
    });
  }

  Future<void> _loadPodcasts() async {
    final stopwatch = Stopwatch()..start();
    Logger.info('🕒 [LIBRARY-UI] _loadPodcasts 被调用');
    try {
      await ref.read(podcastProvider.notifier).loadSubscribedPodcasts();
      Logger.info('🕒 [LIBRARY-UI] _loadPodcasts 完成, 总耗时 ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.stop();
    } catch (e) {
      Logger.info('🕒 [LIBRARY-UI] _loadPodcasts 异常: $e');
      stopwatch.stop();
      AppException exception;
      if (e is AppException) {
        exception = e;
      } else {
        exception = AppException.unknown(
          '加载播客列表失败：${e.toString()}',
          originalError: e,
        );
      }

      if (!context.mounted) return;
      // ignore: use_build_context_synchronously
      ErrorToast.showException(context, exception);
    }
  }

  Future<void> _retryLoad() async {
    try {
      await _loadPodcasts();
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, message: '加载成功');
    } catch (e) {
      if (!mounted) return;
      AppException exception;
      if (e is AppException) {
        exception = e;
      } else {
        exception = AppException.unknown(
          '重新加载失败：${e.toString()}',
          originalError: e,
        );
      }
      ErrorToast.showException(context, exception);
    }
  }

  void _selectPodcast(Podcast podcast) {
    ref.read(navigationProvider.notifier).showPodcastDetail(podcast);
  }

  void _copyLink(Podcast podcast) {
    Clipboard.setData(ClipboardData(text: podcast.rssUrl));
    if (mounted) {
      ToastUtils.showSuccessToast(context, message: '链接已复制');
    }
  }

  Future<void> _unfollow(Podcast podcast) async {
    Logger.info('🚫 [LIBRARY-UNFOLLOW] 开始取消关注 podcast: ${podcast.title} (id: ${podcast.id})');
    try {
      Logger.info('🚫 [LIBRARY-UNFOLLOW] 步骤 1/5: 清理播放历史记录...');
      final playHistoryRepo = PlayHistoryRepository();
      await playHistoryRepo.removeByPodcastId(podcast.id);
      Logger.info('✅ [LIBRARY-UNFOLLOW] 播放历史记录清理完成');

      Logger.info('🚫 [LIBRARY-UNFOLLOW] 步骤 2/5: 清理队列记录...');
      final queueRepo = QueueRepositoryImpl();
      await queueRepo.removeFromQueueByPodcast(podcast.id, podcastITunesId: podcast.itunesId);
      Logger.info('✅ [LIBRARY-UNFOLLOW] 队列记录清理完成');

      Logger.info('🚫 [LIBRARY-UNFOLLOW] 步骤 3/5: 取消关注播客（删除文件和数据库）...');
      final downloadService = AudioDownloadService.instance;
      await downloadService.unfollowPodcast(podcast.id);
      await ref.read(podcastProvider.notifier).unsubscribe(podcast.id);
      Logger.info('✅ [LIBRARY-UNFOLLOW] 取消关注完成');

      Logger.info('🚫 [LIBRARY-UNFOLLOW] 步骤 4/5: 清理内存状态...');
      ref.read(queueNotifierProvider.notifier).removeByPodcastId(podcast.id);
      ref.read(completedHistoriesProvider.notifier).removeByPodcastId(podcast.id);
      ref.invalidate(queueNotifierProvider);
      ref.invalidate(completedHistoriesProvider);
      ref.invalidate(favoriteEpisodesNotifierProvider);
      ref.invalidate(downloadedEpisodesNotifierProvider);
      ref.invalidate(unplayedEpisodesNotifierProvider);
      Logger.info('✅ [LIBRARY-UNFOLLOW] 内存状态清理完成');

      Logger.info('🚫 [LIBRARY-UNFOLLOW] 步骤 5/5: 重新加载播客列表...');
      await ref.read(podcastProvider.notifier).loadSubscribedPodcasts();
      ref.read(downloadNotifierProvider.notifier).manualRefresh();
      Logger.info('✅ [LIBRARY-UNFOLLOW] 播客列表重新加载完成');

      if (!mounted) return;
      ToastUtils.showSuccessToast(context, message: '已取消关注');
      Logger.info('✅ [LIBRARY-UNFOLLOW] 取消关注流程全部完成');
    } catch (e, stackTrace) {
      Logger.error('❌ [LIBRARY-UNFOLLOW] 取消关注失败', error: e, stackTrace: stackTrace);
      if (!mounted) return;
      ToastUtils.showErrorToast(context, message: '取消关注失败: $e');
    }
  }

  Future<void> _removeDownloads(Podcast podcast) async {
    final downloadService = AudioDownloadService.instance;
    await downloadService.removeAllDownloadsForPodcast(podcast.id);

    if (!mounted) return;
    ToastUtils.showSuccessToast(context, message: '已移除所有下载');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(podcastProvider);
    final podcasts = ref.watch(subscribedPodcastsProvider) ?? [];
    Logger.info('🕒 [LIBRARY-UI] build 被调用, status=${state.status}, podcasts.length=${podcasts.length}, podcasts.isEmpty=${podcasts.isEmpty}');

    return FutureBuilder<Map<int, bool>>(
      key: ValueKey(podcasts.length),
      future: _computeDownloadStatus(podcasts),
      builder: (context, snapshot) {
        Logger.info('🕒 [LIBRARY-UI] FutureBuilder builder, snapshot.connectionState=${snapshot.connectionState}, hasData=${snapshot.hasData}');
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildContent(state, podcasts, snapshot.data ?? {}),
        );
      },
    );
  }

  Future<Map<int, bool>> _computeDownloadStatus(List<Podcast> podcasts) async {
    final downloadService = AudioDownloadService.instance;
    final result = <int, bool>{};
    for (final podcast in podcasts) {
      result[podcast.id] = await downloadService
          .hasDownloadedEpisodesForPodcast(podcast.id);
    }
    return result;
  }

  Widget _buildContent(
    PodcastState state,
    List<Podcast> podcasts,
    Map<int, bool> hasDownloadMap,
  ) {
    if (state.status == PodcastStatus.loading && podcasts.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == PodcastStatus.error && podcasts.isEmpty) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? '加载失败',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _retryLoad,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000000),
                  foregroundColor: const Color(0xFFFFFFFF),
                ),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (podcasts.isEmpty) {
      return LibraryEmptyPage(
        onRssSubscribe: () =>
            AppRouter.navigateTo(context, AppRoutes.subscribe),
        onSearchPodcast: () => AppRouter.navigateTo(context, AppRoutes.search),
      );
    }

    return ListView.builder(
      itemCount: podcasts.length,
      itemBuilder: (context, index) {
        final podcast = podcasts[index];
        final showDivider = index < podcasts.length - 1;

        return _LibraryPodcastItem(
          key: ValueKey(podcast.id),
          podcast: podcast,
          showDivider: showDivider,
          onTap: () => _selectPodcast(podcast),
          onViewDetails: () => _selectPodcast(podcast),
          rssUrl: podcast.rssUrl,
          onCopyLinkSuccess: () => _copyLink(podcast),
          hasDownloadedEpisodes: hasDownloadMap[podcast.id] ?? false,
          onRemoveDownloads: () => _removeDownloads(podcast),
          onUnfollow: () => _unfollow(podcast),
        );
      },
    );
  }
}

class _LibraryPodcastItem extends ConsumerWidget {
  final Podcast podcast;
  final bool showDivider;
  final VoidCallback onTap;
  final VoidCallback? onViewDetails;
  final String? rssUrl;
  final VoidCallback? onCopyLinkSuccess;
  final bool hasDownloadedEpisodes;
  final VoidCallback? onRemoveDownloads;
  final VoidCallback? onUnfollow;

  const _LibraryPodcastItem({
    super.key,
    required this.podcast,
    required this.showDivider,
    required this.onTap,
    this.onViewDetails,
    this.rssUrl,
    this.onCopyLinkSuccess,
    this.hasDownloadedEpisodes = false,
    this.onRemoveDownloads,
    this.onUnfollow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodesAsync = ref.watch(latestEpisodesProvider(podcast.id));

    return episodesAsync.when(
      data: (episodes) => LibraryListItem(
        podcast: podcast,
        episodes: episodes,
        showDivider: showDivider,
        onTap: onTap,
        onTitleTap: onTap,
        onViewDetails: onViewDetails,
        rssUrl: rssUrl,
        onCopyLinkSuccess: onCopyLinkSuccess,
        hasDownloadedEpisodes: hasDownloadedEpisodes,
        onRemoveDownloads: onRemoveDownloads,
        onUnfollow: onUnfollow,
        isLoading: false,
      ),
      loading: () => LibraryListItem(
        podcast: podcast,
        episodes: [],
        showDivider: showDivider,
        onTap: onTap,
        onTitleTap: onTap,
        onViewDetails: onViewDetails,
        rssUrl: rssUrl,
        onCopyLinkSuccess: onCopyLinkSuccess,
        hasDownloadedEpisodes: hasDownloadedEpisodes,
        onRemoveDownloads: onRemoveDownloads,
        onUnfollow: onUnfollow,
        isLoading: true,
      ),
      error: (error, stack) => LibraryListItem(
        podcast: podcast,
        episodes: [],
        showDivider: showDivider,
        onTap: onTap,
        onTitleTap: onTap,
        onViewDetails: onViewDetails,
        rssUrl: rssUrl,
        onCopyLinkSuccess: onCopyLinkSuccess,
        hasDownloadedEpisodes: hasDownloadedEpisodes,
        onRemoveDownloads: onRemoveDownloads,
        onUnfollow: onUnfollow,
        isLoading: false,
      ),
    );
  }
}
