import 'package:tinycast/domain/entities/search_result.dart';
import 'package:tinycast/domain/repositories/podcast_repository.dart';

class SearchLocalContentUseCase {
  final PodcastRepository _repository;

  SearchLocalContentUseCase(this._repository);

  Future<SearchResult> call(String keyword) async {
    final podcasts = await _repository.searchPodcasts(keyword);
    final episodes = await _repository.searchEpisodes(keyword);
    return SearchResult(podcasts: podcasts, episodes: episodes);
  }
}
