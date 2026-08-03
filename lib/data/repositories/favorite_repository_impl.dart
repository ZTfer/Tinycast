import '../../domain/entities/episode.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/local_favorite_datasource.dart';
import '../../core/utils/app_exception.dart';
import '../../core/utils/logger.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final LocalFavoriteDataSource _dataSource;

  FavoriteRepositoryImpl({LocalFavoriteDataSource? dataSource})
    : _dataSource = dataSource ?? LocalFavoriteDataSource();

  @override
  Future<void> addFavorite(Episode episode) async {
    Logger.info('⭐ [FAVORITE-REPO] addFavorite 调用, episodeId: ${episode.id}');
    try {
      await _dataSource.addFavorite(episode);
    } catch (e, stackTrace) {
      Logger.error('[FAVORITE-REPO] 添加收藏失败, episodeId: ${episode.id}',
          error: e, stackTrace: stackTrace);
      throw AppException.storage('添加收藏失败',
          originalError: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> removeFavorite(Episode episode) async {
    Logger.info('⭐ [FAVORITE-REPO] removeFavorite 调用, episodeId: ${episode.id}');
    try {
      await _dataSource.removeFavorite(episode);
    } catch (e, stackTrace) {
      Logger.error('[FAVORITE-REPO] 取消收藏失败, episodeId: ${episode.id}',
          error: e, stackTrace: stackTrace);
      throw AppException.storage('取消收藏失败',
          originalError: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<bool> isFavorite(Episode episode) async {
    Logger.debug('⭐ [FAVORITE-REPO] isFavorite 调用, episodeId: ${episode.id}');
    try {
      return await _dataSource.isFavorite(episode);
    } catch (e, stackTrace) {
      Logger.error('[FAVORITE-REPO] 查询收藏状态失败, episodeId: ${episode.id}',
          error: e, stackTrace: stackTrace);
      throw AppException.storage('查询收藏状态失败',
          originalError: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<List<int>> getAllFavoriteEpisodeIds() async {
    Logger.info('⭐ [FAVORITE-REPO] getAllFavoriteEpisodeIds 调用');
    try {
      return await _dataSource.getAllFavoriteEpisodeIds();
    } catch (e, stackTrace) {
      Logger.error('[FAVORITE-REPO] 获取收藏列表失败',
          error: e, stackTrace: stackTrace);
      throw AppException.storage('获取收藏列表失败',
          originalError: e, stackTrace: stackTrace);
    }
  }
}
