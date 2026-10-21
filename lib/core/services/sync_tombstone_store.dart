import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinycast/core/services/supabase_service.dart';
import 'package:tinycast/core/utils/logger.dart';

/// Records user deletions made locally since the last successful sync so
/// they can be propagated to the cloud explicitly.
///
/// Deletions are tracked as "tombstones" (cloud ids) instead of being
/// inferred by diffing the local snapshot against the cloud, because
/// snapshot-based mirror deletion causes devices to delete data that other
/// devices just uploaded but this device has not pulled yet.
///
/// All keys are scoped by the authenticated Supabase user id so account
/// switches on the same device cannot leak pending deletes or push
/// snapshots across users.
class SyncTombstoneStore {
  SyncTombstoneStore._() : _userIdResolver = null;

  /// Injects a user-id resolver so tests can exercise scoped storage without
  /// initializing the global Supabase client.
  @visibleForTesting
  SyncTombstoneStore.forTesting({String? Function()? userIdResolver})
    : _userIdResolver = userIdResolver;

  static final SyncTombstoneStore instance = SyncTombstoneStore._();

  final String? Function()? _userIdResolver;

  static const String _subscriptionKey = 'sync_tombstone_subscriptions';
  static const String _favoriteKey = 'sync_tombstone_favorites';
  static const String _queueKey = 'sync_tombstone_queue';
  static const String _pushedSubscriptionsKey = 'sync_pushed_subscription_ids';

  /// Legacy unscoped keys from before user isolation (cleared on logout).
  static const List<String> _legacyUnscopedKeys = [
    _subscriptionKey,
    _favoriteKey,
    _queueKey,
    _pushedSubscriptionsKey,
  ];

  /// Serializes read-modify-write so concurrent deletes cannot drop ids.
  Future<void> _writeChain = Future.value();

  String? get _userId {
    final resolver = _userIdResolver;
    if (resolver != null) return resolver();
    if (!SupabaseService().isInitialized) return null;
    return SupabaseService().client.auth.currentUser?.id;
  }

  String? _scopedKey(String baseKey, {String? userId}) {
    final id = userId ?? _userId;
    if (id == null || id.isEmpty) return null;
    return '${baseKey}_$id';
  }

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
    final key = _scopedKey(_pushedSubscriptionsKey);
    if (key == null) return;
    await _withWriteLock(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(key, ids.toList());
      } catch (e) {
        Logger.error(
          '[SYNC] Failed to save pushed subscription snapshot',
          error: e,
        );
      }
    });
  }

  // ========== Account lifecycle ==========

  /// Clears all tombstones and push snapshots for [userId].
  Future<void> clearForUser(String userId) async {
    if (userId.isEmpty) return;
    await _withWriteLock(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        for (final base in _legacyUnscopedKeys) {
          await prefs.remove('${base}_$userId');
        }
        Logger.info('[SYNC] Cleared tombstones for user $userId');
      } catch (e) {
        Logger.error(
          '[SYNC] Failed to clear tombstones for user $userId',
          error: e,
        );
      }
    });
  }

  /// Clears pre-scoping global keys so they cannot affect a later account.
  Future<void> clearLegacyUnscopedKeys() async {
    await _withWriteLock(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        for (final key in _legacyUnscopedKeys) {
          await prefs.remove(key);
        }
      } catch (e) {
        Logger.error('[SYNC] Failed to clear legacy tombstone keys', error: e);
      }
    });
  }

  // ========== Internal ==========

  Future<Set<String>> _read(String baseKey) async {
    final key = _scopedKey(baseKey);
    if (key == null) return <String>{};
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(key)?.toSet() ?? <String>{};
    } catch (e) {
      Logger.error('[SYNC] Failed to read tombstones for $baseKey', error: e);
      return <String>{};
    }
  }

  Future<void> _add(String baseKey, String id) async {
    if (id.isEmpty) return;
    final key = _scopedKey(baseKey);
    if (key == null) return;
    await _withWriteLock(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final ids = prefs.getStringList(key)?.toSet() ?? <String>{};
        if (!ids.add(id)) return;
        await prefs.setStringList(key, ids.toList());
      } catch (e) {
        Logger.error('[SYNC] Failed to record tombstone for $baseKey', error: e);
      }
    });
  }

  Future<void> _removeAll(String baseKey, Set<String> ids) async {
    if (ids.isEmpty) return;
    final key = _scopedKey(baseKey);
    if (key == null) return;
    await _withWriteLock(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final existing = prefs.getStringList(key)?.toSet() ?? <String>{};
        existing.removeAll(ids);
        await prefs.setStringList(key, existing.toList());
      } catch (e) {
        Logger.error(
          '[SYNC] Failed to resolve tombstones for $baseKey',
          error: e,
        );
      }
    });
  }

  Future<T> _withWriteLock<T>(Future<T> Function() action) {
    final previous = _writeChain;
    final completer = Completer<void>();
    _writeChain = completer.future;
    return previous.then((_) => action()).whenComplete(completer.complete);
  }
}
