/// 播放历史状态
enum PlayHistoryStatus { playing, completed, skipped }

/// 播放历史领域实体（与 Isar 持久化模型解耦）
class PlayHistory {
  final int id;
  final String? supabaseId;
  final int episodeId;
  final String? episodeGuid;
  final String? episodeITunesId;
  final int podcastId;
  final String? podcastGuid;
  final String? podcastITunesId;
  final String title;
  final String? description;
  final String? artworkUrl;
  final int lastPlayedPositionMs;
  final double playProgress;
  final bool isPlayed;
  final int playedDuration;
  final PlayHistoryStatus status;
  final DateTime lastUpdateTime;
  final DateTime createdAt;
  final bool isDeleted;

  const PlayHistory({
    this.id = 0,
    this.supabaseId,
    required this.episodeId,
    this.episodeGuid,
    this.episodeITunesId,
    required this.podcastId,
    this.podcastGuid,
    this.podcastITunesId,
    required this.title,
    this.description,
    this.artworkUrl,
    this.lastPlayedPositionMs = 0,
    this.playProgress = 0.0,
    this.isPlayed = false,
    this.playedDuration = 0,
    this.status = PlayHistoryStatus.playing,
    required this.lastUpdateTime,
    required this.createdAt,
    this.isDeleted = false,
  });

  /// 创建当前记录的副本，未传入的字段保留原值。
  PlayHistory copyWith({
    int? id,
    String? supabaseId,
    int? episodeId,
    String? episodeGuid,
    String? episodeITunesId,
    int? podcastId,
    String? podcastGuid,
    String? podcastITunesId,
    String? title,
    String? description,
    String? artworkUrl,
    int? lastPlayedPositionMs,
    double? playProgress,
    bool? isPlayed,
    int? playedDuration,
    PlayHistoryStatus? status,
    DateTime? lastUpdateTime,
    DateTime? createdAt,
    bool? isDeleted,
  }) {
    return PlayHistory(
      id: id ?? this.id,
      supabaseId: supabaseId ?? this.supabaseId,
      episodeId: episodeId ?? this.episodeId,
      episodeGuid: episodeGuid ?? this.episodeGuid,
      episodeITunesId: episodeITunesId ?? this.episodeITunesId,
      podcastId: podcastId ?? this.podcastId,
      podcastGuid: podcastGuid ?? this.podcastGuid,
      podcastITunesId: podcastITunesId ?? this.podcastITunesId,
      title: title ?? this.title,
      description: description ?? this.description,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      lastPlayedPositionMs: lastPlayedPositionMs ?? this.lastPlayedPositionMs,
      playProgress: playProgress ?? this.playProgress,
      isPlayed: isPlayed ?? this.isPlayed,
      playedDuration: playedDuration ?? this.playedDuration,
      status: status ?? this.status,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

