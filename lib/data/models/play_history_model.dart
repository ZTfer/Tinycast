import 'package:isar_community/isar.dart';
import '../../domain/entities/play_history.dart' show PlayHistoryStatus;

export '../../domain/entities/play_history.dart' show PlayHistoryStatus;

part 'play_history_model.g.dart';

@collection
class PlayHistory {
  Id id = Isar.autoIncrement;

  String? supabaseId;

  @Index()
  late int episodeId;

  String? episodeGuid;

  String? episodeITunesId;

  @Index()
  late int podcastId;

  String? podcastGuid;

  String? podcastITunesId;

  late String title;

  String? description;

  String? artworkUrl;

  int lastPlayedPositionMs = 0;

  double playProgress = 0.0;

  bool isPlayed = false;

  int playedDuration = 0;

  @Enumerated(EnumType.ordinal)
  PlayHistoryStatus status = PlayHistoryStatus.playing;

  @Index()
  late DateTime lastUpdateTime;

  final DateTime createdAt = DateTime.now();

  bool isDeleted = false;
}
