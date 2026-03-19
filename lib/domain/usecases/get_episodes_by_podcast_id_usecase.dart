import '../entities/episode.dart';
import '../repositories/podcast_repository.dart';

class GetEpisodesByPodcastIdUseCase {
  final PodcastRepository _repository;

  GetEpisodesByPodcastIdUseCase(this._repository);

  Future<List<Episode>> call(int podcastId) async {
    if (podcastId <= 0) {
      throw ArgumentError('Podcast ID must be a positive integer');
    }

    try {
      return await _repository.getEpisodesByPodcastId(podcastId);
    } catch (e) {
      throw Exception('Failed to get episodes by podcast ID: $e');
    }
  }
}
