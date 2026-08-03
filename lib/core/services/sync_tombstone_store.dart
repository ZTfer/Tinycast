import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinycast/core/utils/logger.dart';

/// Records user deletions made locally since the last successful sync so
/// they can be propagated to the cloud explicitly.
///
/// Deletions are tracked as "tombstones" (cloud ids) instead of being
/// inferred by diffing the local snapshot against the cloud, because
/// snapshot-based mirror deletion causes devices to delete data that other
/// devices just uploaded but this device has not pulled yet.
class SyncTombstoneStore {
  SyncTombstoneStore._();

  static final SyncTombstoneStore instance = SyncTombstoneStore._();

  static const String _subscriptionKey = 'sync_tombstone_subscriptions';
  static const String _favoriteKey = 'sync_tombstone_favorites';
  static const String _queueKey = 'sync_tombstone_queue';
  static const String _pushedSubscriptionsKey = 'sync_pushed_subscription_ids';

  // ========== Read pending deletes ==========

  Future<Set<String>> pendingSubscriptionDeletes() => _read(_subscriptionKey);

  Future<Set<String>> pendingFavoriteDeletes() => _read(_favoriteKey);

  Future<Set<String>> pendingQueueDeletes() => _read(_queueKey);

  // ========== Record local deletions ==========

  Future<void> recordSubscriptionDelete(String podcastCloudId) =>
      _add(_subscriptionKey, podcastCloudId);

  Future<void> recordFavoriteDelete(String episodeCloudId) =>
      _add(_favoriteKey, episodeCloudId);

  Future<void> recordQueueDelete(String episodeCloudId) =>
      _add(_queueKey, episodeCloudId);

  /// Removes ids from the pending set. Used both when the record is present
  /// locally again (a local re-add beats a pending delete) and when the
  /// cloud deletion has been confirmed.
  Future<void> resolveSubscriptionDeletes(Set<String> ids) =>
      _removeAll(_subscriptionKey, ids);

  Future<void> resolveFavoriteDeletes(Set<String> ids) =>
      _removeAll(_favoriteKey, ids);

  Future<void> resolveQueueDeletes(Set<String> ids) =>
      _removeAll(_queueKey, ids);

  // ========== Last successfully pushed subscription snapshot ==========

  /// Cloud podcast ids whose subscription this device successfully pushed.
  /// Pull-side unsubscribes only apply to podcasts inside this snapshot,
  /// so a subscription whose push failed is never wiped by a stale cloud.
  Future<Set<String>> lastPushedSubscriptionIds() =>
      _read(_pushedSubscriptionsKey);

  Future<void> saveLastPushedSubscriptionIds(Set<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_pushedSubscriptionsKey, ids.toList());
    } catch (e) {
      Logger.error(
        '[SYNC] Failed to save pushed subscription snapshot',
        error: e,
      );
    }
  }

  // ========== Internal ==========

  Future<Set<String>> _read(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(key)?.toSet() ?? <String>{};
    } catch (e) {
      Logger.error('[SYNC] Failed to read tombstones for $key', error: e);
      return <String>{};
    }
  }

  Future<void> _add(String key, String id) async {
    if (id.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(key)?.toSet() ?? <String>{};
      if (!ids.add(id)) return;
      await prefs.setStringList(key, ids.toList());
    } catch (e) {
      Logger.error('[SYNC] Failed to record tombstone for $key', error: e);
    }
  }

  Future<void> _removeAll(String key, Set<String> ids) async {
    if (ids.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(key)?.toSet() ?? <String>{};
      existing.removeAll(ids);
      await prefs.setStringList(key, existing.toList());
    } catch (e) {
      Logger.error('[SYNC] Failed to resolve tombstones for $key', error: e);
    }
  }
}
