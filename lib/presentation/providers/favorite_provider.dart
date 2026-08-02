import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/episode.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../../data/repositories/favorite_repository_impl.dart';
import '../../core/utils/logger.dart';

/// FavoriteRepository 注入
final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepositoryImpl();
});

/// 收藏状态
enum FavoriteStatus { initial, loading, success, error }

class FavoriteState {
  final FavoriteStatus status;
  final Set<int> favoriteEpisodeIds;
  final String? errorMessage;

  FavoriteState({
    this.status = FavoriteStatus.initial,
    Set<int>? favoriteEpisodeIds,
    this.errorMessage,
  }) : favoriteEpisodeIds = favoriteEpisodeIds ?? <int>{};

  FavoriteState copyWith({
    FavoriteStatus? status,
    Set<int>? favoriteEpisodeIds,
    String? errorMessage,
  }) {
    return FavoriteState(
      status: status ?? this.status,
      favoriteEpisodeIds: favoriteEpisodeIds ?? this.favoriteEpisodeIds,
      errorMessage: errorMessage,
    );
  }

  bool isEpisodeFavorite(int episodeId) {
    return favoriteEpisodeIds.contains(episodeId);
  }
}

class FavoriteNotifier extends Notifier<FavoriteState> {
  @override
  FavoriteState build() {
    Future.microtask(loadFavorites);
    return FavoriteState();
  }

  FavoriteRepository get _repository =>
      ref.read(favoriteRepositoryProvider);

  /// 加载所有收藏状态
  Future<void> loadFavorites() async {
    Logger.info('⭐ [FAVORITE-PROVIDER] ====== loadFavorites 开始 ======');
    state = state.copyWith(status: FavoriteStatus.loading, errorMessage: null);

    try {
      final ids = await _repository.getAllFavoriteEpisodeIds();
      Logger.info('⭐ [FAVORITE-PROVIDER] loadFavorites 成功, 收到 ${ids.length} 条收藏记录, ids: $ids');
      state = state.copyWith(
        status: FavoriteStatus.success,
        favoriteEpisodeIds: Set<int>.from(ids),
      );
      Logger.info('⭐ [FAVORITE-PROVIDER] ====== loadFavorites 完成, 当前收藏数: ${state.favoriteEpisodeIds.length} ======');
    } catch (e, stackTrace) {
      Logger.error('⭐ [FAVORITE-PROVIDER] loadFavorites 失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        status: FavoriteStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 切换收藏状态。以数据库为准，返回切换后是否仍为收藏。
  Future<bool> toggleFavorite(Episode episode) async {
    final currentlyFavorite = await _repository.isFavorite(episode);
    Logger.info('⭐ [FAVORITE-PROVIDER] ====== toggleFavorite 开始 ======');
    Logger.info('⭐ [FAVORITE-PROVIDER] episodeId: ${episode.id}, 当前状态: ${currentlyFavorite ? "已收藏" : "未收藏"}');

    if (currentlyFavorite) {
      Logger.info('⭐ [FAVORITE-PROVIDER] 执行取消收藏操作...');
      try {
        await _repository.removeFavorite(episode);
        final newIds = Set<int>.from(state.favoriteEpisodeIds)..remove(episode.id);
        state = state.copyWith(favoriteEpisodeIds: newIds);
        Logger.info('⭐ [FAVORITE-PROVIDER] 取消收藏成功! episodeId: ${episode.id}, 剩余收藏数: ${state.favoriteEpisodeIds.length}');
        return false;
      } catch (e, stackTrace) {
        Logger.error('⭐ [FAVORITE-PROVIDER] 取消收藏失败!', error: e, stackTrace: stackTrace);
        rethrow;
      }
    } else {
      Logger.info('⭐ [FAVORITE-PROVIDER] 执行添加收藏操作...');
      try {
        await _repository.addFavorite(episode);
        final newIds = Set<int>.from(state.favoriteEpisodeIds)..add(episode.id);
        state = state.copyWith(favoriteEpisodeIds: newIds);
        Logger.info('⭐ [FAVORITE-PROVIDER] 添加收藏成功! episodeId: ${episode.id}, 总收藏数: ${state.favoriteEpisodeIds.length}');
        return true;
      } catch (e, stackTrace) {
        Logger.error('⭐ [FAVORITE-PROVIDER] 添加收藏失败!', error: e, stackTrace: stackTrace);
        rethrow;
      }
    }
  }

  /// 检查单个 episode 是否收藏（不修改状态）
  Future<bool> checkIsFavorite(Episode episode) async {
    Logger.debug('⭐ [FAVORITE-PROVIDER] checkIsFavorite, episodeId: ${episode.id}');
    try {
      final result = await _repository.isFavorite(episode);
      Logger.debug('⭐ [FAVORITE-PROVIDER] checkIsFavorite 结果: $result');
      return result;
    } catch (e, stackTrace) {
      Logger.error('⭐ [FAVORITE-PROVIDER] checkIsFavorite 失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// 根据 episode 列表移除收藏（用于取消关注时清理）
  Future<void> removeByEpisodes(List<Episode> episodes) async {
    final episodeIds = episodes.map((e) => e.id).toSet();
    final toRemove = state.favoriteEpisodeIds.where((id) => episodeIds.contains(id)).toList();
    if (toRemove.isEmpty) return;

    for (final episode in episodes) {
      if (toRemove.contains(episode.id)) {
        try {
          await _repository.removeFavorite(episode);
        } catch (e) {
          Logger.warning('⭐ [FAVORITE-PROVIDER] 移除收藏失败 episodeId: ${episode.id}, $e');
        }
      }
    }

    final newIds = Set<int>.from(state.favoriteEpisodeIds)..removeAll(toRemove);
    state = state.copyWith(favoriteEpisodeIds: newIds);
    Logger.info('⭐ [FAVORITE-PROVIDER] 已移除 ${toRemove.length} 个收藏');
  }
}

final favoriteProvider = NotifierProvider<FavoriteNotifier, FavoriteState>(
  FavoriteNotifier.new,
);

/// 方便使用的 State provider
final favoriteStateProvider = Provider<FavoriteState>((ref) {
  return ref.watch(favoriteProvider);
});

/// 检查某个 episode 是否被收藏（响应式）
final isEpisodeFavoriteProvider = Provider.family<bool, int>((ref, episodeId) {
  final state = ref.watch(favoriteProvider);
  return state.isEpisodeFavorite(episodeId);
});
