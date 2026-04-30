import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/podcast.dart';
import '../../../domain/entities/episode.dart';
import '../../../data/services/podcast_search_service.dart';
import '../../../data/services/audio_download_service.dart';
import '../../../data/services/settings_service.dart';
import '../../../domain/repositories/podcast_repository.dart';
import '../../../domain/usecases/subscribe_podcast_usecase.dart';
import '../../../domain/usecases/get_subscribed_podcasts_usecase.dart';
import '../../../data/repositories/podcast_repository_impl.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/app_settings.dart';
import '../../providers/podcast_provider.dart';
import '../../providers/unplayed_episodes_provider.dart';

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

class PodcastSearchNotifier extends Notifier<PodcastSearchState> {
  List<Podcast> _subscribedPodcasts = [];

  @override
  PodcastSearchState build() => PodcastSearchState();

  PodcastSearchService get _podcastSearchService =>
      ref.read(podcastSearchServiceProvider);
  SubscribePodcastUseCase get _subscribePodcastUseCase =>
      ref.read(podcastSearchSubscribeUseCaseProvider);
  GetSubscribedPodcastsUseCase get _getSubscribedPodcastsUseCase =>
      ref.read(podcastSearchGetSubscribedPodcastsUseCaseProvider);
  PodcastRepository get _repository =>
      ref.read(podcastRepositoryProvider);

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
    final stopwatch = Stopwatch()..start();
    final rssUrl = podcast.rssUrl;

    Logger.info('🕒 [LIBRARY] addPodcast 开始, rssUrl=$rssUrl');

    if (_isPodcastSubscribed(rssUrl)) {
      Logger.info('🕒 [LIBRARY] 播客已订阅，跳过');
      return;
    }

    state = state.copyWith(addingStatus: {...state.addingStatus, rssUrl: true});
    Logger.info('🕒 [LIBRARY] [${stopwatch.elapsedMilliseconds}ms] 设置 addingStatus=true');

    try {
      Logger.info('🕒 [LIBRARY] [${stopwatch.elapsedMilliseconds}ms] 开始调用 _subscribePodcastUseCase...');
      final subscribedPodcast = await _subscribePodcastUseCase(rssUrl);
      Logger.info('🕒 [LIBRARY] [${stopwatch.elapsedMilliseconds}ms] _subscribePodcastUseCase 完成');

      Logger.info('🕒 [LIBRARY] [${stopwatch.elapsedMilliseconds}ms] 开始调用 _loadSubscribedPodcasts...');
      await _loadSubscribedPodcasts();
      Logger.info('🕒 [LIBRARY] [${stopwatch.elapsedMilliseconds}ms] _loadSubscribedPodcasts 完成');

      // 通知 Library 页面刷新
      Logger.info('🕒 [LIBRARY] [${stopwatch.elapsedMilliseconds}ms] 调用 ref.invalidate(podcastProvider)');
      ref.invalidate(podcastProvider);
      Logger.info('🕒 [LIBRARY] [${stopwatch.elapsedMilliseconds}ms] ref.invalidate 完成');

      // 通知"继续播放"列表刷新
      ref.invalidate(unplayedEpisodesNotifierProvider);

      // 根据自动下载策略执行下载（异步执行，不阻塞订阅流程）
      Logger.info('🕒 [LIBRARY] [${stopwatch.elapsedMilliseconds}ms] 调度自动下载任务');
      unawaited(_handleAutoDownload(subscribedPodcast));

      state = state.copyWith(
        addingStatus: {...state.addingStatus, rssUrl: false},
      );
      Logger.info('🕒 [LIBRARY] addPodcast 完成，总耗时: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.stop();
    } catch (e) {
      state = state.copyWith(
        addingStatus: {...state.addingStatus, rssUrl: false},
      );
      Logger.info('🕒 [LIBRARY] addPodcast 失败: $e');
      stopwatch.stop();
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

    // 通知 Library 页面刷新
    ref.invalidate(podcastProvider);
    // 通知"继续播放"列表刷新
    ref.invalidate(unplayedEpisodesNotifierProvider);
  }

  bool isPodcastSubscribed(String rssUrl) {
    return _isPodcastSubscribed(rssUrl);
  }

  bool _isPodcastSubscribed(String rssUrl) {
    return _subscribedPodcasts.any((p) => p.rssUrl == rssUrl);
  }

  Future<void> _loadSubscribedPodcasts() async {
    final stopwatch = Stopwatch()..start();
    Logger.info('🕒 [LIBRARY] _loadSubscribedPodcasts 开始');
    try {
      _subscribedPodcasts = await _getSubscribedPodcastsUseCase();
      Logger.info('🕒 [LIBRARY] _loadSubscribedPodcasts 完成, 获取 ${_subscribedPodcasts.length} 个播客, 耗时 ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.stop();
    } catch (e) {
      Logger.info('🕒 [LIBRARY] _loadSubscribedPodcasts 失败: $e');
      stopwatch.stop();
      _subscribedPodcasts = [];
    }
  }

  void reset() {
    state = PodcastSearchState();
  }

  Future<void> _handleAutoDownload(Podcast podcast) async {
    try {
      final settings = await SettingsService.instance.loadSettings();
      final policy = settings.autoDownloadPolicy;

      if (policy == AutoDownloadPolicy.off) {
        Logger.info('⬇️ [AUTO-DOWNLOAD] 自动下载策略为关闭，跳过');
        return;
      }

      final podcastId = podcast.id;
      Logger.info('⬇️ [AUTO-DOWNLOAD] 策略: ${policy.name}, 播客ID: $podcastId');

      switch (policy) {
        case AutoDownloadPolicy.latest1:
          await AudioDownloadService.instance.downloadPodcastEpisodes(
            podcastId,
            limit: 1,
          );
          break;
        case AutoDownloadPolicy.latest2:
          await AudioDownloadService.instance.downloadPodcastEpisodes(
            podcastId,
            limit: 2,
          );
          break;
        case AutoDownloadPolicy.latest3:
          await AudioDownloadService.instance.downloadPodcastEpisodes(
            podcastId,
            limit: 3,
          );
          break;
        case AutoDownloadPolicy.latest5:
          await AudioDownloadService.instance.downloadPodcastEpisodes(
            podcastId,
            limit: 5,
          );
          break;
        case AutoDownloadPolicy.latest10:
          await AudioDownloadService.instance.downloadPodcastEpisodes(
            podcastId,
            limit: 10,
          );
          break;
        case AutoDownloadPolicy.past24h:
          await _downloadEpisodesByTimeRange(podcastId, hours: 24);
          break;
        case AutoDownloadPolicy.past7d:
          await _downloadEpisodesByTimeRange(podcastId, days: 7);
          break;
        case AutoDownloadPolicy.past14d:
          await _downloadEpisodesByTimeRange(podcastId, days: 14);
          break;
        case AutoDownloadPolicy.past30d:
          await _downloadEpisodesByTimeRange(podcastId, days: 30);
          break;
        case AutoDownloadPolicy.all:
          await AudioDownloadService.instance.downloadPodcastEpisodes(podcastId);
          break;
        case AutoDownloadPolicy.off:
          break;
      }
    } catch (e, stackTrace) {
      Logger.error('⬇️ [AUTO-DOWNLOAD] 自动下载失败', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _downloadEpisodesByTimeRange(
    int podcastId, {
    int? hours,
    int? days,
  }) async {
    // 计算截止时间点（注意：DateTime.subtract 返回新对象，不修改原对象）
    DateTime cutoffDate;
    if (hours != null) {
      cutoffDate = DateTime.now().subtract(Duration(hours: hours));
    } else if (days != null) {
      cutoffDate = DateTime.now().subtract(Duration(days: days));
    } else {
      Logger.info('⬇️ [AUTO-DOWNLOAD] 时间范围策略，未指定时间范围，跳过');
      return;
    }

    Logger.info('⬇️ [AUTO-DOWNLOAD] 时间范围策略，截止时间: $cutoffDate');

    final allEpisodes = await _repository.getEpisodesByPodcastId(podcastId);
    Logger.info('⬇️ [AUTO-DOWNLOAD] 总集数: ${allEpisodes.length}');

    final toDownload = allEpisodes.where((episode) {
      return episode.pubDate.isAfter(cutoffDate);
    }).toList();

    if (toDownload.isNotEmpty) {
      Logger.info('⬇️ [AUTO-DOWNLOAD] 时间范围策略，找到 ${toDownload.length} 集');
      for (final episode in toDownload) {
        Logger.info('⬇️ [AUTO-DOWNLOAD] 准备下载: ${episode.title}, pubDate: ${episode.pubDate}');
        unawaited(
          AudioDownloadService.instance.downloadEpisodeById(episode.id),
        );
      }
    } else {
      Logger.info('⬇️ [AUTO-DOWNLOAD] 时间范围策略，没有符合条件的集数');
    }
  }
}

final podcastSearchProvider =
    NotifierProvider<PodcastSearchNotifier, PodcastSearchState>(
      PodcastSearchNotifier.new,
    );

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
