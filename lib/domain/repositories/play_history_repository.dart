import '../entities/play_history.dart';

/// 播放历史 Repository 抽象接口（Domain 层）
abstract class PlayHistoryRepository {
  Future<List<PlayHistory>> getCompletedHistories();

  Future<PlayHistory?> getLatestPlayingHistory();

  Future<PlayHistory?> getByEpisodeId(
    int episodeId, {
    String? episodeGuid,
    String? episodeITunesId,
  });

  Future<void> saveOrUpdate(PlayHistory history);

  Future<void> updateProgress(
    int episodeId,
    int positionMs,
    int duration, {
    String? episodeGuid,
    String? episodeITunesId,
  });

  Future<void> updatePlayProgress(
    int episodeId,
    int positionMs,
    double progressRatio, {
    String? episodeGuid,
    String? episodeITunesId,
  });

  Future<double?> getPlayProgress(
    int episodeId, {
    String? episodeGuid,
    String? episodeITunesId,
  });

  Future<bool> isEpisodePlayed(
    int episodeId, {
    String? episodeGuid,
    String? episodeITunesId,
  });

  Future<void> markAsPlayedWithProgress(
    int episodeId,
    double progressRatio, {
    String? episodeGuid,
    String? episodeITunesId,
    String? podcastGuid,
    String? podcastITunesId,
  });

  Future<Set<int>> getPlayedEpisodeIds();

  Future<void> markAsCompleted(
    int episodeId, {
    String? episodeGuid,
    String? episodeITunesId,
  });

  Future<void> updateOrCreatePlayHistoryAsCompleted(
    int episodeId, {
    String? episodeGuid,
    String? episodeITunesId,
    String? podcastGuid,
    String? podcastITunesId,
  });

  Future<void> softDelete(
    int episodeId, {
    String? episodeGuid,
    String? episodeITunesId,
  });

  Future<void> removeByPodcastId(
    int podcastId, {
    String? podcastGuid,
    String? podcastITunesId,
  });
}
