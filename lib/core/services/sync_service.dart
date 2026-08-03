import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinycast/core/services/supabase_service.dart';
import 'package:tinycast/core/services/sync_mappers.dart';
import 'package:tinycast/core/services/sync_tombstone_store.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/datasources/remote_sync_datasource.dart';
import 'package:tinycast/data/models/podcast_model.dart';
import 'package:tinycast/data/models/episode_model.dart';
import 'package:tinycast/data/models/play_history_model.dart';
import 'package:tinycast/data/models/favorite_model.dart';
import 'package:tinycast/data/models/queue_model.dart';

enum SyncStatus { idle, syncing, error }

class SyncProgress {
  final int totalItems;
  final int syncedItems;
  final String currentTable;

  const SyncProgress({
    this.totalItems = 0,
    this.syncedItems = 0,
    this.currentTable = '',
  });

  SyncProgress copyWith({
    int? totalItems,
    int? syncedItems,
    String? currentTable,
  }) {
    return SyncProgress(
      totalItems: totalItems ?? this.totalItems,
      syncedItems: syncedItems ?? this.syncedItems,
      currentTable: currentTable ?? this.currentTable,
    );
  }
}

typedef SyncProgressCallback = void Function(SyncProgress progress);

class SyncService {
  static const String _lastSyncTimestampKey = 'last_sync_timestamp';
  static const int _progressNotifyInterval = 5;

  final RemoteSyncDataSource _remoteDataSource;
  final String? Function()? _userIdResolver;
  SyncProgressCallback? onProgressChanged;
  bool _allStepsSucceeded = true;

  // Pending local deletions to propagate to the cloud during push.
  Set<String> _pendingSubscriptionDeletes = {};
  Set<String> _pendingFavoriteDeletes = {};
  Set<String> _pendingQueueDeletes = {};

  // Cloud podcast ids this device has successfully pushed subscriptions for.
  Set<String> _lastPushedSubscriptionIds = {};

  SyncService({
    RemoteSyncDataSource? remoteDataSource,
    String? Function()? userIdResolver,
  }) : _remoteDataSource = remoteDataSource ?? RemoteSyncDataSource(),
       _userIdResolver = userIdResolver;

  String? get _userId {
    final override = _userIdResolver?.call();
    if (override != null) return override;
    if (!SupabaseService().isInitialized) return null;
    return SupabaseService().client.auth.currentUser?.id;
  }

  bool get canSync => SupabaseService().isInitialized && _userId != null;

  String? get _scopedLastSyncKey {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return null;
    return '${_lastSyncTimestampKey}_$userId';
  }

  Future<DateTime?> getLastSyncTime() async {
    final key = _scopedLastSyncKey;
    if (key == null) return null;
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(key);
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  Future<void> _saveLastSyncTime(DateTime time) async {
    final key = _scopedLastSyncKey;
    if (key == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, time.toIso8601String());
  }

  /// Clears the last-sync timestamp for [userId] (used on sign-out).
  static Future<void> clearLastSyncTimeForUser(String userId) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_lastSyncTimestampKey}_$userId');
  }

  /// Clears the pre-scoping global last-sync key.
  static Future<void> clearLegacyLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSyncTimestampKey);
  }

  Future<void> sync() async {
    if (!canSync) {
      Logger.warning('Sync skipped: user not authenticated');
      return;
    }

    try {
      Logger.info('🔄 [SYNC] Starting sync...');
      _notifyProgress(const SyncProgress(currentTable: 'preparing'));
      _allStepsSucceeded = true;

      await _ensureUserProfile();

      // Legacy one-shot flag: keep marking done without mutating subscription state.
      await _markSubscriptionRepairDone();

      final lastSyncTime = await getLastSyncTime();
      final isFirstSync = lastSyncTime == null;

      Logger.info(
        '🔄 [SYNC] First sync: $isFirstSync, last sync: $lastSyncTime',
      );

      // Pull first so the push phase operates on the merged local state.
      // This prevents this device from deleting cloud records that other
      // devices uploaded but this device has not pulled yet.
      await _pullAndMergeCloudChanges(lastSyncTime);

      await _pushLocalChanges(lastSyncTime);

      final now = DateTime.now();
      if (_allStepsSucceeded) {
        await _saveLastSyncTime(now);
        Logger.info('✅ [SYNC] Sync completed at $now');
      } else {
        Logger.warning(
          '⚠️ [SYNC] Sync finished with step failures; lastSyncTime not advanced',
        );
      }

      _notifyProgress(
        SyncProgress(totalItems: 0, syncedItems: 0, currentTable: 'completed'),
      );
    } catch (e, stackTrace) {
      Logger.error('❌ [SYNC] Sync failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _markSubscriptionRepairDone() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('sync_subscription_repair_done') ?? false) return;
    await prefs.setBool('sync_subscription_repair_done', true);
  }

  Future<void> _ensureUserProfile() async {
    final userId = _userId;
    if (userId == null) return;

    try {
      final client = SupabaseService().client;
      final existing = await client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existing == null) {
        final user = client.auth.currentUser;
        await client.from('profiles').insert({
          'id': userId,
          'email': user?.email,
          'full_name': user?.userMetadata?['name'],
          'is_premium': false,
        });
        Logger.info('Created user profile for sync');
      }
    } catch (e, stackTrace) {
      Logger.error(
        '[SYNC] Failed to ensure user profile',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ========== Pull cloud changes ==========

  Future<void> _pullAndMergeCloudChanges(DateTime? since) async {
    // Load pending local deletions so the merge phase does not re-add
    // records the user has deleted locally but not yet pushed.
    final tombstones = SyncTombstoneStore.instance;
    _pendingSubscriptionDeletes = await tombstones.pendingSubscriptionDeletes();
    _pendingFavoriteDeletes = await tombstones.pendingFavoriteDeletes();
    _pendingQueueDeletes = await tombstones.pendingQueueDeletes();
    _lastPushedSubscriptionIds = await tombstones.lastPushedSubscriptionIds();

    _notifyProgress(const SyncProgress(currentTable: 'podcasts'));
    await _safeStep('pull_podcasts', () async {
      final cloudPodcasts = await _remoteDataSource.fetchPodcastsUpdatedAfter(
        since,
      );
      await _mergePodcastsFromCloud(cloudPodcasts);
    });

    _notifyProgress(const SyncProgress(currentTable: 'episodes'));
    await _safeStep('pull_episodes', () async {
      final cloudEpisodes = await _remoteDataSource.fetchEpisodesUpdatedAfter(
        since,
      );
      await _mergeEpisodesFromCloud(cloudEpisodes);
    });

    _notifyProgress(const SyncProgress(currentTable: 'subscriptions'));
    await _safeStep('pull_subscriptions', () async {
      final cloudSubscriptions = await _remoteDataSource
          .fetchUserPodcastSubscriptions();
      await _mergeSubscriptionsFromCloud(cloudSubscriptions);
    });

    _notifyProgress(const SyncProgress(currentTable: 'playback_history'));
    await _safeStep('pull_playback_history', () async {
      final cloudHistory = await _remoteDataSource
          .fetchPlaybackHistoryUpdatedAfter(since);
      await _mergePlaybackHistoryFromCloud(cloudHistory);
    });

    _notifyProgress(const SyncProgress(currentTable: 'favorites'));
    await _safeStep('pull_favorites', () async {
      final cloudFavorites = await _remoteDataSource.fetchFavorites();
      await _mergeFavoritesFromCloud(cloudFavorites);
    });

    _notifyProgress(const SyncProgress(currentTable: 'queue_items'));
    await _safeStep('pull_queue_items', () async {
      final cloudQueue = await _remoteDataSource.fetchQueueItems();
      await _mergeQueueItemsFromCloud(cloudQueue);
    });
  }

  // ========== Push local changes ==========

  Future<void> _pushLocalChanges(DateTime? since) async {
    final isar = IsarService.instance.isar;

    _notifyProgress(const SyncProgress(currentTable: 'push_podcasts'));
    await _safeStep('push_podcasts', () async {
      final localPodcasts = await isar.podcasts.where().findAll();
      if (localPodcasts.isNotEmpty) {
        final podcastMaps = localPodcasts
            .where((p) => p.itunesId != null && p.itunesId!.isNotEmpty)
            .map(_podcastToCloudMap)
            .where((m) => m['id'] != null || m['itunes_id'] != null)
            .map((m) {
              m.remove('id');
              return m;
            })
            .toList();
        if (podcastMaps.isNotEmpty) {
          final results = await _remoteDataSource.upsertPodcasts(podcastMaps);
          await _updatePodcastSupabaseIds(localPodcasts, results);
        }
      }
    });

    _notifyProgress(const SyncProgress(currentTable: 'push_episodes'));
    await _safeStep('push_episodes', () async {
      final localEpisodes = await isar.episodes.where().findAll();

      await _backfillEpisodePodcastITunesId(isar, localEpisodes);

      if (localEpisodes.isNotEmpty) {
        final episodeMaps = localEpisodes
            .where((e) => e.guid != null && e.guid!.isNotEmpty)
            .map(_episodeToCloudMap)
            .where((m) => m.containsKey('podcast_id'))
            .map((m) {
              m.remove('id');
              return m;
            })
            .toList();
        if (episodeMaps.isNotEmpty) {
          final results = await _remoteDataSource.upsertEpisodes(episodeMaps);
          await _updateEpisodeSupabaseIds(localEpisodes, results);
        }
      }
    });

    _notifyProgress(const SyncProgress(currentTable: 'push_subscriptions'));
    await _safeStep('push_subscriptions', () async {
      final tombstones = SyncTombstoneStore.instance;
      final localPodcasts = await isar.podcasts.where().findAll();
      final subscribedPodcasts = localPodcasts
          .where((p) => p.isSubscribed)
          .toList();
      final localSubscribedCloudIds = <String>{};

      if (subscribedPodcasts.isNotEmpty) {
        final subscriptionMaps = <Map<String, dynamic>>[];
        for (final podcast in subscribedPodcasts) {
          if (podcast.supabaseId != null) {
            localSubscribedCloudIds.add(podcast.supabaseId!);
            subscriptionMaps.add({
              'podcast_id': int.parse(podcast.supabaseId!),
              'subscribed_at': podcast.subscribedAt?.toIso8601String(),
            });
          }
        }
        if (subscriptionMaps.isNotEmpty) {
          await _remoteDataSource.upsertUserPodcastSubscriptions(
            subscriptionMaps,
          );
        }
      }

      // Subscriptions present locally again win over pending deletes.
      await tombstones.resolveSubscriptionDeletes(localSubscribedCloudIds);
      _pendingSubscriptionDeletes.removeAll(localSubscribedCloudIds);

      // Propagate local unsubscribes via explicit tombstones instead of
      // mirror-deleting every cloud record missing locally, which would
      // delete data other devices just uploaded.
      var deleteFailures = 0;
      for (final pendingCloudId in _pendingSubscriptionDeletes) {
        final podcastId = int.tryParse(pendingCloudId);
        if (podcastId == null) continue;
        try {
          await _remoteDataSource.deleteUserPodcastSubscription(podcastId);
          Logger.info(
            '[SYNC] Deleted cloud subscription for podcast_id=$podcastId',
          );
        } catch (e) {
          deleteFailures++;
          Logger.error(
            '[SYNC] Failed to delete cloud subscription for podcast_id=$podcastId',
            error: e,
          );
        }
      }
      if (deleteFailures > 0) {
        throw StateError(
          '$deleteFailures subscription cloud delete(s) failed; will retry',
        );
      }

      // Only resolve tombstones whose deletion is confirmed; the rest will
      // be retried on the next sync.
      final confirmedSubDeletes = await _confirmedAbsentCloudIds(
        fetch: _remoteDataSource.fetchUserPodcastSubscriptions,
        idField: 'podcast_id',
        pending: _pendingSubscriptionDeletes,
      );
      await tombstones.resolveSubscriptionDeletes(confirmedSubDeletes);

      // Snapshot the subscriptions just pushed, so pull-side unsubscribes
      // never wipe subscriptions that were never pushed successfully.
      await tombstones.saveLastPushedSubscriptionIds(localSubscribedCloudIds);
    });

    _notifyProgress(const SyncProgress(currentTable: 'push_playback_history'));
    await _safeStep('push_playback_history', () async {
      final localHistory = await isar.playHistorys.where().findAll();
      if (localHistory.isNotEmpty) {
        final historyMaps = <Map<String, dynamic>>[];
        for (final history in localHistory) {
          if (history.supabaseId != null || history.episodeId > 0) {
            historyMaps.add(_playHistoryToCloudMap(history));
          }
        }
        if (historyMaps.isNotEmpty) {
          final results = await _remoteDataSource.upsertPlaybackHistory(
            historyMaps,
          );
          await _updatePlayHistorySupabaseIds(localHistory, results);
        }
      }
    });

    _notifyProgress(const SyncProgress(currentTable: 'push_favorites'));
    await _safeStep('push_favorites', () async {
      final tombstones = SyncTombstoneStore.instance;
      final localFavorites = await isar.favorites.where().findAll();
      final localFavoriteEpisodeCloudIds = <String>{};

      if (localFavorites.isNotEmpty) {
        final favoriteMaps = <Map<String, dynamic>>[];
        for (final fav in localFavorites) {
          final map = _favoriteToCloudMap(fav);
          favoriteMaps.add(map);
          final episodeCloudId = map['episode_id']?.toString();
          if (episodeCloudId != null) {
            localFavoriteEpisodeCloudIds.add(episodeCloudId);
          }
        }
        if (favoriteMaps.isNotEmpty) {
          final results = await _remoteDataSource.upsertFavorites(favoriteMaps);
          await _updateFavoriteSupabaseIds(localFavorites, results);
        }
      }

      // Favorites present locally again win over pending deletes.
      await tombstones.resolveFavoriteDeletes(localFavoriteEpisodeCloudIds);
      _pendingFavoriteDeletes.removeAll(localFavoriteEpisodeCloudIds);

      // Propagate local unfavorites via explicit tombstones instead of
      // mirror-deleting every cloud record missing locally.
      var deleteFailures = 0;
      for (final pendingCloudId in _pendingFavoriteDeletes) {
        final episodeId = int.tryParse(pendingCloudId);
        if (episodeId == null) continue;
        try {
          await _remoteDataSource.deleteFavorite(episodeId);
          Logger.info(
            '[SYNC] Deleted cloud favorite for episode_id=$episodeId',
          );
        } catch (e) {
          deleteFailures++;
          Logger.error(
            '[SYNC] Failed to delete cloud favorite for episode_id=$episodeId',
            error: e,
          );
        }
      }
      if (deleteFailures > 0) {
        throw StateError(
          '$deleteFailures favorite cloud delete(s) failed; will retry',
        );
      }

      final confirmedFavDeletes = await _confirmedAbsentCloudIds(
        fetch: _remoteDataSource.fetchFavorites,
        idField: 'episode_id',
        pending: _pendingFavoriteDeletes,
      );
      await tombstones.resolveFavoriteDeletes(confirmedFavDeletes);
    });

    _notifyProgress(const SyncProgress(currentTable: 'push_queue_items'));
    await _safeStep('push_queue_items', () async {
      final tombstones = SyncTombstoneStore.instance;
      final localQueue = await isar.queues.where().findAll();
      final localQueueEpisodeCloudIds = <String>{};

      if (localQueue.isNotEmpty) {
        final queueMaps = <Map<String, dynamic>>[];
        for (final item in localQueue) {
          final map = _queueItemToCloudMap(item);
          queueMaps.add(map);
          final episodeCloudId = map['episode_id']?.toString();
          if (episodeCloudId != null) {
            localQueueEpisodeCloudIds.add(episodeCloudId);
          }
        }
        if (queueMaps.isNotEmpty) {
          final results = await _remoteDataSource.upsertQueueItems(queueMaps);
          await _updateQueueSupabaseIds(localQueue, results);
        }
      }

      // Queue items present locally again win over pending deletes.
      await tombstones.resolveQueueDeletes(localQueueEpisodeCloudIds);
      _pendingQueueDeletes.removeAll(localQueueEpisodeCloudIds);

      // Differential delete: only remove items the user explicitly removed
      // locally, avoiding the non-atomic "delete all then re-insert".
      var deleteFailures = 0;
      for (final pendingCloudId in _pendingQueueDeletes) {
        final episodeId = int.tryParse(pendingCloudId);
        if (episodeId == null) continue;
        try {
          await _remoteDataSource.deleteQueueItem(episodeId);
          Logger.info(
            '[SYNC] Deleted cloud queue item for episode_id=$episodeId',
          );
        } catch (e) {
          deleteFailures++;
          Logger.error(
            '[SYNC] Failed to delete cloud queue item for episode_id=$episodeId',
            error: e,
          );
        }
      }
      if (deleteFailures > 0) {
        throw StateError(
          '$deleteFailures queue cloud delete(s) failed; will retry',
        );
      }

      final confirmedQueueDeletes = await _confirmedAbsentCloudIds(
        fetch: _remoteDataSource.fetchQueueItems,
        idField: 'episode_id',
        pending: _pendingQueueDeletes,
      );
      await tombstones.resolveQueueDeletes(confirmedQueueDeletes);
    });
  }

  /// Returns the subset of [pending] cloud ids that are confirmed absent
  /// from the cloud list returned by [fetch].
  Future<Set<String>> _confirmedAbsentCloudIds({
    required Future<List<Map<String, dynamic>>> Function() fetch,
    required String idField,
    required Set<String> pending,
  }) async {
    if (pending.isEmpty) return <String>{};
    final cloudRows = await fetch();
    final presentIds = <String>{};
    for (final row in cloudRows) {
      final id = row[idField]?.toString();
      if (id != null) {
        presentIds.add(id);
      }
    }
    return pending.where((id) => !presentIds.contains(id)).toSet();
  }

  // ========== Merge cloud data into local Isar ==========

  Future<void> _mergePodcastsFromCloud(
    List<Map<String, dynamic>> cloudPodcasts,
  ) async {
    if (cloudPodcasts.isEmpty) return;
    final isar = IsarService.instance.isar;
    int count = 0;

    await isar.writeTxn(() async {
      for (final cloudPodcast in cloudPodcasts) {
        try {
          final cloudId = cloudPodcast['id']?.toString();
          final itunesId = cloudPodcast['itunes_id'] as String?;

          Podcast? local;
          if (itunesId != null && itunesId.isNotEmpty) {
            final all = await isar.podcasts
                .filter()
                .itunesIdEqualTo(itunesId)
                .findAll();
            if (all.isNotEmpty) local = all.first;
          }
          if (local == null && cloudId != null) {
            final all = await isar.podcasts
                .filter()
                .supabaseIdEqualTo(cloudId)
                .findAll();
            if (all.isNotEmpty) local = all.first;
          }

          if (local != null) {
            final cloudUpdatedAt = _parseDateTime(cloudPodcast['updated_at']);
            if (cloudUpdatedAt != null &&
                cloudUpdatedAt.isAfter(local.lastUpdated)) {
              _updatePodcastFromCloud(local, cloudPodcast);
              await isar.podcasts.put(local);
            }
          } else {
            final newPodcast = _podcastFromCloud(cloudPodcast);
            await isar.podcasts.put(newPodcast);
          }
        } catch (e) {
          Logger.error(
            '[SYNC] Failed to merge podcast record: ${cloudPodcast['id']}',
            error: e,
          );
        }

        count++;
        if (count % _progressNotifyInterval == 0) {
          _notifyProgress(
            SyncProgress(
              totalItems: cloudPodcasts.length,
              syncedItems: count,
              currentTable: 'podcasts',
            ),
          );
        }
      }
    });
  }

  Future<void> _mergeEpisodesFromCloud(
    List<Map<String, dynamic>> cloudEpisodes,
  ) async {
    if (cloudEpisodes.isEmpty) return;
    final isar = IsarService.instance.isar;
    int count = 0;

    await isar.writeTxn(() async {
      for (final cloudEpisode in cloudEpisodes) {
        try {
          final cloudId = cloudEpisode['id']?.toString();
          final guid = cloudEpisode['guid'] as String?;

          Episode? local;
          if (guid != null && guid.isNotEmpty) {
            final all = await isar.episodes
                .filter()
                .guidEqualTo(guid)
                .findAll();
            if (all.isNotEmpty) local = all.first;
          }
          if (local == null && cloudId != null) {
            final all = await isar.episodes
                .filter()
                .supabaseIdEqualTo(cloudId)
                .findAll();
            if (all.isNotEmpty) local = all.first;
          }

          if (local != null) {
            final cloudUpdatedAt = _parseDateTime(cloudEpisode['updated_at']);
            if (cloudUpdatedAt != null &&
                cloudUpdatedAt.isAfter(local.updatedAt)) {
              _updateEpisodeFromCloud(local, cloudEpisode);
              await isar.episodes.put(local);
            }
          } else {
            final newEpisode = await _episodeFromCloud(cloudEpisode);
            if (newEpisode != null) {
              await isar.episodes.put(newEpisode);
            }
          }
        } catch (e) {
          Logger.error(
            '[SYNC] Failed to merge episode record: ${cloudEpisode['id']}',
            error: e,
          );
        }

        count++;
        if (count % _progressNotifyInterval == 0) {
          _notifyProgress(
            SyncProgress(
              totalItems: cloudEpisodes.length,
              syncedItems: count,
              currentTable: 'episodes',
            ),
          );
        }
      }
    });
  }

  Future<void> _mergeSubscriptionsFromCloud(
    List<Map<String, dynamic>> cloudSubscriptions,
  ) async {
    final isar = IsarService.instance.isar;

    final subscribedPodcastCloudIds = <String>{};
    for (final sub in cloudSubscriptions) {
      final podcastCloudId = sub['podcast_id']?.toString();
      if (podcastCloudId != null) {
        subscribedPodcastCloudIds.add(podcastCloudId);
      }
    }

    await isar.writeTxn(() async {
      if (cloudSubscriptions.isEmpty) {
        Logger.info(
          '[SYNC] Cloud subscriptions empty, skip unsubscribe to protect local data',
        );
        return;
      }

      for (final sub in cloudSubscriptions) {
        try {
          final podcastCloudId = sub['podcast_id']?.toString();
          if (podcastCloudId == null) continue;
          // Do not re-subscribe podcasts the user deleted locally and whose
          // deletion has not been pushed to the cloud yet.
          if (_pendingSubscriptionDeletes.contains(podcastCloudId)) continue;

          final podcasts = await isar.podcasts
              .filter()
              .supabaseIdEqualTo(podcastCloudId)
              .findAll();
          for (final podcast in podcasts) {
            if (!podcast.isSubscribed) {
              podcast.isSubscribed = true;
              podcast.subscribedAt = _parseDateTime(sub['subscribed_at']);
              await isar.podcasts.put(podcast);
            }
          }
        } catch (e) {
          Logger.error(
            '[SYNC] Failed to merge subscription record: ${sub['podcast_id']}',
            error: e,
          );
        }
      }

      // Propagate unsubscribes made on other devices: local subscriptions
      // known to the cloud but absent from the cloud list were deleted
      // elsewhere. Restricted to podcasts this device successfully pushed
      // before, so a subscription whose push failed is never wiped by a
      // stale cloud view.
      final allSubscribedPodcasts = await isar.podcasts
          .filter()
          .isSubscribedEqualTo(true)
          .findAll();
      for (final podcast in allSubscribedPodcasts) {
        try {
          if (podcast.supabaseId != null &&
              _lastPushedSubscriptionIds.contains(podcast.supabaseId) &&
              !subscribedPodcastCloudIds.contains(podcast.supabaseId)) {
            Logger.info(
              '[SYNC] Unsubscribing local podcast (not in cloud): ${podcast.title}',
            );
            podcast.isSubscribed = false;
            podcast.subscribedAt = null;
            await isar.podcasts.put(podcast);
          }
        } catch (e) {
          Logger.error(
            '[SYNC] Failed to unsubscribe podcast: ${podcast.title}',
            error: e,
          );
        }
      }
    });
  }

  Future<void> _mergePlaybackHistoryFromCloud(
    List<Map<String, dynamic>> cloudHistory,
  ) async {
    if (cloudHistory.isEmpty) return;
    final isar = IsarService.instance.isar;
    int count = 0;

    await isar.writeTxn(() async {
      for (final cloudRecord in cloudHistory) {
        try {
          final cloudId = cloudRecord['id']?.toString();
          final episodeCloudId = cloudRecord['episode_id']?.toString();

          PlayHistory? local;
          if (cloudId != null) {
            final all = await isar.playHistorys
                .filter()
                .supabaseIdEqualTo(cloudId)
                .findAll();
            if (all.isNotEmpty) local = all.first;
          }

          if (local == null && episodeCloudId != null) {
            final episodes = await isar.episodes
                .filter()
                .supabaseIdEqualTo(episodeCloudId)
                .findAll();
            if (episodes.isNotEmpty) {
              final existingHistory = await isar.playHistorys
                  .filter()
                  .episodeIdEqualTo(episodes.first.id)
                  .findAll();
              if (existingHistory.isNotEmpty) local = existingHistory.first;
            }
          }

          if (local != null) {
            final cloudUpdateTime = _parseDateTime(
              cloudRecord['last_update_time'],
            );
            if (cloudUpdateTime != null &&
                cloudUpdateTime.isAfter(local.lastUpdateTime)) {
              _updatePlayHistoryFromCloud(local, cloudRecord);
              await isar.playHistorys.put(local);
            }
          } else {
            final newHistory = await _playHistoryFromCloud(cloudRecord);
            if (newHistory != null) {
              await isar.playHistorys.put(newHistory);
            }
          }
        } catch (e) {
          Logger.error(
            '[SYNC] Failed to merge playback history record: ${cloudRecord['id']}',
            error: e,
          );
        }

        count++;
        if (count % _progressNotifyInterval == 0) {
          _notifyProgress(
            SyncProgress(
              totalItems: cloudHistory.length,
              syncedItems: count,
              currentTable: 'playback_history',
            ),
          );
        }
      }
    });
  }

  Future<void> _mergeFavoritesFromCloud(
    List<Map<String, dynamic>> cloudFavorites,
  ) async {
    // Do not early-return on empty cloud list: an empty list still means
    // "propagate full clear" for local favorites that already have supabaseId.
    final isar = IsarService.instance.isar;

    final cloudFavoriteRowIds = <String>{};
    for (final cloudFav in cloudFavorites) {
      final cloudId = cloudFav['id']?.toString();
      if (cloudId != null) {
        cloudFavoriteRowIds.add(cloudId);
      }
    }

    await isar.writeTxn(() async {
      for (final cloudFav in cloudFavorites) {
        try {
          final cloudId = cloudFav['id']?.toString();
          final episodeCloudId = cloudFav['episode_id']?.toString();
          // Skip favorites the user removed locally and whose removal has
          // not been pushed to the cloud yet.
          if (episodeCloudId != null &&
              _pendingFavoriteDeletes.contains(episodeCloudId)) {
            continue;
          }

          Favorite? local;
          if (cloudId != null) {
            final all = await isar.favorites
                .filter()
                .supabaseIdEqualTo(cloudId)
                .findAll();
            if (all.isNotEmpty) local = all.first;
          }

          if (local == null && episodeCloudId != null) {
            final episodes = await isar.episodes
                .filter()
                .supabaseIdEqualTo(episodeCloudId)
                .findAll();
            if (episodes.isNotEmpty) {
              final existingFav = await isar.favorites
                  .filter()
                  .episodeIdEqualTo(episodes.first.id)
                  .findAll();
              if (existingFav.isNotEmpty) local = existingFav.first;
            }
          }

          if (local == null) {
            final newFav = await _favoriteFromCloud(cloudFav);
            if (newFav != null) {
              await isar.favorites.put(newFav);
            }
          }
        } catch (e) {
          Logger.error(
            '[SYNC] Failed to merge favorite record: ${cloudFav['id']}',
            error: e,
          );
        }
      }

      // Propagate unfavorites made on other devices: local favorites whose
      // cloud row is known (supabaseId assigned after a successful push) but
      // absent from the cloud list were removed elsewhere.
      final localFavorites = await isar.favorites.where().findAll();
      for (final fav in localFavorites) {
        try {
          if (fav.supabaseId != null &&
              !cloudFavoriteRowIds.contains(fav.supabaseId)) {
            Logger.info(
              '[SYNC] Removing local favorite (not in cloud): episode_id=${fav.episodeId}',
            );
            await isar.favorites.delete(fav.id);
          }
        } catch (e) {
          Logger.error(
            '[SYNC] Failed to remove local favorite: ${fav.id}',
            error: e,
          );
        }
      }
    });
  }

  Future<void> _mergeQueueItemsFromCloud(
    List<Map<String, dynamic>> cloudQueue,
  ) async {
    // Do not early-return on empty cloud list: an empty list still means
    // "propagate full clear" for local queue items that already have supabaseId.
    final isar = IsarService.instance.isar;

    final cloudQueueRowIds = <String>{};
    for (final cloudItem in cloudQueue) {
      final cloudId = cloudItem['id']?.toString();
      if (cloudId != null) {
        cloudQueueRowIds.add(cloudId);
      }
    }

    await isar.writeTxn(() async {
      for (final cloudItem in cloudQueue) {
        try {
          final cloudId = cloudItem['id']?.toString();
          final episodeCloudId = cloudItem['episode_id']?.toString();
          // Skip queue items the user removed locally and whose removal has
          // not been pushed to the cloud yet.
          if (episodeCloudId != null &&
              _pendingQueueDeletes.contains(episodeCloudId)) {
            continue;
          }

          Queue? local;
          if (cloudId != null) {
            final all = await isar.queues
                .filter()
                .supabaseIdEqualTo(cloudId)
                .findAll();
            if (all.isNotEmpty) local = all.first;
          }

          if (local == null && episodeCloudId != null) {
            final episodes = await isar.episodes
                .filter()
                .supabaseIdEqualTo(episodeCloudId)
                .findAll();
            if (episodes.isNotEmpty) {
              final existingQueue = await isar.queues
                  .filter()
                  .episodeIdEqualTo(episodes.first.id)
                  .findAll();
              if (existingQueue.isNotEmpty) local = existingQueue.first;
            }
          }

          if (local != null) {
            _updateQueueFromCloud(local, cloudItem);
            await isar.queues.put(local);
          } else {
            final newQueue = await _queueItemFromCloud(cloudItem);
            if (newQueue != null) {
              await isar.queues.put(newQueue);
            }
          }
        } catch (e) {
          Logger.error(
            '[SYNC] Failed to merge queue item record: ${cloudItem['id']}',
            error: e,
          );
        }
      }

      // Propagate queue removals made on other devices: local queue items
      // known to the cloud (they have a cloud row id) but absent from the
      // cloud list were removed elsewhere.
      final localQueue = await isar.queues.where().findAll();
      for (final item in localQueue) {
        try {
          if (item.supabaseId != null &&
              !cloudQueueRowIds.contains(item.supabaseId)) {
            Logger.info(
              '[SYNC] Removing local queue item (not in cloud): episode_id=${item.episodeId}',
            );
            await isar.queues.delete(item.id);
          }
        } catch (e) {
          Logger.error(
            '[SYNC] Failed to remove local queue item: ${item.id}',
            error: e,
          );
        }
      }
    });
  }

  // ========== Update supabaseId mappings after push ==========

  Future<void> _updatePodcastSupabaseIds(
    List<Podcast> locals,
    List<Map<String, dynamic>> results,
  ) async {
    if (results.isEmpty) return;
    final isar = IsarService.instance.isar;
    final itunesIdToCloudId = <String, String>{};
    for (final r in results) {
      final itunesId = r['itunes_id'] as String?;
      final cloudId = r['id']?.toString();
      if (itunesId != null && cloudId != null) {
        itunesIdToCloudId[itunesId] = cloudId;
      }
    }

    await isar.writeTxn(() async {
      for (final local in locals) {
        if (local.supabaseId == null && local.itunesId != null) {
          final cloudId = itunesIdToCloudId[local.itunesId];
          if (cloudId != null) {
            local.supabaseId = cloudId;
            await isar.podcasts.put(local);
          }
        }
      }
    });
  }

  Future<void> _updateEpisodeSupabaseIds(
    List<Episode> locals,
    List<Map<String, dynamic>> results,
  ) async {
    if (results.isEmpty) return;
    final isar = IsarService.instance.isar;
    final guidToCloudId = <String, String>{};
    for (final r in results) {
      final guid = r['guid'] as String?;
      final cloudId = r['id']?.toString();
      if (guid != null && cloudId != null) {
        guidToCloudId[guid] = cloudId;
      }
    }

    await isar.writeTxn(() async {
      for (final local in locals) {
        if (local.supabaseId == null && local.guid != null) {
          final cloudId = guidToCloudId[local.guid];
          if (cloudId != null) {
            local.supabaseId = cloudId;
            await isar.episodes.put(local);
          }
        }
      }
    });
  }

  Future<void> _updatePlayHistorySupabaseIds(
    List<PlayHistory> locals,
    List<Map<String, dynamic>> results,
  ) async {
    if (results.isEmpty) return;
    final isar = IsarService.instance.isar;

    await isar.writeTxn(() async {
      for (final local in locals) {
        if (local.supabaseId == null) {
          final episode = await isar.episodes.get(local.episodeId);
          if (episode?.supabaseId != null) {
            for (final r in results) {
              if (r['episode_id'].toString() == episode!.supabaseId) {
                local.supabaseId = r['id']?.toString();
                await isar.playHistorys.put(local);
                break;
              }
            }
          }
        }
      }
    });
  }

  Future<void> _updateFavoriteSupabaseIds(
    List<Favorite> locals,
    List<Map<String, dynamic>> results,
  ) async {
    if (results.isEmpty) return;
    final isar = IsarService.instance.isar;

    await isar.writeTxn(() async {
      for (final local in locals) {
        if (local.supabaseId == null) {
          final episode = await isar.episodes.get(local.episodeId);
          if (episode?.supabaseId != null) {
            for (final r in results) {
              if (r['episode_id'].toString() == episode!.supabaseId) {
                local.supabaseId = r['id']?.toString();
                await isar.favorites.put(local);
                break;
              }
            }
          }
        }
      }
    });
  }

  Future<void> _updateQueueSupabaseIds(
    List<Queue> locals,
    List<Map<String, dynamic>> results,
  ) async {
    if (results.isEmpty) return;
    final isar = IsarService.instance.isar;

    await isar.writeTxn(() async {
      for (final local in locals) {
        if (local.supabaseId == null) {
          final episode = await isar.episodes.get(local.episodeId);
          if (episode?.supabaseId != null) {
            for (final r in results) {
              if (r['episode_id'].toString() == episode!.supabaseId) {
                local.supabaseId = r['id']?.toString();
                await isar.queues.put(local);
                break;
              }
            }
          }
        }
      }
    });
  }

  // ========== Convert local models to cloud maps ==========

  Map<String, dynamic> _podcastToCloudMap(Podcast p) =>
      podcastToCloudMap(p);

  Map<String, dynamic> _episodeToCloudMap(Episode e) {
    final map = episodeToCloudMap(e);

    if (e.podcastId > 0) {
      final isar = IsarService.instance.isar;
      final podcast = isar.podcasts.getSync(e.podcastId);
      if (podcast?.supabaseId != null) {
        final podcastId = int.tryParse(podcast!.supabaseId!);
        if (podcastId != null) map['podcast_id'] = podcastId;
      }
    }

    return map;
  }

  Map<String, dynamic> _playHistoryToCloudMap(PlayHistory h) {
    final map = playHistoryToCloudMap(h);

    if (h.episodeId > 0) {
      final isar = IsarService.instance.isar;
      final episode = isar.episodes.getSync(h.episodeId);
      if (episode?.supabaseId != null) {
        final epId = int.tryParse(episode!.supabaseId!);
        if (epId != null) map['episode_id'] = epId;
      }
    }

    return map;
  }

  Map<String, dynamic> _favoriteToCloudMap(Favorite f) {
    final map = favoriteToCloudMap(f);

    if (f.episodeId > 0) {
      final isar = IsarService.instance.isar;
      final episode = isar.episodes.getSync(f.episodeId);
      if (episode?.supabaseId != null) {
        final epId = int.tryParse(episode!.supabaseId!);
        if (epId != null) map['episode_id'] = epId;
      }
    }

    return map;
  }

  Map<String, dynamic> _queueItemToCloudMap(Queue q) {
    final map = queueItemToCloudMap(q);

    if (q.episodeId > 0) {
      final isar = IsarService.instance.isar;
      final episode = isar.episodes.getSync(q.episodeId);
      if (episode?.supabaseId != null) {
        final epId = int.tryParse(episode!.supabaseId!);
        if (epId != null) map['episode_id'] = epId;
      }
    }

    return map;
  }

  // ========== Convert cloud maps to local models ==========

  Podcast _podcastFromCloud(Map<String, dynamic> cloud) {
    return Podcast()
      ..supabaseId = cloud['id']?.toString()
      ..title = cloud['title'] as String? ?? ''
      ..author = cloud['author'] as String? ?? ''
      ..description = cloud['description'] as String? ?? ''
      ..isExplicit = cloud['is_explicit'] as bool? ?? false
      ..rssUrl = (cloud['rss_urls'] as List?)?.cast<String>().firstOrNull ?? ''
      ..lastUpdated = _parseDateTime(cloud['last_updated']) ?? DateTime.now()
      ..episodeCount = 0
      ..isSubscribed = false
      ..subtitle = cloud['subtitle'] as String?
      ..websiteUrl = cloud['website_url'] as String?
      ..language = cloud['language'] as String?
      ..categories = (cloud['categories'] as List?)?.cast<String>().toList()
      ..keywords = (cloud['keywords'] as List?)?.cast<String>().toList()
      ..ownerName = cloud['owner_name'] as String?
      ..ownerEmail = cloud['owner_email'] as String?
      ..itunesId = cloud['itunes_id'] as String?
      ..itunesArtworkUrl = cloud['itunes_artwork_url'] as String?
      ..itunesPrimaryGenreName = cloud['itunes_primary_genre_name'] as String?
      ..itunesGenres = (cloud['itunes_genres'] as List?)
          ?.cast<String>()
          .toList()
      ..itunesGenreIds = (cloud['itunes_genre_ids'] as List?)
          ?.cast<String>()
          .toList()
      ..itunesCollectionViewUrl = cloud['itunes_collection_view_url'] as String?
      ..itunesCountry = cloud['itunes_country'] as String?
      ..itunesReleaseDate = _parseDateTime(cloud['itunes_release_date'])
      ..itunesCollectionExplicitness =
          cloud['itunes_collection_explicitness'] as String?
      ..itunesContentAdvisoryRating =
          cloud['itunes_content_advisory_rating'] as String?;
  }

  void _updatePodcastFromCloud(Podcast local, Map<String, dynamic> cloud) {
    local.supabaseId = cloud['id']?.toString() ?? local.supabaseId;
    local.title = cloud['title'] as String? ?? local.title;
    local.author = cloud['author'] as String? ?? local.author;
    local.description = cloud['description'] as String? ?? local.description;
    local.isExplicit = cloud['is_explicit'] as bool? ?? local.isExplicit;
    local.subtitle = cloud['subtitle'] as String? ?? local.subtitle;
    local.websiteUrl = cloud['website_url'] as String? ?? local.websiteUrl;
    local.language = cloud['language'] as String? ?? local.language;
    local.keywords =
        (cloud['keywords'] as List?)?.cast<String>().toList() ?? local.keywords;
    local.ownerName = cloud['owner_name'] as String? ?? local.ownerName;
    local.ownerEmail = cloud['owner_email'] as String? ?? local.ownerEmail;
    local.itunesId = cloud['itunes_id'] as String? ?? local.itunesId;
    local.itunesArtworkUrl =
        cloud['itunes_artwork_url'] as String? ?? local.itunesArtworkUrl;
    local.itunesPrimaryGenreName =
        cloud['itunes_primary_genre_name'] as String? ??
        local.itunesPrimaryGenreName;
    local.itunesGenres =
        (cloud['itunes_genres'] as List?)?.cast<String>().toList() ??
        local.itunesGenres;
    local.itunesGenreIds =
        (cloud['itunes_genre_ids'] as List?)?.cast<String>().toList() ??
        local.itunesGenreIds;
    local.itunesCollectionViewUrl =
        cloud['itunes_collection_view_url'] as String? ??
        local.itunesCollectionViewUrl;
    local.itunesCountry =
        cloud['itunes_country'] as String? ?? local.itunesCountry;
    local.itunesReleaseDate =
        _parseDateTime(cloud['itunes_release_date']) ?? local.itunesReleaseDate;
    local.itunesCollectionExplicitness =
        cloud['itunes_collection_explicitness'] as String? ??
        local.itunesCollectionExplicitness;
    local.itunesContentAdvisoryRating =
        cloud['itunes_content_advisory_rating'] as String? ??
        local.itunesContentAdvisoryRating;
    if (cloud['rss_urls'] != null) {
      final rssUrls = (cloud['rss_urls'] as List).cast<String>();
      if (rssUrls.isNotEmpty) local.rssUrl = rssUrls.first;
    }
    local.lastUpdated =
        _parseDateTime(cloud['updated_at']) ?? local.lastUpdated;
  }

  Future<Episode?> _episodeFromCloud(Map<String, dynamic> cloud) async {
    final podcastCloudId = cloud['podcast_id']?.toString();
    if (podcastCloudId == null) return null;

    final isar = IsarService.instance.isar;
    final podcasts = await isar.podcasts
        .filter()
        .supabaseIdEqualTo(podcastCloudId)
        .findAll();
    if (podcasts.isEmpty) return null;

    return Episode()
      ..supabaseId = cloud['id']?.toString()
      ..podcastId = podcasts.first.id
      ..title = cloud['title'] as String? ?? ''
      ..description = cloud['description'] as String? ?? ''
      ..audioUrl = cloud['audio_url'] as String? ?? ''
      ..audioType = 'audio/mpeg'
      ..isExplicit = cloud['is_explicit'] as bool? ?? false
      ..isPlayed = false
      ..isDownloaded = false
      ..downloadProgress = 0.0
      ..playProgress = 0.0
      ..pubDate = _parseDateTime(cloud['pub_date']) ?? DateTime.now()
      ..updatedAt = _parseDateTime(cloud['updated_at']) ?? DateTime.now()
      ..guid = cloud['guid'] as String?
      ..link = cloud['link'] as String?
      ..duration = cloud['duration'] as int?
      ..artworkUrl = cloud['artwork_url'] as String?
      ..itunesId = cloud['itunes_id'] as String?
      ..podcastITunesId = cloud['podcast_itunes_id'] as String?
      ..itunesArtworkUrl = cloud['itunes_artwork_url'] as String?
      ..itunesReleaseDate = _parseDateTime(cloud['itunes_release_date'])
      ..itunesExplicitness = cloud['itunes_explicitness'] as String?
      ..itunesContentAdvisoryRating =
          cloud['itunes_content_advisory_rating'] as String?;
  }

  void _updateEpisodeFromCloud(Episode local, Map<String, dynamic> cloud) {
    local.supabaseId = cloud['id']?.toString() ?? local.supabaseId;
    local.title = cloud['title'] as String? ?? local.title;
    local.description = cloud['description'] as String? ?? local.description;
    local.audioUrl = cloud['audio_url'] as String? ?? local.audioUrl;
    local.isExplicit = cloud['is_explicit'] as bool? ?? local.isExplicit;
    local.guid = cloud['guid'] as String? ?? local.guid;
    local.link = cloud['link'] as String? ?? local.link;
    local.duration = cloud['duration'] as int? ?? local.duration;
    if (cloud['artwork_url'] != null) {
      local.artworkUrl = cloud['artwork_url'] as String?;
    }
    local.itunesId = cloud['itunes_id'] as String? ?? local.itunesId;
    local.podcastITunesId =
        cloud['podcast_itunes_id'] as String? ?? local.podcastITunesId;
    local.itunesArtworkUrl =
        cloud['itunes_artwork_url'] as String? ?? local.itunesArtworkUrl;
    local.itunesReleaseDate =
        _parseDateTime(cloud['itunes_release_date']) ?? local.itunesReleaseDate;
    local.itunesExplicitness =
        cloud['itunes_explicitness'] as String? ?? local.itunesExplicitness;
    local.itunesContentAdvisoryRating =
        cloud['itunes_content_advisory_rating'] as String? ??
        local.itunesContentAdvisoryRating;
    local.pubDate = _parseDateTime(cloud['pub_date']) ?? local.pubDate;
    local.updatedAt = _parseDateTime(cloud['updated_at']) ?? local.updatedAt;
  }

  Future<PlayHistory?> _playHistoryFromCloud(Map<String, dynamic> cloud) async {
    final episodeCloudId = cloud['episode_id']?.toString();
    if (episodeCloudId == null) return null;

    final isar = IsarService.instance.isar;
    final episodes = await isar.episodes
        .filter()
        .supabaseIdEqualTo(episodeCloudId)
        .findAll();
    if (episodes.isEmpty) return null;

    final episode = episodes.first;

    return PlayHistory()
      ..supabaseId = cloud['id']?.toString()
      ..episodeId = episode.id
      ..episodeGuid = cloud['episode_guid'] as String? ?? episode.guid
      ..episodeITunesId =
          cloud['episode_itunes_id'] as String? ?? episode.itunesId
      ..podcastId = episode.podcastId
      ..podcastGuid = null
      ..podcastITunesId =
          cloud['podcast_itunes_id'] as String? ?? episode.podcastITunesId
      ..title = cloud['title'] as String? ?? episode.title
      ..description = cloud['description'] as String? ?? episode.description
      ..artworkUrl = cloud['artwork_url'] as String? ?? episode.artworkUrl
      ..lastPlayedPositionMs = cloud['last_played_position_ms'] as int? ?? 0
      ..playProgress = (cloud['play_progress'] as num?)?.toDouble() ?? 0.0
      ..isPlayed = cloud['is_played'] as bool? ?? false
      ..playedDuration = cloud['played_duration'] as int? ?? 0
      ..status =
          _parsePlayHistoryStatus(cloud['status'] as String?) ??
          PlayHistoryStatus.playing
      ..lastUpdateTime =
          _parseDateTime(cloud['last_update_time']) ?? DateTime.now()
      ..isDeleted = cloud['is_deleted'] as bool? ?? false;
  }

  void _updatePlayHistoryFromCloud(
    PlayHistory local,
    Map<String, dynamic> cloud,
  ) {
    local.supabaseId = cloud['id']?.toString() ?? local.supabaseId;
    local.artworkUrl = cloud['artwork_url'] as String? ?? local.artworkUrl;
    local.description = cloud['description'] as String? ?? local.description;
    local.episodeGuid = cloud['episode_guid'] as String? ?? local.episodeGuid;
    local.episodeITunesId =
        cloud['episode_itunes_id'] as String? ?? local.episodeITunesId;
    local.isDeleted = cloud['is_deleted'] as bool? ?? local.isDeleted;
    local.isPlayed = cloud['is_played'] as bool? ?? local.isPlayed;
    local.lastPlayedPositionMs =
        cloud['last_played_position_ms'] as int? ?? local.lastPlayedPositionMs;
    local.playProgress =
        (cloud['play_progress'] as num?)?.toDouble() ?? local.playProgress;
    local.lastUpdateTime =
        _parseDateTime(cloud['last_update_time']) ?? local.lastUpdateTime;
    local.playedDuration =
        cloud['played_duration'] as int? ?? local.playedDuration;
    local.podcastGuid = cloud['podcast_guid'] as String? ?? local.podcastGuid;
    local.podcastITunesId =
        cloud['podcast_itunes_id'] as String? ?? local.podcastITunesId;
    local.status =
        _parsePlayHistoryStatus(cloud['status'] as String?) ?? local.status;
    local.title = cloud['title'] as String? ?? local.title;
  }

  Future<Favorite?> _favoriteFromCloud(Map<String, dynamic> cloud) async {
    final episodeCloudId = cloud['episode_id']?.toString();
    if (episodeCloudId == null) return null;

    final isar = IsarService.instance.isar;
    final episodes = await isar.episodes
        .filter()
        .supabaseIdEqualTo(episodeCloudId)
        .findAll();
    if (episodes.isEmpty) return null;

    return Favorite()
      ..supabaseId = cloud['id']?.toString()
      ..episodeId = episodes.first.id
      ..episodeGuid = cloud['episode_guid'] as String? ?? episodes.first.guid
      ..episodeITunesId =
          cloud['episode_itunes_id'] as String? ?? episodes.first.itunesId;
  }

  Future<Queue?> _queueItemFromCloud(Map<String, dynamic> cloud) async {
    final episodeCloudId = cloud['episode_id']?.toString();
    if (episodeCloudId == null) return null;

    final isar = IsarService.instance.isar;
    final episodes = await isar.episodes
        .filter()
        .supabaseIdEqualTo(episodeCloudId)
        .findAll();
    if (episodes.isEmpty) return null;

    final episode = episodes.first;

    return Queue()
      ..supabaseId = cloud['id']?.toString()
      ..episodeId = episode.id
      ..episodeGuid = cloud['episode_guid'] as String? ?? episode.guid
      ..episodeITunesId =
          cloud['episode_itunes_id'] as String? ?? episode.itunesId
      ..podcastId = episode.podcastId
      ..podcastGuid = cloud['podcast_guid'] as String?
      ..podcastITunesId =
          cloud['podcast_itunes_id'] as String? ?? episode.podcastITunesId
      ..position = cloud['position'] as int? ?? 0;
  }

  void _updateQueueFromCloud(Queue local, Map<String, dynamic> cloud) {
    local.supabaseId = cloud['id']?.toString() ?? local.supabaseId;
    local.episodeGuid = cloud['episode_guid'] as String? ?? local.episodeGuid;
    local.episodeITunesId =
        cloud['episode_itunes_id'] as String? ?? local.episodeITunesId;
    local.podcastGuid = cloud['podcast_guid'] as String? ?? local.podcastGuid;
    local.podcastITunesId =
        cloud['podcast_itunes_id'] as String? ?? local.podcastITunesId;
    local.position = cloud['position'] as int? ?? local.position;
  }

  // ========== Utility methods ==========

  Future<void> _backfillEpisodePodcastITunesId(
    Isar isar,
    List<Episode> episodes,
  ) async {
    final episodesToUpdate = <Episode>[];

    for (final episode in episodes) {
      if ((episode.podcastITunesId == null ||
              episode.podcastITunesId!.isEmpty) &&
          episode.podcastId > 0) {
        final podcast = isar.podcasts.getSync(episode.podcastId);
        if (podcast != null &&
            podcast.itunesId != null &&
            podcast.itunesId!.isNotEmpty) {
          episode.podcastITunesId = podcast.itunesId;
          episodesToUpdate.add(episode);
        }
      }
    }

    if (episodesToUpdate.isNotEmpty) {
      Logger.info(
        '[SYNC] Backfilling podcastITunesId for ${episodesToUpdate.length} episodes',
      );
      await isar.writeTxn(() async {
        await isar.episodes.putAll(episodesToUpdate);
      });
    }
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  PlayHistoryStatus? _parsePlayHistoryStatus(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'playing':
        return PlayHistoryStatus.playing;
      case 'completed':
        return PlayHistoryStatus.completed;
      case 'skipped':
        return PlayHistoryStatus.skipped;
      default:
        return null;
    }
  }

  void _notifyProgress(SyncProgress progress) {
    onProgressChanged?.call(progress);
  }

  Future<void> _safeStep(
    String stepName,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e, stackTrace) {
      _allStepsSucceeded = false;
      Logger.error(
        '[SYNC] Step "$stepName" failed, continuing with remaining steps',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
