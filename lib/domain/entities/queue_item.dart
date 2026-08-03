/// 播放队列条目领域实体（与 Isar 持久化模型 Queue 解耦）
class QueueItem {
  final int id;
  final String? supabaseId;
  final int episodeId;
  final String? episodeGuid;
  final String? episodeITunesId;
  final int? podcastId;
  final String? podcastGuid;
  final String? podcastITunesId;
  final int position;
  final DateTime addedAt;

  const QueueItem({
    required this.id,
    this.supabaseId,
    required this.episodeId,
    this.episodeGuid,
    this.episodeITunesId,
    this.podcastId,
    this.podcastGuid,
    this.podcastITunesId,
    required this.position,
    required this.addedAt,
  });
}
