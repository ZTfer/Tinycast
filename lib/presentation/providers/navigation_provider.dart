import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/core/router/app_routes.dart';
import 'package:tinycast/core/utils/logger.dart';

/// 详情页类型
enum DetailType {
  podcast,
  episode,
}

/// 详情页状态
class DetailState {
  final DetailType type;
  final dynamic data;
  final Podcast? podcast;

  const DetailState({
    required this.type,
    this.data,
    this.podcast,
  });

  factory DetailState.podcast(Podcast podcast) {
    return DetailState(type: DetailType.podcast, data: podcast);
  }

  factory DetailState.episode(Episode episode, Podcast podcast) {
    return DetailState(type: DetailType.episode, data: episode, podcast: podcast);
  }

  Podcast? get podcastData => type == DetailType.podcast ? data as Podcast : podcast;
  Episode? get episodeData => type == DetailType.episode ? data as Episode : null;
}

/// 导航状态
class NavigationState {
  final String currentPage;
  final List<DetailState> detailStack;

  NavigationState({
    this.currentPage = AppRoutes.queue,
    List<DetailState>? detailStack,
  }) : detailStack = detailStack ?? const [];

  bool get hasDetail => detailStack.isNotEmpty;

  DetailState? get currentDetail => detailStack.isNotEmpty ? detailStack.last : null;

  NavigationState copyWith({
    String? currentPage,
    List<DetailState>? detailStack,
  }) {
    return NavigationState(
      currentPage: currentPage ?? this.currentPage,
      detailStack: detailStack ?? this.detailStack,
    );
  }
}

class NavigationNotifier extends Notifier<NavigationState> {
  @override
  NavigationState build() {
    final initialState = NavigationState();
    Logger.info('🧭 [NAV] NavigationNotifier initialized, current page: ${initialState.currentPage}');
    return initialState;
  }

  void navigateToPage(String page) {
    Logger.info('🧭 [NAV] Navigate to page: $page');
    Logger.info('🧭 [NAV] Clear detail stack (${state.detailStack.length} items)');
    state = NavigationState(currentPage: page, detailStack: const []);
    Logger.info('🧭 [NAV] Navigation state updated: ${state.currentPage}, detail stack: ${state.detailStack.length} items');
  }

  void showPodcastDetail(Podcast podcast) {
    Logger.info('🧭 [NAV] Show podcast detail: ${podcast.title} (ID: ${podcast.id})');
    Logger.info('🧭 [NAV] Current detail stack size: ${state.detailStack.length}');
    final newStack = [...state.detailStack, DetailState.podcast(podcast)];
    state = state.copyWith(detailStack: newStack);
    Logger.info('🧭 [NAV] New detail stack size: ${state.detailStack.length}');
  }

  void showEpisodeDetail(Episode episode, Podcast podcast) {
    Logger.info('🧭 [NAV] Show episode detail: ${episode.title} (ID: ${episode.id})');
    Logger.info('🧭 [NAV] From podcast: ${podcast.title} (ID: ${podcast.id})');
    Logger.info('🧭 [NAV] Current detail stack size: ${state.detailStack.length}');
    final newStack = [...state.detailStack, DetailState.episode(episode, podcast)];
    state = state.copyWith(detailStack: newStack);
    Logger.info('🧭 [NAV] New detail stack size: ${state.detailStack.length}');
  }

  void goBack() {
    if (state.detailStack.isNotEmpty) {
      Logger.info('🧭 [NAV] Go back from detail page');
      Logger.info('🧭 [NAV] Current detail stack size: ${state.detailStack.length}');
      final newStack = [...state.detailStack]..removeLast();
      state = state.copyWith(detailStack: newStack);
      Logger.info('🧭 [NAV] New detail stack size: ${state.detailStack.length}');
    } else {
      Logger.info('🧭 [NAV] Go back: no detail pages to pop');
    }
  }

  void clearDetail() {
    Logger.info('🧭 [NAV] Clear detail stack (${state.detailStack.length} items)');
    state = state.copyWith(detailStack: const []);
    Logger.info('🧭 [NAV] Detail stack cleared');
  }
}

final navigationProvider = NotifierProvider<NavigationNotifier, NavigationState>(
  NavigationNotifier.new,
);

final currentPageProvider = Provider<String>((ref) {
  return ref.watch(navigationProvider).currentPage;
});

final currentDetailProvider = Provider<DetailState?>((ref) {
  return ref.watch(navigationProvider).currentDetail;
});

final hasDetailProvider = Provider<bool>((ref) {
  return ref.watch(navigationProvider).hasDetail;
});
