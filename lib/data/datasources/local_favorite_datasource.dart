import 'package:isar_community/isar.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/app_exception.dart';
import '../database/isar_service.dart';
import '../models/favorite_model.dart';

class LocalFavoriteDataSource {
  final IsarService _isarService;

  LocalFavoriteDataSource({IsarService? isarService})
    : _isarService = isarService ?? IsarService.instance;

  /// 添加收藏
  Future<void> addFavorite(int episodeId) async {
    try {
      Logger.info('⭐ [FAVORITE-DS] 开始添加收藏, episodeId: $episodeId');

      final existing = await _isarService.isar.favorites
          .where()
          .episodeIdEqualTo(episodeId)
          .findFirst();

      if (existing != null) {
        Logger.warning('⭐ [FAVORITE-DS] episodeId: $episodeId 已存在于收藏中, 跳过添加');
        return;
      }

      final favorite = Favorite()..episodeId = episodeId;
      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.favorites.put(favorite);
      });

      Logger.info('⭐ [FAVORITE-DS] 收藏添加成功, episodeId: $episodeId, favoriteId: ${favorite.id}');
    } on IsarError catch (e, stackTrace) {
      Logger.error('⭐ [FAVORITE-DS] 添加收藏失败', error: e, stackTrace: stackTrace);
      throw AppException.storage('添加收藏失败', originalError: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      Logger.error('⭐ [FAVORITE-DS] 添加收藏异常', error: e, stackTrace: stackTrace);
      throw AppException.unknown('添加收藏失败', originalError: e, stackTrace: stackTrace);
    }
  }

  /// 移除收藏
  Future<void> removeFavorite(int episodeId) async {
    try {
      Logger.info('⭐ [FAVORITE-DS] 开始移除收藏, episodeId: $episodeId');

      final existing = await _isarService.isar.favorites
          .where()
          .episodeIdEqualTo(episodeId)
          .findFirst();

      if (existing == null) {
        Logger.warning('⭐ [FAVORITE-DS] episodeId: $episodeId 不在收藏中, 跳过移除');
        return;
      }

      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.favorites.delete(existing.id);
      });

      Logger.info('⭐ [FAVORITE-DS] 收藏移除成功, episodeId: $episodeId');
    } on IsarError catch (e, stackTrace) {
      Logger.error('⭐ [FAVORITE-DS] 移除收藏失败', error: e, stackTrace: stackTrace);
      throw AppException.storage('移除收藏失败', originalError: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      Logger.error('⭐ [FAVORITE-DS] 移除收藏异常', error: e, stackTrace: stackTrace);
      throw AppException.unknown('移除收藏失败', originalError: e, stackTrace: stackTrace);
    }
  }

  /// 检查是否已收藏
  Future<bool> isFavorite(int episodeId) async {
    try {
      Logger.debug('⭐ [FAVORITE-DS] 检查收藏状态, episodeId: $episodeId');

      final count = await _isarService.isar.favorites
          .where()
          .episodeIdEqualTo(episodeId)
          .count();

      final isFav = count > 0;
      Logger.debug('⭐ [FAVORITE-DS] 收藏状态查询结果, episodeId: $episodeId, isFavorite: $isFav, count: $count');
      return isFav;
    } on IsarError catch (e, stackTrace) {
      Logger.error('⭐ [FAVORITE-DS] 检查收藏状态失败', error: e, stackTrace: stackTrace);
      throw AppException.storage('检查收藏状态失败', originalError: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      Logger.error('⭐ [FAVORITE-DS] 检查收藏状态异常', error: e, stackTrace: stackTrace);
      throw AppException.unknown('检查收藏状态失败', originalError: e, stackTrace: stackTrace);
    }
  }

  /// 获取所有收藏的 episodeId 列表
  Future<List<int>> getAllFavoriteEpisodeIds() async {
    try {
      Logger.info('⭐ [FAVORITE-DS] 获取所有收藏的 episodeId 列表');

      final favorites = await _isarService.isar.favorites.where().findAll();
      final episodeIds = favorites.map((f) => f.episodeId).toList();

      Logger.info('⭐ [FAVORITE-DS] 共获取 ${episodeIds.length} 条收藏记录, episodeIds: $episodeIds');
      return episodeIds;
    } on IsarError catch (e, stackTrace) {
      Logger.error('⭐ [FAVORITE-DS] 获取收藏列表失败', error: e, stackTrace: stackTrace);
      throw AppException.storage('获取收藏列表失败', originalError: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      Logger.error('⭐ [FAVORITE-DS] 获取收藏列表异常', error: e, stackTrace: stackTrace);
      throw AppException.unknown('获取收藏列表失败', originalError: e, stackTrace: stackTrace);
    }
  }
}
