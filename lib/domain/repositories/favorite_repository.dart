abstract class FavoriteRepository {
  Future<void> addFavorite(int episodeId);
  Future<void> removeFavorite(int episodeId);
  Future<bool> isFavorite(int episodeId);
  Future<List<int>> getAllFavoriteEpisodeIds();
}
