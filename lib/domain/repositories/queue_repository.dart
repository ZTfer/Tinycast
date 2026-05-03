import '../../data/models/queue_model.dart';
import '../entities/episode.dart';

abstract class QueueRepository {
  Future<List<Queue>> getAll();
  Future<void> addToQueue(Episode episode);
  Future<void> insertToQueueFront(Episode episode);
  Future<void> removeFromQueue(int id);
  Future<void> removeFromQueueByEpisode(Episode episode);
  Future<void> removeFromQueueByPodcast(int podcastId, {String? podcastGuid, String? podcastITunesId});
  Future<void> clearQueue();
  Future<bool> isInQueue(Episode episode);
}
