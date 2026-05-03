import '../../domain/entities/episode.dart';
import '../../domain/repositories/queue_repository.dart';
import '../datasources/local_queue_datasource.dart';
import '../models/queue_model.dart';
import '../../core/utils/logger.dart';

class QueueRepositoryImpl implements QueueRepository {
  final LocalQueueDataSource _dataSource;

  QueueRepositoryImpl({LocalQueueDataSource? dataSource})
    : _dataSource = dataSource ?? LocalQueueDataSource();

  @override
  Future<List<Queue>> getAll() async {
    Logger.info('📋 [QUEUE-REPO] getAll 调用');
    return await _dataSource.getAll();
  }

  @override
  Future<void> addToQueue(Episode episode) async {
    Logger.info('📋 [QUEUE-REPO] addToQueue 调用, episodeId: ${episode.id}');
    await _dataSource.addToQueue(episode);
  }

  @override
  Future<void> insertToQueueFront(Episode episode) async {
    Logger.info('📋 [QUEUE-REPO] insertToQueueFront 调用, episodeId: ${episode.id}');
    await _dataSource.insertToQueueFront(episode);
  }

  @override
  Future<void> removeFromQueue(int id) async {
    Logger.info('📋 [QUEUE-REPO] removeFromQueue 调用, id: $id');
    await _dataSource.removeFromQueue(id);
  }

  @override
  Future<void> removeFromQueueByEpisode(Episode episode) async {
    Logger.info('📋 [QUEUE-REPO] removeFromQueueByEpisode 调用, episodeId: ${episode.id}');
    await _dataSource.removeFromQueueByEpisode(episode);
  }

  @override
  Future<void> clearQueue() async {
    Logger.info('📋 [QUEUE-REPO] clearQueue 调用');
    await _dataSource.clearQueue();
  }

  @override
  Future<void> removeFromQueueByPodcast(int podcastId, {String? podcastGuid, String? podcastITunesId}) async {
    Logger.info('📋 [QUEUE-REPO] removeFromQueueByPodcast 调用, podcastId: $podcastId');
    await _dataSource.removeFromQueueByPodcastId(podcastId, podcastGuid: podcastGuid, podcastITunesId: podcastITunesId);
  }

  @override
  Future<bool> isInQueue(Episode episode) async {
    Logger.debug('📋 [QUEUE-REPO] isInQueue 调用, episodeId: ${episode.id}');
    return await _dataSource.isInQueue(episode);
  }
}
