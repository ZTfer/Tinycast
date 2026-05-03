import '../../domain/entities/episode.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/local_favorite_datasource.dart';
import '../../core/utils/logger.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final LocalFavoriteDataSource _dataSource;

  FavoriteRepositoryImpl({LocalFavoriteDataSource? dataSource})
    : _dataSource = dataSource ?? LocalFavoriteDataSource();

  @override
  Future<void> addFavorite(Episode episode) async {
    Logger.info('⭐ [FAVORITE-REPO] addFavorite 调用, episodeId: ${episode.id}');
    await _dataSource.addFavorite(episode);
  }

  @override
  Future<void> removeFavorite(Episode episode) async {
    Logger.info('⭐ [FAVORITE-REPO] removeFavorite 调用, episodeId: ${episode.id}');
    await _dataSource.removeFavorite(episode);
  }

  @override
  Future<bool> isFavorite(Episode episode) async {
    Logger.debug('⭐ [FAVORITE-REPO] isFavorite 调用, episodeId: ${episode.id}');
    return await _dataSource.isFavorite(episode);
  }

  @override
  Future<List<int>> getAllFavoriteEpisodeIds() async {
    Logger.info('⭐ [FAVORITE-REPO] getAllFavoriteEpisodeIds 调用');
    return await _dataSource.getAllFavoriteEpisodeIds();
  }
}
