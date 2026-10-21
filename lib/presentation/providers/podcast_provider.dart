import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/repositories/podcast_repository.dart';
import 'package:tinycast/domain/usecases/subscribe_podcast_usecase.dart';
import 'package:tinycast/domain/usecases/unsubscribe_podcast_usecase.dart';
import 'package:tinycast/domain/usecases/get_subscribed_podcasts_usecase.dart';
import 'package:tinycast/domain/usecases/get_podcast_by_id_usecase.dart';
import 'package:tinycast/domain/usecases/get_episodes_by_podcast_id_usecase.dart';
import 'package:tinycast/domain/usecases/get_latest_episodes_by_podcast_id_usecase.dart';
import 'package:tinycast/data/repositories/podcast_repository_impl.dart';
import 'package:tinycast/data/services/itunes_search_service.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/core/services/feed_refresh_scheduler.dart';

enum PodcastStatus { initial, loading, success, error }

class _NotProvided {
  const _NotProvided();
}

const _notProvided = _NotProvided();

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
    Object? errorMessage = _notProvided,
  }) {
    return PodcastState(
      status: status ?? this.status,
      podcast: podcast ?? this.podcast,
      podcasts: podcasts ?? this.podcasts,
      episodes: episodes ?? this.episodes,
      errorMessage: identical(errorMessage, _notProvided)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

final itunesSearchServiceProvider = Provider<ITunesSearchService>((ref) {
  return ITunesSearchService();
});

final podcastRepositoryProvider = Provider<PodcastRepository>((ref) {
  final itunesSearchService = ref.watch(itunesSearchServiceProvider);
  return PodcastRepositoryImpl(
    itunesSearchService: itunesSearchService,
  );
});

final subscribePodcastUseCaseProvider = Provider<SubscribePodcastUseCase>((
  ref,
) {
  final repository = ref.watch(podcastRepositoryProvider);
  return SubscribePodcastUseCase(repository);
});

final unsubscribePodcastUseCaseProvider = Provider<UnsubscribePodcastUseCase>((
  ref,
) {
  final repository = ref.watch(podcastRepositoryProvider);
  return UnsubscribePodcastUseCase(repository);
});

final getSubscribedPodcastsUseCaseProvider =
    Provider<GetSubscribedPodcastsUseCase>((ref) {
      final repository = ref.watch(podcastRepositoryProvider);
      return GetSubscribedPodcastsUseCase(repository);
    });

final getPodcastByIdUseCaseProvider = Provider<GetPodcastByIdUseCase>((ref) {
  final repository = ref.watch(podcastRepositoryProvider);
  return GetPodcastByIdUseCase(repository);
});

final getEpisodesByPodcastIdUseCaseProvider =
    Provider<GetEpisodesByPodcastIdUseCase>((ref) {
      final repository = ref.watch(podcastRepositoryProvider);
      return GetEpisodesByPodcastIdUseCase(repository);
    });

final getLatestEpisodesByPodcastIdUseCaseProvider =
    Provider<GetLatestEpisodesByPodcastIdUseCase>((ref) {
      final repository = ref.watch(podcastRepositoryProvider);
      return GetLatestEpisodesByPodcastIdUseCase(repository);
    });

class PodcastNotifier extends Notifier<PodcastState> {
  @override
  PodcastState build() {
    final subscription = FeedRefreshScheduler.instance.onRefreshCompleted.listen(
      (_) => loadSubscribedPodcasts(),
    );
    ref.onDispose(subscription.cancel);
    return PodcastState();
  }

  SubscribePodcastUseCase get _subscribePodcastUseCase =>
      ref.read(subscribePodcastUseCaseProvider);
  UnsubscribePodcastUseCase get _unsubscribePodcastUseCase =>
      ref.read(unsubscribePodcastUseCaseProvider);
  GetSubscribedPodcastsUseCase get _getSubscribedPodcastsUseCase =>
      ref.read(getSubscribedPodcastsUseCaseProvider);
  GetPodcastByIdUseCase get _getPodcastByIdUseCase =>
      ref.read(getPodcastByIdUseCaseProvider);
  GetEpisodesByPodcastIdUseCase get _getEpisodesByPodcastIdUseCase =>
      ref.read(getEpisodesByPodcastIdUseCaseProvider);

  Future<void> subscribe(String rssUrl) async {
    state = state.copyWith(status: PodcastStatus.loading, errorMessage: null);
    try {
      final result = await _subscribePodcastUseCase(rssUrl);
      state = state.copyWith(
        status: PodcastStatus.success,
        podcast: result.podcast,
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
      state = state.copyWith(status: PodcastStatus.success, podcast: null);
    } catch (e) {
      state = state.copyWith(
        status: PodcastStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadSubscribedPodcasts() async {
    final stopwatch = Stopwatch()..start();
    final existingPodcasts = state.podcasts;
    Logger.info('🕒 [LIBRARY-PROVIDER] loadSubscribedPodcasts 开始, 现有数据 ${existingPodcasts?.length ?? 0} 个');
    
    // 立即设置 loading 状态并保留现有数据，防止 UI 显示空页面
    state = state.copyWith(status: PodcastStatus.loading, podcasts: existingPodcasts);
    
    try {
      final podcasts = await _getSubscribedPodcastsUseCase();
      Logger.info('🕒 [LIBRARY-PROVIDER] loadSubscribedPodcasts 数据库查询完成, 获取 ${podcasts.length} 个播客, 耗时 ${stopwatch.elapsedMilliseconds}ms');
      state = state.copyWith(status: PodcastStatus.success, podcasts: podcasts);
      Logger.info('🕒 [LIBRARY-PROVIDER] loadSubscribedPodcasts 完成, 总耗时 ${stopwatch.elapsedMilliseconds}ms');
    } catch (e, stackTrace) {
      Logger.error('🕒 [LIBRARY-PROVIDER] loadSubscribedPodcasts 失败: $e, 耗时 ${stopwatch.elapsedMilliseconds}ms', error: e, stackTrace: stackTrace);
      // 失败时保留现有数据
      state = state.copyWith(
        status: PodcastStatus.error,
        errorMessage: e.toString(),
        podcasts: existingPodcasts,
      );
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> loadPodcastById(int id) async {
    state = state.copyWith(status: PodcastStatus.loading, errorMessage: null);
    try {
      final podcast = await _getPodcastByIdUseCase(id);
      state = state.copyWith(status: PodcastStatus.success, podcast: podcast);
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
      state = state.copyWith(status: PodcastStatus.success, episodes: episodes);
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

final podcastProvider = NotifierProvider<PodcastNotifier, PodcastState>(
  PodcastNotifier.new,
);

final podcastStateProvider = Provider<PodcastState>((ref) {
  return ref.watch(podcastProvider);
});

final subscribedPodcastsProvider = Provider<List<Podcast>?>((ref) {
  final state = ref.watch(podcastProvider);
  // 仅在从未加载过时返回 null；加载完成但无订阅时返回空列表（供空状态页展示）
  if (state.podcasts == null) return null;
  if (state.podcasts!.isEmpty) return [];

  // 按订阅时间（createdAt）倒序排列，最新的在前面
  final sortedPodcasts = [...state.podcasts!];
  sortedPodcasts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sortedPodcasts;
});

/// 缓存的已订阅播客列表 - 避免每次重建都重新查询
final cachedSubscribedPodcastsProvider = FutureProvider<List<Podcast>>(
  (ref) async {
    final useCase = ref.watch(getSubscribedPodcastsUseCaseProvider);
    final podcasts = await useCase();

    // 按订阅时间倒序排列
    final sortedPodcasts = [...podcasts];
    sortedPodcasts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    Logger.info('📦 [PROVIDER] Cached subscribed podcasts: ${sortedPodcasts.length} items');
    return sortedPodcasts;
  },
  retry: (error, stackTrace) => null,
);

final currentPodcastProvider = Provider<Podcast?>((ref) {
  final state = ref.watch(podcastProvider);
  return state.podcast;
});

final episodesProvider = Provider<List<Episode>?>((ref) {
  final state = ref.watch(podcastProvider);
  return state.episodes;
});

/// 为每个播客提供最新3集剧集的 Provider
/// 使用 FutureProvider.family 来支持基于 podcastId 的参数化查询
final latestEpisodesProvider = FutureProvider.family<List<Episode>, int>(
  (ref, podcastId) async {
    final useCase = ref.watch(getLatestEpisodesByPodcastIdUseCaseProvider);
    return await useCase(podcastId, limit: 3);
  },
  retry: (error, stackTrace) => null,
);

/// 根据 ID 查询单个播客的 Provider
final podcastByIdProvider = FutureProvider.family<Podcast?, int>(
  (ref, id) async {
    final useCase = ref.watch(getPodcastByIdUseCaseProvider);
    return await useCase.call(id);
  },
  retry: (error, stackTrace) => null,
);
