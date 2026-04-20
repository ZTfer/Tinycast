import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/router/app_router.dart';
import 'package:tinycast/core/router/app_routes.dart';
import 'package:tinycast/data/services/audio_download_service.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/features/library/library_list_item/library_list_item.dart';
import 'package:tinycast/presentation/features/library/library_empty_page/library_empty_page.dart';
import 'package:tinycast/presentation/providers/download_provider.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/presentation/providers/navigation_provider.dart';
import 'package:tinycast/presentation/widgets/common/error_toast.dart';
import 'package:tinycast/core/utils/app_exception.dart';

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

  Future<void> _loadPodcasts() async {
    try {
      await ref.read(podcastProvider.notifier).loadSubscribedPodcasts();
    } catch (e) {
      AppException exception;
      if (e is AppException) {
        exception = e;
      } else {
        exception = AppException.unknown(
          '加载播客列表失败：${e.toString()}',
          originalError: e,
        );
      }

      if (mounted) {
        ErrorToast.showException(context, exception);
      }
    }
  }

  Future<void> _retryLoad() async {
    try {
      await _loadPodcasts();
      if (mounted) {
        ErrorToast.showSuccess(context, '加载成功');
      }
    } catch (e) {
      // 错误已在 _loadPodcasts 中处理
    }
  }

  void _selectPodcast(Podcast podcast) {
    ref.read(navigationProvider.notifier).showPodcastDetail(podcast);
  }

  void _copyLink(Podcast podcast) {
    Clipboard.setData(ClipboardData(text: podcast.rssUrl));
    if (mounted) {
      ErrorToast.showSuccess(context, '链接已复制');
    }
  }

  void _unfollow(Podcast podcast) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消关注'),
        content: const Text('确定要取消关注这个节目吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(podcastProvider.notifier).unsubscribe(podcast.id);
              if (mounted) {
                ErrorToast.showSuccess(context, '已取消关注');
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeDownloads(Podcast podcast) async {
    final downloadService = AudioDownloadService.instance;
    final completedIds = ref.read(downloadNotifierProvider).getCompletedEpisodes();

    for (final episodeId in completedIds) {
      await downloadService.deleteDownloadedEpisode(episodeId);
    }

    if (mounted) {
      ErrorToast.showSuccess(context, '已移除所有下载');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(podcastProvider);
    final podcasts = ref.watch(subscribedPodcastsProvider) ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _buildContent(state, podcasts),
    );
  }

  Widget _buildContent(PodcastState state, List<Podcast> podcasts) {
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
        final completedIds = ref.read(downloadNotifierProvider).getCompletedEpisodes();

        return _LibraryPodcastItem(
          key: ValueKey(podcast.id),
          podcast: podcast,
          showDivider: showDivider,
          onTap: () => _selectPodcast(podcast),
          onViewDetails: () => _selectPodcast(podcast),
          rssUrl: podcast.rssUrl,
          onCopyLinkSuccess: () => _copyLink(podcast),
          hasDownloadedEpisodes: completedIds.isNotEmpty,
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
