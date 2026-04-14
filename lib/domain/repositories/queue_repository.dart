import '../../data/models/queue_model.dart';

abstract class QueueRepository {
  Future<List<Queue>> getAll();
  Future<void> addToQueue(int episodeId);
  Future<void> removeFromQueue(int id);
  Future<void> clearQueue();
  Future<bool> isInQueue(int episodeId);
}
