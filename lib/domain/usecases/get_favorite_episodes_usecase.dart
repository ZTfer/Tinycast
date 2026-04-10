import '../entities/episode.dart';
import '../repositories/podcast_repository.dart';

class GetFavoriteEpisodesUseCase {
  final PodcastRepository _repository;

  GetFavoriteEpisodesUseCase(this._repository);

  Future<List<Episode>> call() async {
    try {
      final episodes = await _repository.getUnplayedEpisodes();
      return episodes
          .where((episode) => episode.isFavorite)
          .toList()
        ..sort((a, b) => b.pubDate.compareTo(a.pubDate));
    } catch (e) {
      throw Exception('Failed to get favorite episodes: $e');
    }
  }
}
