import 'package:isar_community/isar.dart';
import 'package:tinycast/core/services/sync_tombstone_store.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/models/episode_model.dart';
import 'package:tinycast/data/models/queue_model.dart';

/// Records sync tombstones for locally deleted records so the deletion can
/// be propagated to the cloud on the next sync.
///
/// Recording is best-effort: failures are logged but never break the local
/// operation. A missing tombstone only means the deletion may not reach
/// other devices; it never corrupts local data.
class SyncDeleteRecorder {
  SyncDeleteRecorder._();

  static final SyncDeleteRecorder instance = SyncDeleteRecorder._();

  final SyncTombstoneStore _tombstones = SyncTombstoneStore.instance;

  /// Records a favorite removal for the episode once its cloud id is known.
  Future<void> recordFavoriteRemoval(int episodeId) async {
    final episodeCloudId = await _episodeCloudId(episodeId);
    if (episodeCloudId == null) return;
    try {
      await _tombstones.recordFavoriteDelete(episodeCloudId);
    } catch (e) {
      Logger.error('[SYNC] Failed to record favorite tombstone', error: e);
    }
  }

  /// Records a queue removal for the episode once its cloud id is known.
  Future<void> recordQueueRemoval(int episodeId) async {
    final episodeCloudId = await _episodeCloudId(episodeId);
    if (episodeCloudId == null) return;
    try {
      await _tombstones.recordQueueDelete(episodeCloudId);
    } catch (e) {
      Logger.error('[SYNC] Failed to record queue tombstone', error: e);
    }
  }

  /// Records queue removals for all episodes of [podcastId].
  Future<void> recordQueueRemovalsByPodcast(int podcastId) async {
    try {
      final isar = IsarService.instance.isar;
      final queueItems = await isar.queues
          .filter()
          .podcastIdEqualTo(podcastId)
          .findAll();
      for (final item in queueItems) {
        await recordQueueRemoval(item.episodeId);
      }
    } catch (e) {
      Logger.error(
        '[SYNC] Failed to record queue tombstones by podcast',
        error: e,
      );
    }
  }

  /// Records an unsubscribe for the podcast once its cloud id is known.
  Future<void> recordUnsubscribe(String? podcastCloudId) async {
    if (podcastCloudId == null || podcastCloudId.isEmpty) return;
    try {
      await _tombstones.recordSubscriptionDelete(podcastCloudId);
    } catch (e) {
      Logger.error('[SYNC] Failed to record subscription tombstone', error: e);
    }
  }

  Future<String?> _episodeCloudId(int episodeId) async {
    if (episodeId <= 0) return null;
    try {
      final episode = await IsarService.instance.isar.episodes.get(episodeId);
      final cloudId = episode?.supabaseId;
      if (cloudId == null || cloudId.isEmpty) return null;
      return cloudId;
    } catch (e) {
      Logger.error('[SYNC] Failed to resolve episode cloud id', error: e);
      return null;
    }
  }
}
