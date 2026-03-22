import '../entities/episode.dart';
import '../repositories/podcast_repository.dart';

class GetUnplayedEpisodesUseCase {
  final PodcastRepository _repository;

  GetUnplayedEpisodesUseCase(this._repository);

  Future<List<Episode>> call() async {
    try {
      return await _repository.getUnplayedEpisodes();
    } catch (e) {
      throw Exception('Failed to get unplayed episodes: $e');
    }
  }
}
