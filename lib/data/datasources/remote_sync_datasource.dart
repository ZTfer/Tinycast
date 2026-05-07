import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinycast/core/services/supabase_service.dart';
import 'package:tinycast/core/utils/logger.dart';

class RemoteSyncDataSource {
  SupabaseClient get _client => SupabaseService().client;
  String? get _userId => _client.auth.currentUser?.id;

  void _ensureUserId() {
    if (_userId == null) {
      throw StateError('User is not authenticated');
    }
  }

  // ========== Podcasts ==========

  Future<List<Map<String, dynamic>>> upsertPodcasts(
    List<Map<String, dynamic>> podcasts,
  ) async {
    try {
      if (podcasts.isEmpty) return [];

      final result = await _client
          .from('podcasts')
          .upsert(podcasts, onConflict: 'itunes_id')
          .select();

      return List<Map<String, dynamic>>.from(result);
    } catch (e, stackTrace) {
      Logger.error('upsertPodcasts failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchPodcastsUpdatedAfter(
    DateTime? since,
  ) async {
    try {
      var query = _client.from('podcasts').select();

      if (since != null) {
        query = query.gt('updated_at', since.toIso8601String());
      }

      final result = await query;
      return List<Map<String, dynamic>>.from(result);
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

      final result = await _client
          .from('episodes')
          .upsert(episodes, onConflict: 'guid,podcast_id')
          .select();

      return List<Map<String, dynamic>>.from(result);
    } catch (e, stackTrace) {
      Logger.error('upsertEpisodes failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchEpisodesUpdatedAfter(
    DateTime? since,
  ) async {
    try {
      var query = _client.from('episodes').select();

      if (since != null) {
        query = query.gt('updated_at', since.toIso8601String());
      }

      final result = await query;
      return List<Map<String, dynamic>>.from(result);
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

      final result = await _client
          .from('user_podcast_subscriptions')
          .upsert(records, onConflict: 'user_id,podcast_id')
          .select();

      return List<Map<String, dynamic>>.from(result);
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

      final result = await _client
          .from('user_podcast_subscriptions')
          .select()
          .eq('user_id', _userId!);

      return List<Map<String, dynamic>>.from(result);
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

      final result = await _client
          .from('playback_history')
          .upsert(items, onConflict: 'user_id,episode_id')
          .select();

      return List<Map<String, dynamic>>.from(result);
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

      var query = _client
          .from('playback_history')
          .select()
          .eq('user_id', _userId!);

      if (since != null) {
        query = query.gt('last_update_time', since.toIso8601String());
      }

      final result = await query;
      return List<Map<String, dynamic>>.from(result);
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

      final result = await _client
          .from('favorites')
          .upsert(items, onConflict: 'user_id,episode_id')
          .select();

      return List<Map<String, dynamic>>.from(result);
    } catch (e, stackTrace) {
      Logger.error('upsertFavorites failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchFavorites() async {
    try {
      _ensureUserId();

      final result = await _client
          .from('favorites')
          .select()
          .eq('user_id', _userId!);

      return List<Map<String, dynamic>>.from(result);
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

      final result = await _client
          .from('queue_items')
          .upsert(records, onConflict: 'user_id,episode_id')
          .select();

      return List<Map<String, dynamic>>.from(result);
    } catch (e, stackTrace) {
      Logger.error('upsertQueueItems failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchQueueItems() async {
    try {
      _ensureUserId();

      final result = await _client
          .from('queue_items')
          .select()
          .eq('user_id', _userId!)
          .order('position');

      return List<Map<String, dynamic>>.from(result);
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
