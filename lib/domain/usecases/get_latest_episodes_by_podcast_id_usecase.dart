import '../entities/episode.dart';
import '../repositories/podcast_repository.dart';

class GetLatestEpisodesByPodcastIdUseCase {
  final PodcastRepository _repository;

  GetLatestEpisodesByPodcastIdUseCase(this._repository);

  Future<List<Episode>> call(int podcastId, {int limit = 3}) async {
    if (podcastId <= 0) {
      throw ArgumentError('Podcast ID must be a positive integer');
    }

    try {
      return await _repository.getLatestEpisodesByPodcastId(
        podcastId,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Failed to get latest episodes by podcast ID: $e');
    }
  }
}
