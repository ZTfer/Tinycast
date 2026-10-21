import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/queue_item.dart';
import 'package:tinycast/domain/repositories/queue_repository.dart';
import 'package:tinycast/data/datasources/local_queue_datasource.dart';
import 'package:tinycast/core/utils/app_exception.dart';
import 'package:tinycast/core/utils/logger.dart';

class QueueRepositoryImpl implements QueueRepository {
  final LocalQueueDataSource _dataSource;

  QueueRepositoryImpl({LocalQueueDataSource? dataSource})
    : _dataSource = dataSource ?? LocalQueueDataSource();

  @override
  Future<List<QueueItem>> getAll() async {
    Logger.info('📋 [QUEUE-REPO] getAll 调用');
    try {
      final queues = await _dataSource.getAll();
      return queues
          .map(
            (q) => QueueItem(
              id: q.id,
              supabaseId: q.supabaseId,
              episodeId: q.episodeId,
              episodeGuid: q.episodeGuid,
              episodeITunesId: q.episodeITunesId,
              podcastId: q.podcastId,
              podcastGuid: q.podcastGuid,
              podcastITunesId: q.podcastITunesId,
              position: q.position,
              addedAt: q.addedAt,
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      Logger.error('[QUEUE-REPO] 获取队列失败', error: e, stackTrace: stackTrace);
      throw AppException.storage('获取队列失败',
          originalError: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> addToQueue(Episode episode) async {
    Logger.info('📋 [QUEUE-REPO] addToQueue 调用, episodeId: ${episode.id}');
    try {
      await _dataSource.addToQueue(episode);
    } catch (e, stackTrace) {
      Logger.error('[QUEUE-REPO] 加入队列失败, episodeId: ${episode.id}',
          error: e, stackTrace: stackTrace);
      throw AppException.storage('加入队列失败',
          originalError: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> insertToQueueFront(Episode episode) async {
    Logger.info('📋 [QUEUE-REPO] insertToQueueFront 调用, episodeId: ${episode.id}');
    try {
      await _dataSource.insertToQueueFront(episode);
    } catch (e, stackTrace) {
      Logger.error('[QUEUE-REPO] 插入队列头部失败, episodeId: ${episode.id}',
          error: e, stackTrace: stackTrace);
      throw AppException.storage('插入队列头部失败',
          originalError: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> removeFromQueue(int id) async {
    Logger.info('📋 [QUEUE-REPO] removeFromQueue 调用, id: $id');
    try {
      await _dataSource.removeFromQueue(id);
    } catch (e, stackTrace) {
      Logger.error('[QUEUE-REPO] 从队列移除失败, id: $id',
          error: e, stackTrace: stackTrace);
      throw AppException.storage('从队列移除失败',
          originalError: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> removeFromQueueByEpisode(Episode episode) async {
    Logger.info('📋 [QUEUE-REPO] removeFromQueueByEpisode 调用, episodeId: ${episode.id}');
    try {
      await _dataSource.removeFromQueueByEpisode(episode);
    } catch (e, stackTrace) {
      Logger.error('[QUEUE-REPO] 按 episode 移除队列失败, episodeId: ${episode.id}',
          error: e, stackTrace: stackTrace);
      throw AppException.storage('按 episode 移除队列失败',
          originalError: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> clearQueue() async {
    Logger.info('📋 [QUEUE-REPO] clearQueue 调用');
    try {
      await _dataSource.clearQueue();
    } catch (e, stackTrace) {
      Logger.error('[QUEUE-REPO] 清空队列失败', error: e, stackTrace: stackTrace);
      throw AppException.storage('清空队列失败',
          originalError: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> removeFromQueueByPodcast(int podcastId, {String? podcastGuid, String? podcastITunesId}) async {
    Logger.info('📋 [QUEUE-REPO] removeFromQueueByPodcast 调用, podcastId: $podcastId');
    try {
      await _dataSource.removeFromQueueByPodcastId(podcastId, podcastGuid: podcastGuid, podcastITunesId: podcastITunesId);
    } catch (e, stackTrace) {
      Logger.error('[QUEUE-REPO] 按播客移除队列失败, podcastId: $podcastId',
          error: e, stackTrace: stackTrace);
      throw AppException.storage('按播客移除队列失败',
          originalError: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<bool> isInQueue(Episode episode) async {
    Logger.debug('📋 [QUEUE-REPO] isInQueue 调用, episodeId: ${episode.id}');
    try {
      return await _dataSource.isInQueue(episode);
    } catch (e, stackTrace) {
      Logger.error('[QUEUE-REPO] 查询队列状态失败, episodeId: ${episode.id}',
          error: e, stackTrace: stackTrace);
      throw AppException.storage('查询队列状态失败',
          originalError: e, stackTrace: stackTrace);
    }
  }
}
