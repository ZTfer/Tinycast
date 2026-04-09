import '../../domain/repositories/favorite_repository.dart';
import '../datasources/local_favorite_datasource.dart';
import '../../core/utils/logger.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final LocalFavoriteDataSource _dataSource;

  FavoriteRepositoryImpl({LocalFavoriteDataSource? dataSource})
    : _dataSource = dataSource ?? LocalFavoriteDataSource();

  @override
  Future<void> addFavorite(int episodeId) async {
    Logger.info('⭐ [FAVORITE-REPO] addFavorite 调用, episodeId: $episodeId');
    await _dataSource.addFavorite(episodeId);
  }

  @override
  Future<void> removeFavorite(int episodeId) async {
    Logger.info('⭐ [FAVORITE-REPO] removeFavorite 调用, episodeId: $episodeId');
    await _dataSource.removeFavorite(episodeId);
  }

  @override
  Future<bool> isFavorite(int episodeId) async {
    Logger.debug('⭐ [FAVORITE-REPO] isFavorite 调用, episodeId: $episodeId');
    return await _dataSource.isFavorite(episodeId);
  }

  @override
  Future<List<int>> getAllFavoriteEpisodeIds() async {
    Logger.info('⭐ [FAVORITE-REPO] getAllFavoriteEpisodeIds 调用');
    return await _dataSource.getAllFavoriteEpisodeIds();
  }
}
