import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/episode.dart';
import '../../domain/usecases/get_unplayed_episodes_usecase.dart';
import 'podcast_provider.dart';

enum UnplayedEpisodesStatus { initial, loading, success, error }

class UnplayedEpisodesState {
  final UnplayedEpisodesStatus status;
  final List<Episode> episodes;
  final String? errorMessage;

  UnplayedEpisodesState({
    this.status = UnplayedEpisodesStatus.initial,
    this.episodes = const [],
    this.errorMessage,
  });

  UnplayedEpisodesState copyWith({
    UnplayedEpisodesStatus? status,
    List<Episode>? episodes,
    String? errorMessage,
  }) {
    return UnplayedEpisodesState(
      status: status ?? this.status,
      episodes: episodes ?? this.episodes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final getUnplayedEpisodesUseCaseProvider = Provider<GetUnplayedEpisodesUseCase>((ref) {
  final repository = ref.watch(podcastRepositoryProvider);
  return GetUnplayedEpisodesUseCase(repository);
});

class UnplayedEpisodesNotifier extends Notifier<UnplayedEpisodesState> {
  @override
  UnplayedEpisodesState build() => UnplayedEpisodesState();

  GetUnplayedEpisodesUseCase get _getUnplayedEpisodesUseCase =>
      ref.read(getUnplayedEpisodesUseCaseProvider);

  Future<void> loadUnplayedEpisodes() async {
    state = state.copyWith(status: UnplayedEpisodesStatus.loading, errorMessage: null);
    try {
      final episodes = await _getUnplayedEpisodesUseCase();
      state = state.copyWith(status: UnplayedEpisodesStatus.success, episodes: episodes);
    } catch (e) {
      state = state.copyWith(
        status: UnplayedEpisodesStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadUnplayedEpisodes();
  }

  void reset() {
    state = UnplayedEpisodesState();
  }
}

final unplayedEpisodesNotifierProvider = NotifierProvider<UnplayedEpisodesNotifier, UnplayedEpisodesState>(
  UnplayedEpisodesNotifier.new,
);

final unplayedEpisodesProvider = Provider<List<Episode>>((ref) {
  final state = ref.watch(unplayedEpisodesNotifierProvider);
  return state.episodes;
});

final unplayedEpisodesLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(unplayedEpisodesNotifierProvider);
  return state.status == UnplayedEpisodesStatus.loading;
});
