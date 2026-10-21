import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/feed_refresh_result.dart';
export '../../domain/entities/feed_refresh_result.dart'
    show FeedRefreshResult, BatchRefreshResult;
import 'package:tinycast/data/datasources/remote_podcast_datasource.dart';
import 'package:tinycast/data/datasources/local_podcast_datasource.dart';
import 'package:tinycast/data/mappers/podcast_mapper.dart';
import 'package:tinycast/data/mappers/episode_mapper.dart';

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

  Future<FeedRefreshResult> refreshSingleFeed(int podcastId, {bool force = false}) async {
    try {
      final now = DateTime.now();
      final lastRefresh = _lastRefreshTimes[podcastId];
      if (!force && lastRefresh != null && now.difference(lastRefresh) < _cooldownDuration) {
        final remaining = _cooldownDuration.inSeconds - now.difference(lastRefresh).inSeconds;
        Logger.info('🔄 [REFRESH] 播客 $podcastId 刷新冷却中，剩余 $remaining秒，跳过');
        return FeedRefreshResult(podcastId: podcastId, skipped: true);
      }

      final podcastModel = await _localDataSource.getPodcastById(podcastId);
      if (podcastModel == null || podcastModel.rssUrl.isEmpty) {
        Logger.warning('🔄 [REFRESH] 播客 $podcastId 不存在或无 RSS URL');
        return FeedRefreshResult(
          podcastId: podcastId,
          error: '播客不存在或无 RSS URL',
        );
      }

      Logger.info('🔄 [REFRESH] 开始刷新播客: ${podcastModel.title}, RSS: ${podcastModel.rssUrl}');

      if (podcastModel.refreshFailedCount >= _degradationThreshold) {
        Logger.warning(
          '🔄 [REFRESH] 播客 $podcastId 刷新失败次数达 ${podcastModel.refreshFailedCount}，'
          '进入退化模式，延长刷新间隔',
        );
        final lastFetched = podcastModel.lastFetchedAt;
        if (lastFetched != null) {
          final extendedInterval = Duration(
            minutes: _cooldownDuration.inMinutes * _degradationMultiplier,
          );
          if (now.difference(lastFetched) < extendedInterval) {
            Logger.info('🔄 [REFRESH] 播客 $podcastId 退化模式中，跳过刷新');
            return FeedRefreshResult(podcastId: podcastId, skipped: true);
          }
        }
      }

      final podcastEntity = PodcastMapper.toEntity(podcastModel);

      Logger.info('🔄 [REFRESH] 正在获取远程 RSS 数据: ${podcastEntity.rssUrl}');
      final rssResult = await _remoteDataSource.getPodcastFromRss(podcastEntity.rssUrl);
      final remoteEpisodes = rssResult['episodes'] as List<Episode>;
      Logger.info('🔄 [REFRESH] 远程 RSS 获取成功，共 ${remoteEpisodes.length} 个剧集');

      Logger.info('🔄 [REFRESH] 正在查询本地已存在的 GUID...');
      final existingGuids = await _localDataSource.getExistingEpisodeGuids(podcastId);
      Logger.info('🔄 [REFRESH] 本地已存在 ${existingGuids.length} 个剧集 GUID');

      // 统计新剧集和已存在剧集的详细信息
      final newEpisodes = <Episode>[];
      int skippedForExistingGuid = 0;
      int skippedForMissingGuid = 0;
      
      for (final ep in remoteEpisodes) {
        final guid = ep.guid;
        if (guid == null || guid.isEmpty) {
          skippedForMissingGuid++;
          Logger.warning('⚠️ [REFRESH] 剧集 "${ep.title}" GUID 为空，跳过');
          continue;
        }
        if (existingGuids.contains(guid)) {
          skippedForExistingGuid++;
          continue;
        }
        newEpisodes.add(ep);
      }

      Logger.info(
        '🔄 [REFRESH] 增量更新统计: '
        '远程 ${remoteEpisodes.length} 个, '
        '本地已存在 $skippedForExistingGuid 个, '
        'GUID 为空 $skippedForMissingGuid 个, '
        '新剧集 ${newEpisodes.length} 个',
      );

      if (newEpisodes.isNotEmpty) {
        final episodeModels = newEpisodes.map((ep) {
          final model = EpisodeMapper.toModel(ep);
          model.podcastId = podcastId;
          return model;
        }).toList();

        await _localDataSource.bulkInsertNewEpisodes(episodeModels);

        final updatedCount = podcastEntity.episodeCount + newEpisodes.length;
        await _localDataSource.updatePodcastEpisodeCount(podcastId, updatedCount);

        Logger.info('🔄 [REFRESH] 播客 $podcastId 新增 ${newEpisodes.length} 个剧集，总数更新为 $updatedCount');
      }

      await _localDataSource.updateLastFetchedAt(podcastId, now);

      if (podcastModel.refreshFailedCount > 0) {
        await _localDataSource.updateRefreshFailedCount(podcastId, 0);
      }

      // Only a completed refresh starts the cooldown; failures and
      // degraded skips must remain retryable.
      _lastRefreshTimes[podcastId] = now;

      Logger.info('🔄 [REFRESH] 播客 $podcastId 刷新成功');

      return FeedRefreshResult(
        podcastId: podcastId,
        newEpisodesCount: newEpisodes.length,
        success: true,
      );
    } catch (e, stackTrace) {
      Logger.error(
        '🔄 [REFRESH] 播客 $podcastId 刷新失败',
        error: e,
        stackTrace: stackTrace,
      );

      final podcastModel = await _localDataSource.getPodcastById(podcastId);
      if (podcastModel != null) {
        final newFailedCount = podcastModel.refreshFailedCount + 1;
        await _localDataSource.updateRefreshFailedCount(podcastId, newFailedCount);
        await _localDataSource.updateLastFetchedAt(podcastId, DateTime.now());
        Logger.info(
          '🔄 [REFRESH] 播客 $podcastId 刷新失败次数更新为 $newFailedCount',
        );
      }

      return FeedRefreshResult(
        podcastId: podcastId,
        error: e.toString(),
      );
    }
  }

  Future<BatchRefreshResult> refreshAllFeeds(List<Podcast> podcasts, {bool force = false}) async {
    if (podcasts.isEmpty) {
      return BatchRefreshResult(results: []);
    }

    Logger.info('🔄 [REFRESH] 开始批量刷新 ${podcasts.length} 个播客 (force: $force)');

    final results = <FeedRefreshResult>[];
    
    for (var i = 0; i < podcasts.length; i += _maxConcurrentRefreshes) {
      final end = (i + _maxConcurrentRefreshes < podcasts.length) 
          ? i + _maxConcurrentRefreshes 
          : podcasts.length;
      final chunk = podcasts.sublist(i, end);
      final futures = chunk.map((podcast) => refreshSingleFeed(podcast.id, force: force));
      final chunkResults = await Future.wait<FeedRefreshResult>(futures);
      results.addAll(chunkResults);
    }

    final successCount = results.where((r) => r.success).length;
    final skippedCount = results.where((r) => r.skipped).length;
    final failureCount =
        results.where((r) => !r.success && !r.skipped).length;
    final totalNewEpisodes = results.fold<int>(0, (sum, r) => sum + r.newEpisodesCount);

    Logger.info(
      '批量刷新完成: 总数 ${results.length}, 成功 $successCount, '
      '跳过 $skippedCount, 失败 $failureCount, 新剧集 $totalNewEpisodes',
    );

    return BatchRefreshResult(
      totalNewEpisodes: totalNewEpisodes,
      successCount: successCount,
      skippedCount: skippedCount,
      failureCount: failureCount,
      results: results,
    );
  }
}