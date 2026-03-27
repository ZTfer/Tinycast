import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/widgets/molecules/sidebar/sidebar.dart';
import 'package:tinycast/presentation/pages/downloads/downloads.dart';
import 'package:tinycast/presentation/pages/favorite/favorite.dart';
import 'package:tinycast/presentation/pages/library/library.dart';
import 'package:tinycast/presentation/pages/subscribe/subscribe.dart';
import 'package:tinycast/presentation/pages/test_page/test_page.dart';
import 'package:tinycast/presentation/pages/up_next_queue/up_next_queue.dart';
import 'package:tinycast/presentation/pages/settings/settings.dart';
import 'package:tinycast/presentation/pages/podcast_detail/podcast_detail.dart';
import 'package:tinycast/presentation/pages/episode_detail/episode_detail.dart';
import 'package:tinycast/presentation/providers/navigation_provider.dart';
import 'package:tinycast/core/router/app_routes.dart';

class Body extends ConsumerWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);

    return Container(
      color: const Color(0xFFFFFFFF),
      child: Row(
        children: [
          Sidebar(
            currentPage: navigationState.currentPage,
            onPageChanged: (page) {
              ref.read(navigationProvider.notifier).navigateToPage(page);
            },
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              alignment: Alignment.topLeft,
              child: _buildContent(navigationState, ref),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(NavigationState state, WidgetRef ref) {
    if (state.hasDetail) {
      return _buildDetailPage(state, ref);
    }

    return _buildMainPage(state.currentPage);
  }

  Widget _buildMainPage(String currentPage) {
    switch (currentPage) {
      case AppRoutes.library:
        return const Library();
      case AppRoutes.favorite:
        return const Favorite();
      case AppRoutes.downloads:
        return const Downloads();
      case AppRoutes.subscribe:
        return const Subscribe();
      case AppRoutes.testPage:
        return const TestPage();
      case AppRoutes.settings:
        return const Settings();
      case AppRoutes.queue:
      default:
        return const UpNextQueue();
    }
  }

  Widget _buildDetailPage(NavigationState state, WidgetRef ref) {
    final detail = state.currentDetail;
    if (detail == null) return _buildMainPage(state.currentPage);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => ref.read(navigationProvider.notifier).goBack(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios, size: 14),
                      SizedBox(width: 4),
                      Text(
                        '返回',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildDetailContent(detail),
        ),
      ],
    );
  }

  Widget _buildDetailContent(DetailState detail) {
    switch (detail.type) {
      case DetailType.podcast:
        final podcast = detail.podcastData;
        if (podcast == null) return const SizedBox.shrink();
        return PodcastDetail(podcastId: podcast.id);
      case DetailType.episode:
        return EpisodeDetail(
          episode: detail.episodeData,
          podcast: detail.podcastData,
        );
    }
  }
}
