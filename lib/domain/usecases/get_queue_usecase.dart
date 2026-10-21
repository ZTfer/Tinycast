import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/repositories/podcast_repository.dart';
import 'package:tinycast/domain/repositories/queue_repository.dart';

class GetQueueUseCase {
  final QueueRepository _queueRepository;
  final PodcastRepository _podcastRepository;

  GetQueueUseCase(this._queueRepository, this._podcastRepository);

  Future<List<Episode>> call() async {
    final queueItems = await _queueRepository.getAll();

    if (queueItems.isEmpty) {
      return [];
    }

    final episodeIds = queueItems.map((item) => item.episodeId).toList();
    final episodes = await _podcastRepository.getEpisodesByIds(episodeIds);

    final episodeMap = {for (var ep in episodes) ep.id: ep};

    return queueItems
        .where((item) => episodeMap.containsKey(item.episodeId))
        .map((item) => episodeMap[item.episodeId]!)
        .toList();
  }
}
