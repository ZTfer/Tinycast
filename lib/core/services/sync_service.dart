import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinycast/core/services/supabase_service.dart';
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

  SyncProgress copyWith({int? totalItems, int? syncedItems, String? currentTable}) {
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
  SyncProgressCallback? onProgressChanged;

  SyncService({RemoteSyncDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? RemoteSyncDataSource();

  String? get _userId => SupabaseService().client.auth.currentUser?.id;

  bool get canSync => _userId != null;

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(_lastSyncTimestampKey);
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  Future<void> _saveLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncTimestampKey, time.toIso8601String());
  }

  Future<void> sync() async {
    if (!canSync) {
      Logger.warning('Sync skipped: user not authenticated');
      return;
    }

    try {
      Logger.info('🔄 [SYNC] Starting sync...');
      _notifyProgress(const SyncProgress(currentTable: 'preparing'));

      await _ensureUserProfile();

      await _repairSubscriptionState();

      final lastSyncTime = await getLastSyncTime();
      final isFirstSync = lastSyncTime == null;

      Logger.info('🔄 [SYNC] First sync: $isFirstSync, last sync: $lastSyncTime');

      await _pushLocalChanges(lastSyncTime);

      await _pullAndMergeCloudChanges(lastSyncTime);

      final now = DateTime.now();
      await _saveLastSyncTime(now);

      _notifyProgress(SyncProgress(
        totalItems: 0,
        syncedItems: 0,
        currentTable: 'completed',
      ));

      Logger.info('✅ [SYNC] Sync completed at $now');
    } catch (e, stackTrace) {
      Logger.error('❌ [SYNC] Sync failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _repairSubscriptionState() async {
    final prefs = await SharedPreferences.getInstance();
    final repairDone = prefs.getBool('sync_subscription_repair_done') ?? false;
    if (repairDone) return;

    final isar = IsarService.instance.isar;
    final allPodcasts = await isar.podcasts.where().findAll();
    final unsubscribedPodcasts = allPodcasts.where((p) => !p.isSubscribed).toList();

    if (unsubscribedPodcasts.isEmpty) {
      await prefs.setBool('sync_subscription_repair_done', true);
      return;
    }

    Logger.info('[SYNC-REPAIR] Found ${unsubscribedPodcasts.length} unsubscribed podcasts, checking if repair needed...');

    List<Map<String, dynamic>> cloudSubscriptions;
    try {
      cloudSubscriptions = await _remoteDataSource.fetchUserPodcastSubscriptions();
    } catch (e, stackTrace) {
      Logger.error('[SYNC-REPAIR] Failed to fetch cloud subscriptions for repair', error: e, stackTrace: stackTrace);
      return;
    }

    if (cloudSubscriptions.isEmpty) {
      Logger.info('[SYNC-REPAIR] Cloud has no subscriptions, repairing all local unsubscribed podcasts to subscribed');
      await isar.writeTxn(() async {
        for (final podcast in unsubscribedPodcasts) {
          podcast.isSubscribed = true;
          podcast.subscribedAt ??= podcast.createdAt;
          await isar.podcasts.put(podcast);
          Logger.info('[SYNC-REPAIR] Repaired: ${podcast.title} -> isSubscribed=true');
        }
      });
    }

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
      Logger.error('[SYNC] Failed to ensure user profile', error: e, stackTrace: stackTrace);
    }
  }

  // ========== Pull cloud changes ==========

  Future<void> _pullAndMergeCloudChanges(DateTime? since) async {
    _notifyProgress(const SyncProgress(currentTable: 'podcasts'));
    await _safeStep('pull_podcasts', () async {
      final cloudPodcasts = await _remoteDataSource.fetchPodcastsUpdatedAfter(since);
      await _mergePodcastsFromCloud(cloudPodcasts);
    });

    _notifyProgress(const SyncProgress(currentTable: 'episodes'));
    await _safeStep('pull_episodes', () async {
      final cloudEpisodes = await _remoteDataSource.fetchEpisodesUpdatedAfter(since);
      await _mergeEpisodesFromCloud(cloudEpisodes);
    });

    _notifyProgress(const SyncProgress(currentTable: 'subscriptions'));
    await _safeStep('pull_subscriptions', () async {
      final cloudSubscriptions = await _remoteDataSource.fetchUserPodcastSubscriptions();
      await _mergeSubscriptionsFromCloud(cloudSubscriptions);
    });

    _notifyProgress(const SyncProgress(currentTable: 'playback_history'));
    await _safeStep('pull_playback_history', () async {
      final cloudHistory = await _remoteDataSource.fetchPlaybackHistoryUpdatedAfter(since);
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
      final localPodcasts = await isar.podcasts.where().findAll();
      final subscribedPodcasts = localPodcasts.where((p) => p.isSubscribed).toList();
      if (subscribedPodcasts.isNotEmpty) {
        final subscriptionMaps = <Map<String, dynamic>>[];
        for (final podcast in subscribedPodcasts) {
          if (podcast.supabaseId != null) {
            subscriptionMaps.add({
              'podcast_id': int.parse(podcast.supabaseId!),
              'subscribed_at': podcast.subscribedAt?.toIso8601String(),
            });
          }
        }
        if (subscriptionMaps.isNotEmpty) {
          await _remoteDataSource.upsertUserPodcastSubscriptions(subscriptionMaps);
        }
      }
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
          final results = await _remoteDataSource.upsertPlaybackHistory(historyMaps);
          await _updatePlayHistorySupabaseIds(localHistory, results);
        }
      }
    });

    _notifyProgress(const SyncProgress(currentTable: 'push_favorites'));
    await _safeStep('push_favorites', () async {
      final localFavorites = await isar.favorites.where().findAll();
      if (localFavorites.isNotEmpty) {
        final favoriteMaps = <Map<String, dynamic>>[];
        for (final fav in localFavorites) {
          favoriteMaps.add(_favoriteToCloudMap(fav));
        }
        if (favoriteMaps.isNotEmpty) {
          final results = await _remoteDataSource.upsertFavorites(favoriteMaps);
          await _updateFavoriteSupabaseIds(localFavorites, results);
        }
      }
    });

    _notifyProgress(const SyncProgress(currentTable: 'push_queue_items'));
    await _safeStep('push_queue_items', () async {
      final localQueue = await isar.queues.where().findAll();
      if (localQueue.isNotEmpty) {
        final queueMaps = <Map<String, dynamic>>[];
        for (final item in localQueue) {
          queueMaps.add(_queueItemToCloudMap(item));
        }
        if (queueMaps.isNotEmpty) {
          final results = await _remoteDataSource.upsertQueueItems(queueMaps);
          await _updateQueueSupabaseIds(localQueue, results);
        }
      }
    });
  }

  // ========== Merge cloud data into local Isar ==========

  Future<void> _mergePodcastsFromCloud(List<Map<String, dynamic>> cloudPodcasts) async {
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
            final all = await isar.podcasts.filter().itunesIdEqualTo(itunesId).findAll();
            if (all.isNotEmpty) local = all.first;
          }
          if (local == null && cloudId != null) {
            final all = await isar.podcasts.filter().supabaseIdEqualTo(cloudId).findAll();
            if (all.isNotEmpty) local = all.first;
          }

          if (local != null) {
            final cloudUpdatedAt = _parseDateTime(cloudPodcast['updated_at']);
            if (cloudUpdatedAt != null && cloudUpdatedAt.isAfter(local.lastUpdated)) {
              _updatePodcastFromCloud(local, cloudPodcast);
              await isar.podcasts.put(local);
            }
          } else {
            final newPodcast = _podcastFromCloud(cloudPodcast);
            await isar.podcasts.put(newPodcast);
          }
        } catch (e) {
          Logger.error('[SYNC] Failed to merge podcast record: ${cloudPodcast['id']}', error: e);
        }

        count++;
        if (count % _progressNotifyInterval == 0) {
          _notifyProgress(SyncProgress(
            totalItems: cloudPodcasts.length,
            syncedItems: count,
            currentTable: 'podcasts',
          ));
        }
      }
    });
  }

  Future<void> _mergeEpisodesFromCloud(List<Map<String, dynamic>> cloudEpisodes) async {
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
            final all = await isar.episodes.filter().guidEqualTo(guid).findAll();
            if (all.isNotEmpty) local = all.first;
          }
          if (local == null && cloudId != null) {
            final all = await isar.episodes.filter().supabaseIdEqualTo(cloudId).findAll();
            if (all.isNotEmpty) local = all.first;
          }

          if (local != null) {
            final cloudUpdatedAt = _parseDateTime(cloudEpisode['updated_at']);
            if (cloudUpdatedAt != null && cloudUpdatedAt.isAfter(local.updatedAt)) {
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
          Logger.error('[SYNC] Failed to merge episode record: ${cloudEpisode['id']}', error: e);
        }

        count++;
        if (count % _progressNotifyInterval == 0) {
          _notifyProgress(SyncProgress(
            totalItems: cloudEpisodes.length,
            syncedItems: count,
            currentTable: 'episodes',
          ));
        }
      }
    });
  }

  Future<void> _mergeSubscriptionsFromCloud(List<Map<String, dynamic>> cloudSubscriptions) async {
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
        Logger.info('[SYNC] Cloud subscriptions empty, skip unsubscribe to protect local data');
        return;
      }

      for (final sub in cloudSubscriptions) {
        try {
          final podcastCloudId = sub['podcast_id']?.toString();
          if (podcastCloudId == null) continue;

          final podcasts = await isar.podcasts.filter().supabaseIdEqualTo(podcastCloudId).findAll();
          for (final podcast in podcasts) {
            if (!podcast.isSubscribed) {
              podcast.isSubscribed = true;
              podcast.subscribedAt = _parseDateTime(sub['subscribed_at']);
              await isar.podcasts.put(podcast);
            }
          }
        } catch (e) {
          Logger.error('[SYNC] Failed to merge subscription record: ${sub['podcast_id']}', error: e);
        }
      }

      final allSubscribedPodcasts = await isar.podcasts.filter().isSubscribedEqualTo(true).findAll();
      for (final podcast in allSubscribedPodcasts) {
        try {
          if (podcast.supabaseId != null && !subscribedPodcastCloudIds.contains(podcast.supabaseId)) {
            Logger.info('[SYNC] Unsubscribing local podcast (not in cloud): ${podcast.title}');
            podcast.isSubscribed = false;
            podcast.subscribedAt = null;
            await isar.podcasts.put(podcast);
          }
        } catch (e) {
          Logger.error('[SYNC] Failed to unsubscribe podcast: ${podcast.title}', error: e);
        }
      }
    });
  }

  Future<void> _mergePlaybackHistoryFromCloud(List<Map<String, dynamic>> cloudHistory) async {
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
            final all = await isar.playHistorys.filter().supabaseIdEqualTo(cloudId).findAll();
            if (all.isNotEmpty) local = all.first;
          }

          if (local == null && episodeCloudId != null) {
            final episodes = await isar.episodes.filter().supabaseIdEqualTo(episodeCloudId).findAll();
            if (episodes.isNotEmpty) {
              final existingHistory = await isar.playHistorys
                  .filter()
                  .episodeIdEqualTo(episodes.first.id)
                  .findAll();
              if (existingHistory.isNotEmpty) local = existingHistory.first;
            }
          }

          if (local != null) {
            final cloudUpdateTime = _parseDateTime(cloudRecord['last_update_time']);
            if (cloudUpdateTime != null && cloudUpdateTime.isAfter(local.lastUpdateTime)) {
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
          Logger.error('[SYNC] Failed to merge playback history record: ${cloudRecord['id']}', error: e);
        }

        count++;
        if (count % _progressNotifyInterval == 0) {
          _notifyProgress(SyncProgress(
            totalItems: cloudHistory.length,
            syncedItems: count,
            currentTable: 'playback_history',
          ));
        }
      }
    });
  }

  Future<void> _mergeFavoritesFromCloud(List<Map<String, dynamic>> cloudFavorites) async {
    if (cloudFavorites.isEmpty) return;
    final isar = IsarService.instance.isar;

    await isar.writeTxn(() async {
      for (final cloudFav in cloudFavorites) {
        try {
          final cloudId = cloudFav['id']?.toString();
          final episodeCloudId = cloudFav['episode_id']?.toString();

          Favorite? local;
          if (cloudId != null) {
            final all = await isar.favorites.filter().supabaseIdEqualTo(cloudId).findAll();
            if (all.isNotEmpty) local = all.first;
          }

          if (local == null && episodeCloudId != null) {
            final episodes = await isar.episodes.filter().supabaseIdEqualTo(episodeCloudId).findAll();
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
          Logger.error('[SYNC] Failed to merge favorite record: ${cloudFav['id']}', error: e);
        }
      }
    });
  }

  Future<void> _mergeQueueItemsFromCloud(List<Map<String, dynamic>> cloudQueue) async {
    if (cloudQueue.isEmpty) return;
    final isar = IsarService.instance.isar;

    await isar.writeTxn(() async {
      for (final cloudItem in cloudQueue) {
        try {
          final cloudId = cloudItem['id']?.toString();
          final episodeCloudId = cloudItem['episode_id']?.toString();

          Queue? local;
          if (cloudId != null) {
            final all = await isar.queues.filter().supabaseIdEqualTo(cloudId).findAll();
            if (all.isNotEmpty) local = all.first;
          }

          if (local == null && episodeCloudId != null) {
            final episodes = await isar.episodes.filter().supabaseIdEqualTo(episodeCloudId).findAll();
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
          Logger.error('[SYNC] Failed to merge queue item record: ${cloudItem['id']}', error: e);
        }
      }
    });
  }

  // ========== Update supabaseId mappings after push ==========

  Future<void> _updatePodcastSupabaseIds(List<Podcast> locals, List<Map<String, dynamic>> results) async {
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

  Future<void> _updateEpisodeSupabaseIds(List<Episode> locals, List<Map<String, dynamic>> results) async {
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

  Future<void> _updatePlayHistorySupabaseIds(List<PlayHistory> locals, List<Map<String, dynamic>> results) async {
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

  Future<void> _updateFavoriteSupabaseIds(List<Favorite> locals, List<Map<String, dynamic>> results) async {
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

  Future<void> _updateQueueSupabaseIds(List<Queue> locals, List<Map<String, dynamic>> results) async {
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

  Map<String, dynamic> _podcastToCloudMap(Podcast p) {
    final map = <String, dynamic>{
      'title': p.title,
      'author': p.author,
      'description': p.description,
      'is_explicit': p.isExplicit,
      'language': p.language,
      'last_updated': p.lastUpdated.toIso8601String(),
      'owner_email': p.ownerEmail,
      'owner_name': p.ownerName,
      'subtitle': p.subtitle,
      'website_url': p.websiteUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (p.itunesId != null) map['itunes_id'] = p.itunesId;
    if (p.itunesArtworkUrl != null) map['itunes_artwork_url'] = p.itunesArtworkUrl;
    if (p.itunesCollectionExplicitness != null) map['itunes_collection_explicitness'] = p.itunesCollectionExplicitness;
    if (p.itunesCollectionViewUrl != null) map['itunes_collection_view_url'] = p.itunesCollectionViewUrl;
    if (p.itunesContentAdvisoryRating != null) map['itunes_content_advisory_rating'] = p.itunesContentAdvisoryRating;
    if (p.itunesCountry != null) map['itunes_country'] = p.itunesCountry;
    if (p.itunesGenreIds != null) map['itunes_genre_ids'] = p.itunesGenreIds;
    if (p.itunesGenres != null) map['itunes_genres'] = p.itunesGenres;
    if (p.itunesPrimaryGenreName != null) map['itunes_primary_genre_name'] = p.itunesPrimaryGenreName;
    if (p.itunesReleaseDate != null) map['itunes_release_date'] = p.itunesReleaseDate!.toIso8601String();
    if (p.keywords != null) map['keywords'] = p.keywords;
    if (p.rssUrl.isNotEmpty) map['rss_urls'] = [p.rssUrl];
    final podcastCloudId = p.supabaseId != null ? int.tryParse(p.supabaseId!) : null;
    if (podcastCloudId != null) map['id'] = podcastCloudId;

    return map;
  }

  Map<String, dynamic> _episodeToCloudMap(Episode e) {
    final map = <String, dynamic>{
      'title': e.title,
      'description': e.description,
      'audio_url': e.audioUrl,
      'is_explicit': e.isExplicit,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (e.guid != null) map['guid'] = e.guid;
    if (e.artworkUrl != null) map['artwork_url'] = e.artworkUrl;
    if (e.duration != null) map['duration'] = e.duration;
    if (e.itunesArtworkUrl != null) map['itunes_artwork_url'] = e.itunesArtworkUrl;
    if (e.itunesContentAdvisoryRating != null) map['itunes_content_advisory_rating'] = e.itunesContentAdvisoryRating;
    if (e.itunesExplicitness != null) map['itunes_explicitness'] = e.itunesExplicitness;
    if (e.itunesId != null) map['itunes_id'] = e.itunesId;
    if (e.itunesReleaseDate != null) map['itunes_release_date'] = e.itunesReleaseDate!.toIso8601String();
    if (e.link != null) map['link'] = e.link;
    if (e.podcastITunesId != null) map['podcast_itunes_id'] = e.podcastITunesId;
    map['pub_date'] = e.pubDate.toIso8601String();
    final episodeCloudId = e.supabaseId != null ? int.tryParse(e.supabaseId!) : null;
    if (episodeCloudId != null) map['id'] = episodeCloudId;

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
    final map = <String, dynamic>{
      'artwork_url': h.artworkUrl,
      'description': h.description,
      'episode_guid': h.episodeGuid,
      'episode_itunes_id': h.episodeITunesId,
      'is_deleted': h.isDeleted,
      'is_played': h.isPlayed,
      'last_played_position_ms': h.lastPlayedPositionMs,
      'last_update_time': h.lastUpdateTime.toIso8601String(),
      'played_duration': h.playedDuration,
      'podcast_guid': h.podcastGuid,
      'podcast_itunes_id': h.podcastITunesId,
      'status': h.status.name,
      'title': h.title,
    };

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
    final map = <String, dynamic>{
      'episode_guid': f.episodeGuid,
      'episode_itunes_id': f.episodeITunesId,
    };

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
    final map = <String, dynamic>{
      'episode_guid': q.episodeGuid,
      'episode_itunes_id': q.episodeITunesId,
      'podcast_guid': q.podcastGuid,
      'podcast_itunes_id': q.podcastITunesId,
      'position': q.position,
      'added_at': q.addedAt.toIso8601String(),
    };

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
      ..itunesGenres = (cloud['itunes_genres'] as List?)?.cast<String>().toList()
      ..itunesGenreIds = (cloud['itunes_genre_ids'] as List?)?.cast<String>().toList()
      ..itunesCollectionViewUrl = cloud['itunes_collection_view_url'] as String?
      ..itunesCountry = cloud['itunes_country'] as String?
      ..itunesReleaseDate = _parseDateTime(cloud['itunes_release_date'])
      ..itunesCollectionExplicitness = cloud['itunes_collection_explicitness'] as String?
      ..itunesContentAdvisoryRating = cloud['itunes_content_advisory_rating'] as String?;
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
    local.keywords = (cloud['keywords'] as List?)?.cast<String>().toList() ?? local.keywords;
    local.ownerName = cloud['owner_name'] as String? ?? local.ownerName;
    local.ownerEmail = cloud['owner_email'] as String? ?? local.ownerEmail;
    local.itunesId = cloud['itunes_id'] as String? ?? local.itunesId;
    local.itunesArtworkUrl = cloud['itunes_artwork_url'] as String? ?? local.itunesArtworkUrl;
    local.itunesPrimaryGenreName = cloud['itunes_primary_genre_name'] as String? ?? local.itunesPrimaryGenreName;
    local.itunesGenres = (cloud['itunes_genres'] as List?)?.cast<String>().toList() ?? local.itunesGenres;
    local.itunesGenreIds = (cloud['itunes_genre_ids'] as List?)?.cast<String>().toList() ?? local.itunesGenreIds;
    local.itunesCollectionViewUrl = cloud['itunes_collection_view_url'] as String? ?? local.itunesCollectionViewUrl;
    local.itunesCountry = cloud['itunes_country'] as String? ?? local.itunesCountry;
    local.itunesReleaseDate = _parseDateTime(cloud['itunes_release_date']) ?? local.itunesReleaseDate;
    local.itunesCollectionExplicitness = cloud['itunes_collection_explicitness'] as String? ?? local.itunesCollectionExplicitness;
    local.itunesContentAdvisoryRating = cloud['itunes_content_advisory_rating'] as String? ?? local.itunesContentAdvisoryRating;
    if (cloud['rss_urls'] != null) {
      final rssUrls = (cloud['rss_urls'] as List).cast<String>();
      if (rssUrls.isNotEmpty) local.rssUrl = rssUrls.first;
    }
    local.lastUpdated = _parseDateTime(cloud['updated_at']) ?? local.lastUpdated;
  }

  Future<Episode?> _episodeFromCloud(Map<String, dynamic> cloud) async {
    final podcastCloudId = cloud['podcast_id']?.toString();
    if (podcastCloudId == null) return null;

    final isar = IsarService.instance.isar;
    final podcasts = await isar.podcasts.filter().supabaseIdEqualTo(podcastCloudId).findAll();
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
      ..itunesContentAdvisoryRating = cloud['itunes_content_advisory_rating'] as String?;
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
    if (cloud['artwork_url'] != null) local.artworkUrl = cloud['artwork_url'] as String?;
    local.itunesId = cloud['itunes_id'] as String? ?? local.itunesId;
    local.podcastITunesId = cloud['podcast_itunes_id'] as String? ?? local.podcastITunesId;
    local.itunesArtworkUrl = cloud['itunes_artwork_url'] as String? ?? local.itunesArtworkUrl;
    local.itunesReleaseDate = _parseDateTime(cloud['itunes_release_date']) ?? local.itunesReleaseDate;
    local.itunesExplicitness = cloud['itunes_explicitness'] as String? ?? local.itunesExplicitness;
    local.itunesContentAdvisoryRating = cloud['itunes_content_advisory_rating'] as String? ?? local.itunesContentAdvisoryRating;
    local.pubDate = _parseDateTime(cloud['pub_date']) ?? local.pubDate;
    local.updatedAt = _parseDateTime(cloud['updated_at']) ?? local.updatedAt;
  }

  Future<PlayHistory?> _playHistoryFromCloud(Map<String, dynamic> cloud) async {
    final episodeCloudId = cloud['episode_id']?.toString();
    if (episodeCloudId == null) return null;

    final isar = IsarService.instance.isar;
    final episodes = await isar.episodes.filter().supabaseIdEqualTo(episodeCloudId).findAll();
    if (episodes.isEmpty) return null;

    final episode = episodes.first;

    return PlayHistory()
      ..supabaseId = cloud['id']?.toString()
      ..episodeId = episode.id
      ..episodeGuid = cloud['episode_guid'] as String? ?? episode.guid
      ..episodeITunesId = cloud['episode_itunes_id'] as String? ?? episode.itunesId
      ..podcastId = episode.podcastId
      ..podcastGuid = null
      ..podcastITunesId = cloud['podcast_itunes_id'] as String? ?? episode.podcastITunesId
      ..title = cloud['title'] as String? ?? episode.title
      ..description = cloud['description'] as String? ?? episode.description
      ..artworkUrl = cloud['artwork_url'] as String? ?? episode.artworkUrl
      ..lastPlayedPositionMs = cloud['last_played_position_ms'] as int? ?? 0
      ..playProgress = 0.0
      ..isPlayed = cloud['is_played'] as bool? ?? false
      ..playedDuration = cloud['played_duration'] as int? ?? 0
      ..status = _parsePlayHistoryStatus(cloud['status'] as String?) ?? PlayHistoryStatus.playing
      ..lastUpdateTime = _parseDateTime(cloud['last_update_time']) ?? DateTime.now()
      ..isDeleted = cloud['is_deleted'] as bool? ?? false;
  }

  void _updatePlayHistoryFromCloud(PlayHistory local, Map<String, dynamic> cloud) {
    local.supabaseId = cloud['id']?.toString() ?? local.supabaseId;
    local.artworkUrl = cloud['artwork_url'] as String? ?? local.artworkUrl;
    local.description = cloud['description'] as String? ?? local.description;
    local.episodeGuid = cloud['episode_guid'] as String? ?? local.episodeGuid;
    local.episodeITunesId = cloud['episode_itunes_id'] as String? ?? local.episodeITunesId;
    local.isDeleted = cloud['is_deleted'] as bool? ?? local.isDeleted;
    local.isPlayed = cloud['is_played'] as bool? ?? local.isPlayed;
    local.lastPlayedPositionMs = cloud['last_played_position_ms'] as int? ?? local.lastPlayedPositionMs;
    local.lastUpdateTime = _parseDateTime(cloud['last_update_time']) ?? local.lastUpdateTime;
    local.playedDuration = cloud['played_duration'] as int? ?? local.playedDuration;
    local.podcastGuid = cloud['podcast_guid'] as String? ?? local.podcastGuid;
    local.podcastITunesId = cloud['podcast_itunes_id'] as String? ?? local.podcastITunesId;
    local.status = _parsePlayHistoryStatus(cloud['status'] as String?) ?? local.status;
    local.title = cloud['title'] as String? ?? local.title;
  }

  Future<Favorite?> _favoriteFromCloud(Map<String, dynamic> cloud) async {
    final episodeCloudId = cloud['episode_id']?.toString();
    if (episodeCloudId == null) return null;

    final isar = IsarService.instance.isar;
    final episodes = await isar.episodes.filter().supabaseIdEqualTo(episodeCloudId).findAll();
    if (episodes.isEmpty) return null;

    return Favorite()
      ..supabaseId = cloud['id']?.toString()
      ..episodeId = episodes.first.id
      ..episodeGuid = cloud['episode_guid'] as String? ?? episodes.first.guid
      ..episodeITunesId = cloud['episode_itunes_id'] as String? ?? episodes.first.itunesId;
  }

  Future<Queue?> _queueItemFromCloud(Map<String, dynamic> cloud) async {
    final episodeCloudId = cloud['episode_id']?.toString();
    if (episodeCloudId == null) return null;

    final isar = IsarService.instance.isar;
    final episodes = await isar.episodes.filter().supabaseIdEqualTo(episodeCloudId).findAll();
    if (episodes.isEmpty) return null;

    final episode = episodes.first;

    return Queue()
      ..supabaseId = cloud['id']?.toString()
      ..episodeId = episode.id
      ..episodeGuid = cloud['episode_guid'] as String? ?? episode.guid
      ..episodeITunesId = cloud['episode_itunes_id'] as String? ?? episode.itunesId
      ..podcastId = episode.podcastId
      ..podcastGuid = cloud['podcast_guid'] as String?
      ..podcastITunesId = cloud['podcast_itunes_id'] as String? ?? episode.podcastITunesId
      ..position = cloud['position'] as int? ?? 0;
  }

  void _updateQueueFromCloud(Queue local, Map<String, dynamic> cloud) {
    local.supabaseId = cloud['id']?.toString() ?? local.supabaseId;
    local.episodeGuid = cloud['episode_guid'] as String? ?? local.episodeGuid;
    local.episodeITunesId = cloud['episode_itunes_id'] as String? ?? local.episodeITunesId;
    local.podcastGuid = cloud['podcast_guid'] as String? ?? local.podcastGuid;
    local.podcastITunesId = cloud['podcast_itunes_id'] as String? ?? local.podcastITunesId;
    local.position = cloud['position'] as int? ?? local.position;
  }

  // ========== Utility methods ==========

  Future<void> _backfillEpisodePodcastITunesId(Isar isar, List<Episode> episodes) async {
    final episodesToUpdate = <Episode>[];

    for (final episode in episodes) {
      if ((episode.podcastITunesId == null || episode.podcastITunesId!.isEmpty) && episode.podcastId > 0) {
        final podcast = isar.podcasts.getSync(episode.podcastId);
        if (podcast != null && podcast.itunesId != null && podcast.itunesId!.isNotEmpty) {
          episode.podcastITunesId = podcast.itunesId;
          episodesToUpdate.add(episode);
        }
      }
    }

    if (episodesToUpdate.isNotEmpty) {
      Logger.info('[SYNC] Backfilling podcastITunesId for ${episodesToUpdate.length} episodes');
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
      case 'playing': return PlayHistoryStatus.playing;
      case 'completed': return PlayHistoryStatus.completed;
      case 'skipped': return PlayHistoryStatus.skipped;
      default: return null;
    }
  }

  void _notifyProgress(SyncProgress progress) {
    onProgressChanged?.call(progress);
  }

  Future<void> _safeStep(String stepName, Future<void> Function() action) async {
    try {
      await action();
    } catch (e, stackTrace) {
      Logger.error('[SYNC] Step "$stepName" failed, continuing with remaining steps', error: e, stackTrace: stackTrace);
    }
  }
}
