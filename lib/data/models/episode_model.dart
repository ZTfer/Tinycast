import 'package:isar_community/isar.dart';

part 'episode_model.g.dart';

@collection
class Episode {
  Id id = Isar.autoIncrement;

  String? supabaseId;

  @Index()
  late int podcastId;

  late String title;

  late String description;

  String? link;

  String? guid;

  String? author;

  @Index()
  late DateTime pubDate;

  late String audioUrl;

  late String audioType;

  int? duration;

  String? artworkUrl;

  late bool isExplicit;

  late bool isPlayed;

  late bool isDownloaded;

  String? downloadedPath;

  String? artworkPath;

  late double downloadProgress;

  late double playProgress;

  DateTime? lastPlayedAt;

  late DateTime createdAt;

  late DateTime updatedAt;

  String? itunesId;

  String? podcastITunesId;

  String? itunesArtworkUrl;

  DateTime? itunesReleaseDate;

  String? itunesExplicitness;

  String? itunesContentAdvisoryRating;
}
