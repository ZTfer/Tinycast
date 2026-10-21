import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinycast/core/services/sync_service.dart';
import 'package:tinycast/core/services/sync_tombstone_store.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/models/episode_model.dart';
import 'package:tinycast/data/models/favorite_model.dart';
import 'package:tinycast/data/models/play_history_model.dart';
import 'package:tinycast/data/models/podcast_model.dart';
import 'package:tinycast/data/models/queue_model.dart';
import 'package:tinycast/data/models/search_history_model.dart';

/// 管理账号与本地数据之间的归属关系。
///
/// 本地 Isar 数据不区分账号，因此切换账号时必须在同步开始前清空上一账号
/// 的数据，否则本地数据会被当作新账号的数据推送到云端。应用设置不属于
/// 账号数据，保持不变。
class LocalAccountDataService {
  LocalAccountDataService({IsarService? isarService})
    : _isarService = isarService ?? IsarService.instance;

  final IsarService _isarService;

  static const String lastUserIdKey = 'last_logged_in_user_id';

  Future<String?> getLastUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(lastUserIdKey);
  }

  Future<void> setLastUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastUserIdKey, userId);
  }

  /// 清空全部用户数据（播客、节目、收藏、队列、播放历史、搜索历史），
  /// 保留应用设置。
  Future<void> clearUserData() async {
    final isar = _isarService.isar;
    await isar.writeTxn(() async {
      await isar.playHistorys.clear();
      await isar.queues.clear();
      await isar.favorites.clear();
      await isar.searchHistoryModels.clear();
      await isar.episodes.clear();
      await isar.podcasts.clear();
    });
    Logger.info('[ACCOUNT] 已清空本地用户数据');
  }

  /// 在开始同步前确认本地数据属于 [userId]。
  ///
  /// 返回 true 表示检测到账号切换并已清空旧数据。上一账号的同步墓碑与
  /// 同步游标同时清除，避免污染新账号的同步流程。
  Future<bool> prepareForUser(String userId) async {
    final previousUserId = await getLastUserId();
    final switched =
        previousUserId != null &&
        previousUserId.isNotEmpty &&
        previousUserId != userId;

    if (switched) {
      Logger.info('[ACCOUNT] 检测到账号切换: $previousUserId -> $userId');
      await clearUserData();
      await SyncTombstoneStore.instance.clearForUser(previousUserId);
      await SyncService.clearLastSyncTimeForUser(previousUserId);
    }

    await setLastUserId(userId);
    return switched;
  }

  /// 显式退出登录：清空本地数据并移除账号标记。
  Future<void> clearForSignOut() async {
    await clearUserData();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(lastUserIdKey);
  }
}
