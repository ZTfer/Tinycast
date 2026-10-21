import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/repositories/podcast_repository.dart';
import 'package:tinycast/domain/repositories/favorite_repository.dart';

class GetFavoriteEpisodesUseCase {
  final PodcastRepository _podcastRepository;
  final FavoriteRepository _favoriteRepository;

  GetFavoriteEpisodesUseCase(this._podcastRepository, this._favoriteRepository);

  Future<List<Episode>> call() async {
    final favoriteEpisodeIds =
        await _favoriteRepository.getAllFavoriteEpisodeIds();

    if (favoriteEpisodeIds.isEmpty) {
      return [];
    }

    final episodes =
        await _podcastRepository.getEpisodesByIds(favoriteEpisodeIds);

    return episodes..sort((a, b) => b.pubDate.compareTo(a.pubDate));
  }
}
