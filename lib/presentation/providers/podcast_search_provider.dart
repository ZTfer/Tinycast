import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/podcast.dart';
import '../../domain/entities/episode.dart';
import '../../data/services/podcast_search_service.dart';
import '../../domain/repositories/podcast_repository.dart';
import '../../domain/usecases/subscribe_podcast_usecase.dart';
import '../../domain/usecases/get_subscribed_podcasts_usecase.dart';
import '../../data/repositories/podcast_repository_impl.dart';

enum PodcastSearchStatus { idle, loading, success, error }

class PodcastSearchState {
  final PodcastSearchStatus status;
  final Podcast? podcast;
  final List<Podcast>? searchResults;
  final List<Episode>? episodes;
  final String? errorMessage;
  final Map<String, bool> addingStatus;

  PodcastSearchState({
    this.status = PodcastSearchStatus.idle,
    this.podcast,
    this.searchResults,
    this.episodes,
    this.errorMessage,
    Map<String, bool>? addingStatus,
  }) : addingStatus = addingStatus ?? {};

  PodcastSearchState copyWith({
    PodcastSearchStatus? status,
    Podcast? podcast,
    List<Podcast>? searchResults,
    List<Episode>? episodes,
    String? errorMessage,
    Map<String, bool>? addingStatus,
  }) {
    return PodcastSearchState(
      status: status ?? this.status,
      podcast: podcast ?? this.podcast,
      searchResults: searchResults ?? this.searchResults,
      episodes: episodes ?? this.episodes,
      errorMessage: errorMessage ?? this.errorMessage,
      addingStatus: addingStatus ?? this.addingStatus,
    );
  }
}

class PodcastSearchNotifier extends StateNotifier<PodcastSearchState> {
  final PodcastSearchService _podcastSearchService;
  final SubscribePodcastUseCase _subscribePodcastUseCase;
  final GetSubscribedPodcastsUseCase _getSubscribedPodcastsUseCase;
  List<Podcast> _subscribedPodcasts = [];

  PodcastSearchNotifier({
    required PodcastSearchService podcastSearchService,
    required SubscribePodcastUseCase subscribePodcastUseCase,
    required GetSubscribedPodcastsUseCase getSubscribedPodcastsUseCase,
  }) : _podcastSearchService = podcastSearchService,
       _subscribePodcastUseCase = subscribePodcastUseCase,
       _getSubscribedPodcastsUseCase = getSubscribedPodcastsUseCase,
       super(PodcastSearchState());

  Future<void> searchPodcast(String url) async {
    state = state.copyWith(
      status: PodcastSearchStatus.loading,
      errorMessage: null,
    );
    try {
      final result = await _podcastSearchService.searchPodcast(url);
      final podcast = result['podcast'] as Podcast;
      final episodes = result['episodes'] as List<Episode>;

      await _loadSubscribedPodcasts();

      state = state.copyWith(
        status: PodcastSearchStatus.success,
        podcast: podcast,
        searchResults: [podcast],
        episodes: episodes,
      );
    } catch (e) {
      state = state.copyWith(
        status: PodcastSearchStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> addPodcast(Podcast podcast) async {
    final rssUrl = podcast.rssUrl;

    if (_isPodcastSubscribed(rssUrl)) {
      return;
    }

    state = state.copyWith(addingStatus: {...state.addingStatus, rssUrl: true});

    try {
      await _subscribePodcastUseCase(rssUrl);
      await _loadSubscribedPodcasts();

      state = state.copyWith(
        addingStatus: {...state.addingStatus, rssUrl: false},
      );
    } catch (e) {
      state = state.copyWith(
        addingStatus: {...state.addingStatus, rssUrl: false},
      );
      rethrow;
    }
  }

  Future<void> addAllPodcasts() async {
    final podcasts = state.searchResults ?? [];
    if (podcasts.isEmpty) {
      return;
    }

    for (final podcast in podcasts) {
      final rssUrl = podcast.rssUrl;

      if (_isPodcastSubscribed(rssUrl)) {
        continue;
      }

      state = state.copyWith(
        addingStatus: {...state.addingStatus, rssUrl: true},
      );

      try {
        await _subscribePodcastUseCase(rssUrl);
        state = state.copyWith(
          addingStatus: {...state.addingStatus, rssUrl: false},
        );
      } catch (e) {
        state = state.copyWith(
          addingStatus: {...state.addingStatus, rssUrl: false},
        );
      }
    }

    await _loadSubscribedPodcasts();
  }

  bool isPodcastSubscribed(String rssUrl) {
    return _isPodcastSubscribed(rssUrl);
  }

  bool _isPodcastSubscribed(String rssUrl) {
    return _subscribedPodcasts.any((p) => p.rssUrl == rssUrl);
  }

  Future<void> _loadSubscribedPodcasts() async {
    try {
      _subscribedPodcasts = await _getSubscribedPodcastsUseCase();
    } catch (e) {
      _subscribedPodcasts = [];
    }
  }

  void reset() {
    state = PodcastSearchState();
  }
}

final podcastSearchServiceProvider = Provider<PodcastSearchService>((ref) {
  return PodcastSearchService();
});

final podcastSearchRepositoryProvider = Provider<PodcastRepository>((ref) {
  return PodcastRepositoryImpl();
});

final podcastSearchSubscribeUseCaseProvider = Provider<SubscribePodcastUseCase>(
  (ref) {
    final repository = ref.watch(podcastSearchRepositoryProvider);
    return SubscribePodcastUseCase(repository);
  },
);

final podcastSearchGetSubscribedPodcastsUseCaseProvider =
    Provider<GetSubscribedPodcastsUseCase>((ref) {
      final repository = ref.watch(podcastSearchRepositoryProvider);
      return GetSubscribedPodcastsUseCase(repository);
    });

final podcastSearchProvider =
    StateNotifierProvider<PodcastSearchNotifier, PodcastSearchState>((ref) {
      return PodcastSearchNotifier(
        podcastSearchService: ref.watch(podcastSearchServiceProvider),
        subscribePodcastUseCase: ref.watch(
          podcastSearchSubscribeUseCaseProvider,
        ),
        getSubscribedPodcastsUseCase: ref.watch(
          podcastSearchGetSubscribedPodcastsUseCaseProvider,
        ),
      );
    });

final podcastSearchStateProvider = Provider<PodcastSearchState>((ref) {
  return ref.watch(podcastSearchProvider);
});

final podcastSearchResultsProvider = Provider<List<Podcast>?>((ref) {
  final state = ref.watch(podcastSearchProvider);
  return state.searchResults;
});

final podcastSearchEpisodesProvider = Provider<List<Episode>?>((ref) {
  final state = ref.watch(podcastSearchProvider);
  return state.episodes;
});

final podcastSearchAddingStatusProvider = Provider<Map<String, bool>>((ref) {
  final state = ref.watch(podcastSearchProvider);
  return state.addingStatus;
});
