import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/widgets/organisms/navbar/navbar.dart';
import 'package:tinycast/presentation/widgets/organisms/tabbar/tabbar.dart'
    as custom_tabbar;
import 'package:tinycast/presentation/features/downloads/downloads.dart';
import 'package:tinycast/presentation/features/favorite/favorite.dart';
import 'package:tinycast/presentation/features/history/history.dart';
import 'package:tinycast/presentation/features/library/library.dart';
import 'package:tinycast/presentation/features/subscribe/subscribe.dart';
import 'package:tinycast/presentation/features/debug/test_page.dart';
import 'package:tinycast/presentation/features/queue/queue.dart';
import 'package:tinycast/presentation/features/settings/settings.dart';
import 'package:tinycast/presentation/features/library/podcast_detail/podcast_detail.dart';
import 'package:tinycast/presentation/features/episode_detail/episode_detail.dart';
import 'package:tinycast/presentation/providers/navigation_provider.dart';
import 'package:tinycast/core/router/app_routes.dart';

class MobileBody extends ConsumerWidget {
  const MobileBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Navbar(title: _getPageTitle(navigationState.currentPage)),
        ),
        Expanded(child: _buildContent(navigationState, ref)),
        custom_tabbar.TabBar(
          currentPage: navigationState.currentPage,
          onPageChanged: (page) {
            ref.read(navigationProvider.notifier).navigateToPage(page);
          },
        ),
      ],
    );
  }

  String _getPageTitle(String currentPage) {
    switch (currentPage) {
      case AppRoutes.queue:
        return 'Queue';
      case AppRoutes.library:
        return 'Library';
      case AppRoutes.favorite:
        return 'Favorite';
      case AppRoutes.history:
        return 'History';
      case AppRoutes.downloads:
        return 'Downloads';
      case AppRoutes.subscribe:
        return 'Subscribe';
      case AppRoutes.settings:
        return 'Settings';
      case AppRoutes.testPage:
        return 'Test Page';
      default:
        return 'Tinycast';
    }
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
      case AppRoutes.history:
        return const History();
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
        return const Queue();
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
              GestureDetector(
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
            ],
          ),
        ),
        Expanded(child: _buildDetailContent(detail)),
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
