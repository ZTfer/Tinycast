import '../../core/utils/logger.dart';
import '../../domain/entities/podcast.dart';
import '../../domain/entities/episode.dart';
import '../datasources/remote_podcast_datasource.dart';
import '../datasources/local_podcast_datasource.dart';
import '../mappers/podcast_mapper.dart';
import '../mappers/episode_mapper.dart';

class FeedRefreshResult {
  final int podcastId;
  final int newEpisodesCount;
  final bool success;
  final String? error;

  FeedRefreshResult({
    required this.podcastId,
    this.newEpisodesCount = 0,
    this.success = false,
    this.error,
  });

  @override
  String toString() {
    if (success) {
      return 'FeedRefreshResult{podcastId: $podcastId, newEpisodes: $newEpisodesCount}';
    } else {
      return 'FeedRefreshResult{podcastId: $podcastId, error: $error}';
    }
  }
}

class BatchRefreshResult {
  final int totalNewEpisodes;
  final int successCount;
  final int failureCount;
  final List<FeedRefreshResult> results;

  BatchRefreshResult({
    this.totalNewEpisodes = 0,
    this.successCount = 0,
    this.failureCount = 0,
    required this.results,
  });

  @override
  String toString() {
    return 'BatchRefreshResult{totalNew: $totalNewEpisodes, success: $successCount, failures: $failureCount}';
  }
}

class FeedRefreshService {
  static const _cooldownDuration = Duration(minutes: 5);
  static const _degradationThreshold = 3;
  static const _degradationMultiplier = 3;
  static const _maxConcurrentRefreshes = 3;

  final RemotePodcastDataSource _remoteDataSource;
  final LocalPodcastDataSource _localDataSource;
  final Map<int, DateTime> _lastRefreshTimes = {};

  FeedRefreshService._()
    : _remoteDataSource = RemotePodcastDataSource(),
      _localDataSource = LocalPodcastDataSource();

  static final FeedRefreshService _instance = FeedRefreshService._();
  static FeedRefreshService get instance => _instance;

  FeedRefreshService({
    RemotePodcastDataSource? remoteDataSource,
    LocalPodcastDataSource? localDataSource,
  }) : _remoteDataSource = remoteDataSource ?? RemotePodcastDataSource(),
       _localDataSource = localDataSource ?? LocalPodcastDataSource();

  Future<FeedRefreshResult> refreshSingleFeed(int podcastId) async {
    try {
      final now = DateTime.now();
      final lastRefresh = _lastRefreshTimes[podcastId];
      if (lastRefresh != null && now.difference(lastRefresh) < _cooldownDuration) {
        Logger.info('播客 $podcastId 刷新冷却中，跳过');
        return FeedRefreshResult(podcastId: podcastId, success: true);
      }

      _lastRefreshTimes[podcastId] = now;

      final podcastModel = await _localDataSource.getPodcastById(podcastId);
      if (podcastModel == null || podcastModel.rssUrl.isEmpty) {
        Logger.warning('播客 $podcastId 不存在或无 RSS URL');
        return FeedRefreshResult(
          podcastId: podcastId,
          error: '播客不存在或无 RSS URL',
        );
      }

      if (podcastModel.refreshFailedCount >= _degradationThreshold) {
        Logger.warning(
          '播客 $podcastId 刷新失败次数达 ${podcastModel.refreshFailedCount}，'
          '进入退化模式，延长刷新间隔',
        );
        final lastFetched = podcastModel.lastFetchedAt;
        if (lastFetched != null) {
          final extendedInterval = Duration(
            minutes: _cooldownDuration.inMinutes * _degradationMultiplier,
          );
          if (now.difference(lastFetched) < extendedInterval) {
            Logger.info('播客 $podcastId 退化模式中，跳过刷新');
            return FeedRefreshResult(podcastId: podcastId, success: true);
          }
        }
      }

      final podcastEntity = PodcastMapper.toEntity(podcastModel);

      final rssResult = await _remoteDataSource.getPodcastFromRss(podcastEntity.rssUrl);
      final remoteEpisodes = rssResult['episodes'] as List<Episode>;

      final existingGuids = await _localDataSource.getExistingEpisodeGuids(podcastId);

      final newEpisodes = remoteEpisodes.where((ep) {
        final guid = ep.guid;
        return guid != null && guid.isNotEmpty && !existingGuids.contains(guid);
      }).toList();

      if (newEpisodes.isNotEmpty) {
        final episodeModels = newEpisodes.map((ep) {
          final model = EpisodeMapper.toModel(ep);
          model.podcastId = podcastId;
          return model;
        }).toList();

        await _localDataSource.bulkInsertNewEpisodes(episodeModels);

        final updatedCount = podcastEntity.episodeCount + newEpisodes.length;
        await _localDataSource.updatePodcastEpisodeCount(podcastId, updatedCount);

        Logger.info('播客 $podcastId 新增 ${newEpisodes.length} 个剧集，总数更新为 $updatedCount');
      }

      await _localDataSource.updateLastFetchedAt(podcastId, now);

      if (podcastModel.refreshFailedCount > 0) {
        await _localDataSource.updateRefreshFailedCount(podcastId, 0);
      }

      Logger.info('播客 $podcastId 刷新成功');

      return FeedRefreshResult(
        podcastId: podcastId,
        newEpisodesCount: newEpisodes.length,
        success: true,
      );
    } catch (e, stackTrace) {
      Logger.error(
        '播客 $podcastId 刷新失败',
        error: e,
        stackTrace: stackTrace,
      );

      final podcastModel = await _localDataSource.getPodcastById(podcastId);
      if (podcastModel != null) {
        final newFailedCount = podcastModel.refreshFailedCount + 1;
        await _localDataSource.updateRefreshFailedCount(podcastId, newFailedCount);
        await _localDataSource.updateLastFetchedAt(podcastId, DateTime.now());
        Logger.info(
          '播客 $podcastId 刷新失败次数更新为 $newFailedCount',
        );
      }

      return FeedRefreshResult(
        podcastId: podcastId,
        error: e.toString(),
      );
    }
  }

  Future<BatchRefreshResult> refreshAllFeeds(List<Podcast> podcasts) async {
    if (podcasts.isEmpty) {
      return BatchRefreshResult(results: []);
    }

    Logger.info('开始批量刷新 ${podcasts.length} 个播客');

    final results = <FeedRefreshResult>[];
    
    for (var i = 0; i < podcasts.length; i += _maxConcurrentRefreshes) {
      final end = (i + _maxConcurrentRefreshes < podcasts.length) 
          ? i + _maxConcurrentRefreshes 
          : podcasts.length;
      final chunk = podcasts.sublist(i, end);
      final futures = chunk.map((podcast) => refreshSingleFeed(podcast.id));
      final chunkResults = await Future.wait<FeedRefreshResult>(futures);
      results.addAll(chunkResults);
    }

    final successCount = results.where((r) => r.success).length;
    final failureCount = results.length - successCount;
    final totalNewEpisodes = results.fold<int>(0, (sum, r) => sum + r.newEpisodesCount);

    Logger.info(
      '批量刷新完成: 总数 ${results.length}, 成功 $successCount, '
      '失败 $failureCount, 新剧集 $totalNewEpisodes',
    );

    return BatchRefreshResult(
      totalNewEpisodes: totalNewEpisodes,
      successCount: successCount,
      failureCount: failureCount,
      results: results,
    );
  }
}