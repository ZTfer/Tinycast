import 'package:isar_community/isar.dart';

part 'play_history_model.g.dart';

enum PlayHistoryStatus { playing, completed, skipped }

@collection
class PlayHistory {
  Id id = Isar.autoIncrement;

  @Index()
  late int episodeId;

  @Index()
  late int podcastId;

  late String title;

  String? artworkUrl;

  int lastPlayedPositionMs = 0;

  bool isPlayed = false;

  int playedDuration = 0;

  @Enumerated(EnumType.ordinal)
  PlayHistoryStatus status = PlayHistoryStatus.playing;

  @Index()
  late DateTime lastUpdateTime;

  final DateTime createdAt = DateTime.now();

  bool isDeleted = false;
}
