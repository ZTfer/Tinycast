import '../entities/episode.dart';
import '../repositories/podcast_repository.dart';

class GetDownloadedEpisodesUseCase {
  final PodcastRepository _repository;

  GetDownloadedEpisodesUseCase(this._repository);

  Future<List<Episode>> call() async {
    try {
      return await _repository.getDownloadedEpisodes();
    } catch (e) {
      throw Exception('Failed to get downloaded episodes: $e');
    }
  }
}
