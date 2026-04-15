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
  Future<void> addToQueue(int episodeId) async {
    Logger.info('📋 [QUEUE-REPO] addToQueue 调用, episodeId: $episodeId');
    await _dataSource.addToQueue(episodeId);
  }

  @override
  Future<void> insertToQueueFront(int episodeId) async {
    Logger.info('📋 [QUEUE-REPO] insertToQueueFront 调用, episodeId: $episodeId');
    await _dataSource.insertToQueueFront(episodeId);
  }

  @override
  Future<void> removeFromQueue(int id) async {
    Logger.info('📋 [QUEUE-REPO] removeFromQueue 调用, id: $id');
    await _dataSource.removeFromQueue(id);
  }

  @override
  Future<void> removeFromQueueByEpisodeId(int episodeId) async {
    Logger.info('📋 [QUEUE-REPO] removeFromQueueByEpisodeId 调用, episodeId: $episodeId');
    await _dataSource.removeFromQueueByEpisodeId(episodeId);
  }

  @override
  Future<void> clearQueue() async {
    Logger.info('📋 [QUEUE-REPO] clearQueue 调用');
    await _dataSource.clearQueue();
  }

  @override
  Future<bool> isInQueue(int episodeId) async {
    Logger.debug('📋 [QUEUE-REPO] isInQueue 调用, episodeId: $episodeId');
    return await _dataSource.isInQueue(episodeId);
  }
}
