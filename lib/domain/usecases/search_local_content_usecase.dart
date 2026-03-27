import '../entities/search_result.dart';
import '../repositories/podcast_repository.dart';

class SearchLocalContentUseCase {
  final PodcastRepository _repository;

  SearchLocalContentUseCase(this._repository);

  Future<SearchResult> call(String keyword) async {
    try {
      final podcasts = await _repository.searchPodcasts(keyword);
      final episodes = await _repository.searchEpisodes(keyword);
      return SearchResult(podcasts: podcasts, episodes: episodes);
    } catch (e) {
      throw Exception('Failed to search local content: $e');
    }
  }
}
