import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/episode.dart';
import '../../domain/usecases/get_favorite_episodes_usecase.dart';
import 'podcast_provider.dart';
import 'favorite_provider.dart';

enum FavoriteEpisodesStatus { initial, loading, success, error }

class FavoriteEpisodesState {
  final FavoriteEpisodesStatus status;
  final List<Episode> episodes;
  final String? errorMessage;

  FavoriteEpisodesState({
    this.status = FavoriteEpisodesStatus.initial,
    this.episodes = const [],
    this.errorMessage,
  });

  FavoriteEpisodesState copyWith({
    FavoriteEpisodesStatus? status,
    List<Episode>? episodes,
    String? errorMessage,
  }) {
    return FavoriteEpisodesState(
      status: status ?? this.status,
      episodes: episodes ?? this.episodes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final getFavoriteEpisodesUseCaseProvider = Provider<GetFavoriteEpisodesUseCase>((ref) {
  final podcastRepository = ref.watch(podcastRepositoryProvider);
  final favoriteRepository = ref.watch(favoriteRepositoryProvider);
  return GetFavoriteEpisodesUseCase(podcastRepository, favoriteRepository);
});

class FavoriteEpisodesNotifier extends Notifier<FavoriteEpisodesState> {
  @override
  FavoriteEpisodesState build() {
    Future.microtask(() => loadFavoriteEpisodes());
    return FavoriteEpisodesState();
  }

  GetFavoriteEpisodesUseCase get _getFavoriteEpisodesUseCase =>
      ref.read(getFavoriteEpisodesUseCaseProvider);

  Future<void> loadFavoriteEpisodes() async {
    state = state.copyWith(status: FavoriteEpisodesStatus.loading, errorMessage: null);
    try {
      final episodes = await _getFavoriteEpisodesUseCase();
      state = state.copyWith(status: FavoriteEpisodesStatus.success, episodes: episodes);
    } catch (e) {
      state = state.copyWith(
        status: FavoriteEpisodesStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadFavoriteEpisodes();
  }

  void reset() {
    state = FavoriteEpisodesState();
  }
}

final favoriteEpisodesNotifierProvider =
    NotifierProvider<FavoriteEpisodesNotifier, FavoriteEpisodesState>(
  FavoriteEpisodesNotifier.new,
);

final favoriteEpisodesProvider = Provider<List<Episode>>((ref) {
  final state = ref.watch(favoriteEpisodesNotifierProvider);
  final sortedEpisodes = [...state.episodes];
  sortedEpisodes.sort((a, b) => b.pubDate.compareTo(a.pubDate));
  return sortedEpisodes;
});

final favoriteEpisodesLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(favoriteEpisodesNotifierProvider);
  return state.status == FavoriteEpisodesStatus.loading;
});
