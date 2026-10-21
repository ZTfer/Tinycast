import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/repositories/podcast_repository.dart';

class GetEpisodesByPodcastIdUseCase {
  final PodcastRepository _repository;

  GetEpisodesByPodcastIdUseCase(this._repository);

  Future<List<Episode>> call(int podcastId) async {
    if (podcastId <= 0) {
      throw ArgumentError('Podcast ID must be a positive integer');
    }

    return _repository.getEpisodesByPodcastId(podcastId);
  }
}
