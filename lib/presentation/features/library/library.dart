import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/router/app_router.dart';
import 'package:tinycast/core/router/app_routes.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/features/library/library_list_item/library_list_item.dart';
import 'package:tinycast/presentation/features/library/library_empty_page/library_empty_page.dart';
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

        return _LibraryPodcastItem(
          key: ValueKey(podcast.id),
          podcast: podcast,
          showDivider: showDivider,
          onTap: () => _selectPodcast(podcast),
        );
      },
    );
  }
}

class _LibraryPodcastItem extends ConsumerWidget {
  final Podcast podcast;
  final bool showDivider;
  final VoidCallback onTap;

  const _LibraryPodcastItem({
    super.key,
    required this.podcast,
    required this.showDivider,
    required this.onTap,
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
        isLoading: false,
      ),
      loading: () => LibraryListItem(
        podcast: podcast,
        episodes: [],
        showDivider: showDivider,
        onTap: onTap,
        onTitleTap: onTap,
        isLoading: true,
      ),
      error: (error, stack) => LibraryListItem(
        podcast: podcast,
        episodes: [],
        showDivider: showDivider,
        onTap: onTap,
        onTitleTap: onTap,
        isLoading: false,
      ),
    );
  }
}
