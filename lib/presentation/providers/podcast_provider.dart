import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/podcast.dart';
import '../../domain/entities/episode.dart';
import '../../domain/repositories/podcast_repository.dart';
import '../../domain/usecases/subscribe_podcast_usecase.dart';
import '../../domain/usecases/unsubscribe_podcast_usecase.dart';
import '../../domain/usecases/get_subscribed_podcasts_usecase.dart';
import '../../domain/usecases/get_podcast_by_id_usecase.dart';
import '../../domain/usecases/get_episodes_by_podcast_id_usecase.dart';
import '../../data/repositories/podcast_repository_impl.dart';
import 'base_provider.dart';

enum PodcastStatus {
  initial,
  loading,
  success,
  error,
}

class PodcastState {
  final PodcastStatus status;
  final Podcast? podcast;
  final List<Podcast>? podcasts;
  final List<Episode>? episodes;
  final String? errorMessage;

  PodcastState({
    this.status = PodcastStatus.initial,
    this.podcast,
    this.podcasts,
    this.episodes,
    this.errorMessage,
  });

  PodcastState copyWith({
    PodcastStatus? status,
    Podcast? podcast,
    List<Podcast>? podcasts,
    List<Episode>? episodes,
    String? errorMessage,
  }) {
    return PodcastState(
      status: status ?? this.status,
      podcast: podcast ?? this.podcast,
      podcasts: podcasts ?? this.podcasts,
      episodes: episodes ?? this.episodes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PodcastNotifier extends StateNotifier<PodcastState> {
  final SubscribePodcastUseCase _subscribePodcastUseCase;
  final UnsubscribePodcastUseCase _unsubscribePodcastUseCase;
  final GetSubscribedPodcastsUseCase _getSubscribedPodcastsUseCase;
  final GetPodcastByIdUseCase _getPodcastByIdUseCase;
  final GetEpisodesByPodcastIdUseCase _getEpisodesByPodcastIdUseCase;

  PodcastNotifier({
    required SubscribePodcastUseCase subscribePodcastUseCase,
    required UnsubscribePodcastUseCase unsubscribePodcastUseCase,
    required GetSubscribedPodcastsUseCase getSubscribedPodcastsUseCase,
    required GetPodcastByIdUseCase getPodcastByIdUseCase,
    required GetEpisodesByPodcastIdUseCase getEpisodesByPodcastIdUseCase,
  })  : _subscribePodcastUseCase = subscribePodcastUseCase,
        _unsubscribePodcastUseCase = unsubscribePodcastUseCase,
        _getSubscribedPodcastsUseCase = getSubscribedPodcastsUseCase,
        _getPodcastByIdUseCase = getPodcastByIdUseCase,
        _getEpisodesByPodcastIdUseCase = getEpisodesByPodcastIdUseCase,
        super(PodcastState());

  Future<void> subscribe(String rssUrl) async {
    state = state.copyWith(status: PodcastStatus.loading, errorMessage: null);
    try {
      final podcast = await _subscribePodcastUseCase(rssUrl);
      state = state.copyWith(
        status: PodcastStatus.success,
        podcast: podcast,
      );
    } catch (e) {
      state = state.copyWith(
        status: PodcastStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> unsubscribe(int podcastId) async {
    state = state.copyWith(status: PodcastStatus.loading, errorMessage: null);
    try {
      await _unsubscribePodcastUseCase(podcastId);
      state = state.copyWith(
        status: PodcastStatus.success,
        podcast: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: PodcastStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadSubscribedPodcasts() async {
    state = state.copyWith(status: PodcastStatus.loading, errorMessage: null);
    try {
      final podcasts = await _getSubscribedPodcastsUseCase();
      state = state.copyWith(
        status: PodcastStatus.success,
        podcasts: podcasts,
      );
    } catch (e) {
      state = state.copyWith(
        status: PodcastStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadPodcastById(int id) async {
    state = state.copyWith(status: PodcastStatus.loading, errorMessage: null);
    try {
      final podcast = await _getPodcastByIdUseCase(id);
      state = state.copyWith(
        status: PodcastStatus.success,
        podcast: podcast,
      );
    } catch (e) {
      state = state.copyWith(
        status: PodcastStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadEpisodesByPodcastId(int id) async {
    state = state.copyWith(status: PodcastStatus.loading, errorMessage: null);
    try {
      final episodes = await _getEpisodesByPodcastIdUseCase(id);
      state = state.copyWith(
        status: PodcastStatus.success,
        episodes: episodes,
      );
    } catch (e) {
      state = state.copyWith(
        status: PodcastStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = PodcastState();
  }
}

final podcastRepositoryProvider = Provider<PodcastRepository>((ref) {
  return PodcastRepositoryImpl();
});

final subscribePodcastUseCaseProvider = Provider<SubscribePodcastUseCase>((ref) {
  final repository = ref.watch(podcastRepositoryProvider);
  return SubscribePodcastUseCase(repository);
});

final unsubscribePodcastUseCaseProvider = Provider<UnsubscribePodcastUseCase>((ref) {
  final repository = ref.watch(podcastRepositoryProvider);
  return UnsubscribePodcastUseCase(repository);
});

final getSubscribedPodcastsUseCaseProvider = Provider<GetSubscribedPodcastsUseCase>((ref) {
  final repository = ref.watch(podcastRepositoryProvider);
  return GetSubscribedPodcastsUseCase(repository);
});

final getPodcastByIdUseCaseProvider = Provider<GetPodcastByIdUseCase>((ref) {
  final repository = ref.watch(podcastRepositoryProvider);
  return GetPodcastByIdUseCase(repository);
});

final getEpisodesByPodcastIdUseCaseProvider = Provider<GetEpisodesByPodcastIdUseCase>((ref) {
  final repository = ref.watch(podcastRepositoryProvider);
  return GetEpisodesByPodcastIdUseCase(repository);
});

final podcastProvider = StateNotifierProvider<PodcastNotifier, PodcastState>((ref) {
  return PodcastNotifier(
    subscribePodcastUseCase: ref.watch(subscribePodcastUseCaseProvider),
    unsubscribePodcastUseCase: ref.watch(unsubscribePodcastUseCaseProvider),
    getSubscribedPodcastsUseCase: ref.watch(getSubscribedPodcastsUseCaseProvider),
    getPodcastByIdUseCase: ref.watch(getPodcastByIdUseCaseProvider),
    getEpisodesByPodcastIdUseCase: ref.watch(getEpisodesByPodcastIdUseCaseProvider),
  );
});

final podcastStateProvider = Provider<PodcastState>((ref) {
  return ref.watch(podcastProvider);
});

final subscribedPodcastsProvider = Provider<List<Podcast>?>((ref) {
  final state = ref.watch(podcastProvider);
  return state.podcasts;
});

final currentPodcastProvider = Provider<Podcast?>((ref) {
  final state = ref.watch(podcastProvider);
  return state.podcast;
});

final episodesProvider = Provider<List<Episode>?>((ref) {
  final state = ref.watch(podcastProvider);
  return state.episodes;
});
