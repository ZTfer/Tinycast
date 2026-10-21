import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/repositories/podcast_repository.dart';

class GetLatestEpisodesByPodcastIdUseCase {
  final PodcastRepository _repository;

  GetLatestEpisodesByPodcastIdUseCase(this._repository);

  Future<List<Episode>> call(int podcastId, {int limit = 3}) async {
    if (podcastId <= 0) {
      throw ArgumentError('Podcast ID must be a positive integer');
    }

    return _repository.getLatestEpisodesByPodcastId(
      podcastId,
      limit: limit,
    );
  }
}
