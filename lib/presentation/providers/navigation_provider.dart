import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/core/router/app_routes.dart';

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
    return NavigationState();
  }

  void navigateToPage(String page) {
    state = NavigationState(currentPage: page, detailStack: const []);
  }

  void showPodcastDetail(Podcast podcast) {
    final newStack = [...state.detailStack, DetailState.podcast(podcast)];
    state = state.copyWith(detailStack: newStack);
  }

  void showEpisodeDetail(Episode episode, Podcast podcast) {
    final newStack = [...state.detailStack, DetailState.episode(episode, podcast)];
    state = state.copyWith(detailStack: newStack);
  }

  void goBack() {
    if (state.detailStack.isNotEmpty) {
      final newStack = [...state.detailStack]..removeLast();
      state = state.copyWith(detailStack: newStack);
    }
  }

  void clearDetail() {
    state = state.copyWith(detailStack: const []);
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
