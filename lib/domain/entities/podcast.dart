class Podcast {
  final int id;
  final String title;
  final String? subtitle;
  final String author;
  final String description;
  final String artworkUrl;
  final String rssUrl;
  final String? websiteUrl;
  final String? language;
  final String? copyright;
  final List<String>? categories;
  final List<String>? keywords;
  final bool isExplicit;
  final String? ownerName;
  final String? ownerEmail;
  final DateTime lastUpdated;
  final int episodeCount;
  final bool isSubscribed;
  final DateTime? subscribedAt;
  final String? artworkPath;
  final DateTime createdAt;
  final String? appleId;
  final String? itunesArtworkUrl;

  Podcast({
    required this.id,
    required this.title,
    this.subtitle,
    required this.author,
    required this.description,
    required this.artworkUrl,
    required this.rssUrl,
    this.websiteUrl,
    this.language,
    this.copyright,
    this.categories,
    this.keywords,
    this.isExplicit = false,
    this.ownerName,
    this.ownerEmail,
    required this.lastUpdated,
    this.episodeCount = 0,
    this.isSubscribed = false,
    this.subscribedAt,
    this.artworkPath,
    required this.createdAt,
    this.appleId,
    this.itunesArtworkUrl,
  });
}
