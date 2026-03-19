import 'package:isar/isar.dart';

part 'podcast_model.g.dart';

@Collection()
class Podcast {
  final Id id = Isar.autoIncrement;

  @Index()
  late String title;

  String? subtitle;

  late String author;

  late String description;

  late String artworkUrl;

  @Index(unique: true)
  late String rssUrl;

  String? websiteUrl;

  String? language;

  String? copyright;

  List<String>? categories;

  List<String>? keywords;

  late bool isExplicit;

  String? ownerName;

  String? ownerEmail;

  @Index()
  late DateTime lastUpdated;

  late int episodeCount;

  late bool isSubscribed;

  DateTime? subscribedAt;

  final DateTime createdAt = DateTime.now();
}
