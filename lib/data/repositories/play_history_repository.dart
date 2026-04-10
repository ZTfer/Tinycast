import 'package:isar_community/isar.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/models/play_history_model.dart';

class PlayHistoryRepository {
  Future<List<PlayHistory>> getCompletedHistories() async {
    final isar = IsarService.instance.isar;
    return isar.playHistorys
        .filter()
        .statusEqualTo(PlayHistoryStatus.completed)
        .and()
        .isDeletedEqualTo(false)
        .sortByLastUpdateTimeDesc()
        .findAll();
  }

  Future<PlayHistory?> getLatestPlayingHistory() async {
    final isar = IsarService.instance.isar;
    return isar.playHistorys
        .filter()
        .group((q) => q
            .statusEqualTo(PlayHistoryStatus.playing)
            .or()
            .isPlayedEqualTo(false))
        .and()
        .isDeletedEqualTo(false)
        .sortByLastUpdateTimeDesc()
        .findFirst();
  }

  Future<PlayHistory?> getByEpisodeId(int episodeId) async {
    final isar = IsarService.instance.isar;
    return isar.playHistorys
        .filter()
        .episodeIdEqualTo(episodeId)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<void> saveOrUpdate(PlayHistory history) async {
    final isar = IsarService.instance.isar;
    await isar.writeTxn(() async {
      final existing = await getByEpisodeId(history.episodeId);
      if (existing != null) {
        history.id = existing.id;
      }
      await isar.playHistorys.put(history);
    });
  }

  Future<void> updateProgress(int episodeId, int positionMs, int duration) async {
    final isar = IsarService.instance.isar;
    await isar.writeTxn(() async {
      final history = await getByEpisodeId(episodeId);
      if (history != null) {
        history.lastPlayedPositionMs = positionMs;
        history.playedDuration += duration;
        history.lastUpdateTime = DateTime.now();
        await isar.playHistorys.put(history);
      }
    });
  }

  Future<void> markAsCompleted(int episodeId) async {
    final isar = IsarService.instance.isar;
    await isar.writeTxn(() async {
      final history = await getByEpisodeId(episodeId);
      if (history != null) {
        history.isPlayed = true;
        history.status = PlayHistoryStatus.completed;
        history.lastUpdateTime = DateTime.now();
        await isar.playHistorys.put(history);
      }
    });
  }

  Future<void> softDelete(int episodeId) async {
    final isar = IsarService.instance.isar;
    await isar.writeTxn(() async {
      final histories = await isar.playHistorys
          .where()
          .episodeIdEqualTo(episodeId)
          .findAll();

      for (final history in histories) {
        history.isDeleted = true;
        await isar.playHistorys.put(history);
      }
    });
  }
}
