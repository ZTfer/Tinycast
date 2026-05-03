import '../entities/episode.dart';

abstract class FavoriteRepository {
  Future<void> addFavorite(Episode episode);
  Future<void> removeFavorite(Episode episode);
  Future<bool> isFavorite(Episode episode);
  Future<List<int>> getAllFavoriteEpisodeIds();
}
