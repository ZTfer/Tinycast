import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinycast/core/services/supabase_service.dart';
import 'package:tinycast/core/utils/logger.dart';

/// PostgREST truncates result sets at the server's max-rows (Supabase
/// defaults to 1000), so list fetches must page explicitly.
const int syncPageSize = 1000;

/// PostgREST also caps the rows echoed back by `upsert(...).select()`, so a
/// large upsert would silently lose the returned ids for the tail. Push in
/// chunks well below the server limit so every record's id is mapped back.
const int syncUpsertChunkSize = 500;

/// Fetches every page by repeatedly calling [fetchPage] until a short page
/// is returned. Callers must pass a stable `order` (unique column) so pages
/// do not overlap or skip rows.
@visibleForTesting
Future<List<Map<String, dynamic>>> fetchAllSyncPages(
  Future<List<Map<String, dynamic>>> Function(int offset, int limit) fetchPage, {
  int pageSize = syncPageSize,
}) async {
  final all = <Map<String, dynamic>>[];
  var offset = 0;
  while (true) {
    final page = await fetchPage(offset, pageSize);
    all.addAll(page);
    if (page.length < pageSize) return all;
    offset += page.length;
  }
}

/// 远程同步数据源，负责与 Supabase 云端表交互。
///
/// 默认通过 [SupabaseService] 全局单例解析客户端；测试或集成环境可通过
/// [clientResolver] 注入自定义客户端解析函数以替代全局状态。
class RemoteSyncDataSource {
  RemoteSyncDataSource({
    SupabaseClient? Function()? clientResolver,
    String? Function()? userIdResolver,
  })  : _clientResolver = clientResolver,
        _userIdResolver = userIdResolver;

  final SupabaseClient? Function()? _clientResolver;
  final String? Function()? _userIdResolver;

  SupabaseClient get _client {
    final override = _clientResolver?.call();
    if (override != null) return override;
    return SupabaseService().client;
  }

  String? get _userId =>
      _userIdResolver != null ? _userIdResolver() : _client.auth.currentUser?.id;

  void _ensureUserId() {
    if (_userId == null) {
      throw StateError('User is not authenticated');
    }
  }

  Future<List<Map<String, dynamic>>> _upsertChunked(
    String table,
    List<Map<String, dynamic>> rows,
    String onConflict,
  ) async {
    final results = <Map<String, dynamic>>[];
    for (var start = 0; start < rows.length; start += syncUpsertChunkSize) {
      final end = start + syncUpsertChunkSize < rows.length
          ? start + syncUpsertChunkSize
          : rows.length;
      final response = await _client
          .from(table)
          .upsert(rows.sublist(start, end), onConflict: onConflict)
          .select();
      results.addAll(List<Map<String, dynamic>>.from(response));
    }
    return results;
  }

  // ========== Podcasts ==========

  Future<List<Map<String, dynamic>>> upsertPodcasts(
    List<Map<String, dynamic>> podcasts,
  ) async {
    try {
      if (podcasts.isEmpty) return [];

      return _upsertChunked('podcasts', podcasts, 'itunes_id');
    } catch (e, stackTrace) {
      Logger.error('upsertPodcasts failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchPodcastsUpdatedAfter(
    DateTime? since,
  ) async {
    try {
      return await fetchAllSyncPages((offset, limit) {
        var query = _client.from('podcasts').select();

        if (since != null) {
          query = query.gt('updated_at', since.toUtc().toIso8601String());
        }

        return query
            .order('id', ascending: true)
            .range(offset, offset + limit - 1)
            .then((rows) => List<Map<String, dynamic>>.from(rows));
      });
    } catch (e, stackTrace) {
      Logger.error(
        'fetchPodcastsUpdatedAfter failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchPodcastByItunesId(String itunesId) async {
    try {
      final result = await _client
          .from('podcasts')
          .select()
          .eq('itunes_id', itunesId)
          .maybeSingle();

      return result;
    } catch (e, stackTrace) {
      Logger.error(
        'fetchPodcastByItunesId failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ========== Episodes ==========

  Future<List<Map<String, dynamic>>> upsertEpisodes(
    List<Map<String, dynamic>> episodes,
  ) async {
    try {
      if (episodes.isEmpty) return [];

      return _upsertChunked('episodes', episodes, 'guid,podcast_id');
    } catch (e, stackTrace) {
      Logger.error('upsertEpisodes failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchEpisodesUpdatedAfter(
    DateTime? since,
  ) async {
    try {
      return await fetchAllSyncPages((offset, limit) {
        var query = _client.from('episodes').select();

        if (since != null) {
          query = query.gt('updated_at', since.toUtc().toIso8601String());
        }

        return query
            .order('id', ascending: true)
            .range(offset, offset + limit - 1)
            .then((rows) => List<Map<String, dynamic>>.from(rows));
      });
    } catch (e, stackTrace) {
      Logger.error(
        'fetchEpisodesUpdatedAfter failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ========== User Podcast Subscriptions ==========

  Future<List<Map<String, dynamic>>> upsertUserPodcastSubscriptions(
    List<Map<String, dynamic>> subscriptions,
  ) async {
    try {
      _ensureUserId();
      if (subscriptions.isEmpty) return [];

      final records = subscriptions
          .map((s) => {...s, 'user_id': _userId})
          .toList();

      return _upsertChunked(
        'user_podcast_subscriptions',
        records,
        'user_id,podcast_id',
      );
    } catch (e, stackTrace) {
      Logger.error(
        'upsertUserPodcastSubscriptions failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserPodcastSubscriptions() async {
    try {
      _ensureUserId();

      return await fetchAllSyncPages((offset, limit) {
        return _client
            .from('user_podcast_subscriptions')
            .select()
            .eq('user_id', _userId!)
            .order('id', ascending: true)
            .range(offset, offset + limit - 1)
            .then((rows) => List<Map<String, dynamic>>.from(rows));
      });
    } catch (e, stackTrace) {
      Logger.error(
        'fetchUserPodcastSubscriptions failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> deleteUserPodcastSubscription(int podcastId) async {
    try {
      _ensureUserId();

      await _client
          .from('user_podcast_subscriptions')
          .delete()
          .eq('user_id', _userId!)
          .eq('podcast_id', podcastId);
    } catch (e, stackTrace) {
      Logger.error(
        'deleteUserPodcastSubscription failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ========== Playback History ==========

  Future<List<Map<String, dynamic>>> upsertPlaybackHistory(
    List<Map<String, dynamic>> records,
  ) async {
    try {
      _ensureUserId();
      if (records.isEmpty) return [];

      final items = records
          .map((r) => {...r, 'user_id': _userId})
          .toList();

      return _upsertChunked(
        'playback_history',
        items,
        'user_id,episode_id',
      );
    } catch (e, stackTrace) {
      Logger.error(
        'upsertPlaybackHistory failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchPlaybackHistoryUpdatedAfter(
    DateTime? since,
  ) async {
    try {
      _ensureUserId();

      return await fetchAllSyncPages((offset, limit) {
        var query = _client
            .from('playback_history')
            .select()
            .eq('user_id', _userId!);

        if (since != null) {
          query = query.gt(
            'last_update_time',
            since.toUtc().toIso8601String(),
          );
        }

        return query
            .order('id', ascending: true)
            .range(offset, offset + limit - 1)
            .then((rows) => List<Map<String, dynamic>>.from(rows));
      });
    } catch (e, stackTrace) {
      Logger.error(
        'fetchPlaybackHistoryUpdatedAfter failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> deletePlaybackHistory(int episodeId) async {
    try {
      _ensureUserId();

      await _client
          .from('playback_history')
          .delete()
          .eq('user_id', _userId!)
          .eq('episode_id', episodeId);
    } catch (e, stackTrace) {
      Logger.error(
        'deletePlaybackHistory failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ========== Favorites ==========

  Future<List<Map<String, dynamic>>> upsertFavorites(
    List<Map<String, dynamic>> favorites,
  ) async {
    try {
      _ensureUserId();
      if (favorites.isEmpty) return [];

      final items = favorites
          .map((f) => {...f, 'user_id': _userId})
          .toList();

      return _upsertChunked('favorites', items, 'user_id,episode_id');
    } catch (e, stackTrace) {
      Logger.error('upsertFavorites failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchFavorites() async {
    try {
      _ensureUserId();

      return await fetchAllSyncPages((offset, limit) {
        return _client
            .from('favorites')
            .select()
            .eq('user_id', _userId!)
            .order('id', ascending: true)
            .range(offset, offset + limit - 1)
            .then((rows) => List<Map<String, dynamic>>.from(rows));
      });
    } catch (e, stackTrace) {
      Logger.error('fetchFavorites failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteFavorite(int episodeId) async {
    try {
      _ensureUserId();

      await _client
          .from('favorites')
          .delete()
          .eq('user_id', _userId!)
          .eq('episode_id', episodeId);
    } catch (e, stackTrace) {
      Logger.error('deleteFavorite failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ========== Queue Items ==========

  Future<List<Map<String, dynamic>>> upsertQueueItems(
    List<Map<String, dynamic>> items,
  ) async {
    try {
      _ensureUserId();
      if (items.isEmpty) return [];

      final records = items
          .map((i) => {...i, 'user_id': _userId})
          .toList();

      return _upsertChunked('queue_items', records, 'user_id,episode_id');
    } catch (e, stackTrace) {
      Logger.error('upsertQueueItems failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchQueueItems() async {
    try {
      _ensureUserId();

      return await fetchAllSyncPages((offset, limit) {
        return _client
            .from('queue_items')
            .select()
            .eq('user_id', _userId!)
            .order('id', ascending: true)
            .range(offset, offset + limit - 1)
            .then((rows) => List<Map<String, dynamic>>.from(rows));
      });
    } catch (e, stackTrace) {
      Logger.error('fetchQueueItems failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteQueueItem(int episodeId) async {
    try {
      _ensureUserId();

      await _client
          .from('queue_items')
          .delete()
          .eq('user_id', _userId!)
          .eq('episode_id', episodeId);
    } catch (e, stackTrace) {
      Logger.error('deleteQueueItem failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteAllQueueItems() async {
    try {
      _ensureUserId();

      await _client
          .from('queue_items')
          .delete()
          .eq('user_id', _userId!);
    } catch (e, stackTrace) {
      Logger.error(
        'deleteAllQueueItems failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
