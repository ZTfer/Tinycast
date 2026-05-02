import 'package:isar_community/isar.dart';

part 'podcast_model.g.dart';

@collection
class Podcast {
  Id id = Isar.autoIncrement;

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

  String? artworkPath;

  final DateTime createdAt = DateTime.now();

  String? itunesId;

  String? itunesArtworkUrl;

  String? itunesPrimaryGenreName;

  List<String>? itunesGenres;

  List<String>? itunesGenreIds;

  String? itunesCollectionViewUrl;

  String? itunesCountry;

  DateTime? itunesReleaseDate;

  String? itunesCollectionExplicitness;

  String? itunesContentAdvisoryRating;
}
