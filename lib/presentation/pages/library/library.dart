import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/router/app_router.dart';
import 'package:tinycast/core/router/app_routes.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/pages/library/library_list_item/library_list_item.dart';
import 'package:tinycast/presentation/pages/library/library_empty_page/library_empty_page.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/core/utils/error_toast.dart';
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
    // 初始化时加载订阅的播客
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPodcasts();
    });
  }

  /// 加载播客列表
  Future<void> _loadPodcasts() async {
    try {
      await ref.read(podcastProvider.notifier).loadSubscribedPodcasts();
    } catch (e) {
      // 处理加载错误
      AppException exception;
      if (e is AppException) {
        exception = e;
      } else {
        exception = AppException.unknown(
          '加载播客列表失败：${e.toString()}',
          originalError: e,
        );
      }

      // 显示错误提示
      if (mounted) {
        ErrorToast.showException(context, exception);
      }
    }
  }

  /// 重试加载
  Future<void> _retryLoad() async {
    try {
      await _loadPodcasts(); // 显示错误提示
      if (mounted) {
        ErrorToast.showSuccess(context, '加载成功');
      }
    } catch (e) {
      // 错误已在 _loadPodcasts 中处理
    }
  }

  /// 导航到播客详情页面
  void _navigateToPodcastDetail(Podcast podcast) {
    AppRouter.navigateTo(context, AppRoutes.podcastDetail, arguments: podcast);
  }

  /// 显示更多操作菜单
  void _showMoreMenu(Podcast podcast) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('分享'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现分享功能
              },
            ),
            ListTile(
              leading: const Icon(Icons.mark_email_read_outlined),
              title: const Text('标记为已读'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现标记为已读功能
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('下载全部'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现下载全部功能
              },
            ),
            ListTile(
              leading: const Icon(Icons.unsubscribe_outlined),
              title: const Text('取消订阅'),
              onTap: () async {
                Navigator.pop(context);
                await ref
                    .read(podcastProvider.notifier)
                    .unsubscribe(podcast.id);
              },
            ),
          ],
        ),
      ),
    );
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
    // 加载状态
    if (state.status == PodcastStatus.loading && podcasts.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // 错误状态
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

    // 空状态
    if (podcasts.isEmpty) {
      return LibraryEmptyPage(
        onRssSubscribe: () =>
            AppRouter.navigateTo(context, AppRoutes.subscribe),
        onSearchPodcast: () => AppRouter.navigateTo(context, AppRoutes.search),
      );
    }

    // 显示播客列表
    return ListView.builder(
      itemCount: podcasts.length,
      itemBuilder: (context, index) {
        final podcast = podcasts[index];
        final showDivider = index < podcasts.length - 1;

        return _LibraryPodcastItem(
          key: ValueKey(podcast.id),
          podcast: podcast,
          showDivider: showDivider,
          onTap: () => _navigateToPodcastDetail(podcast),
          onMorePressed: () => _showMoreMenu(podcast),
        );
      },
    );
  }
}

/// 播客列表项组件，负责加载和管理单个播客的剧集数据
class _LibraryPodcastItem extends ConsumerWidget {
  final Podcast podcast;
  final bool showDivider;
  final VoidCallback onTap;
  final VoidCallback onMorePressed;

  const _LibraryPodcastItem({
    super.key,
    required this.podcast,
    required this.showDivider,
    required this.onTap,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听该播客的最新剧集数据
    final episodesAsync = ref.watch(latestEpisodesProvider(podcast.id));

    return episodesAsync.when(
      // 数据加载成功
      data: (episodes) => LibraryListItem(
        podcast: podcast,
        episodes: episodes,
        showDivider: showDivider,
        onTap: onTap,
        onMorePressed: onMorePressed,
        isLoading: false,
      ),
      // 加载中状态：显示播客信息和加载骨架屏
      loading: () => LibraryListItem(
        podcast: podcast,
        episodes: [],
        showDivider: showDivider,
        onTap: onTap,
        onMorePressed: onMorePressed,
        isLoading: true,
      ),
      // 错误状态：显示播客信息，但剧集列表为空，不影响其他播客展示
      error: (error, stack) => LibraryListItem(
        podcast: podcast,
        episodes: [],
        showDivider: showDivider,
        onTap: onTap,
        onMorePressed: onMorePressed,
        isLoading: false,
      ),
    );
  }
}
