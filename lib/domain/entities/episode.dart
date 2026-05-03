class Episode {
  final int id;
  final int podcastId;
  final String title;
  final String description;
  final String? link;
  final String? guid;
  final String? author;
  final DateTime pubDate;
  final String audioUrl;
  final String audioType;
  final int? duration;
  final String? artworkUrl;
  final bool isExplicit;
  final bool isPlayed;
  final bool isDownloaded;
  final bool isFavorite;
  final String? downloadedPath;
  final String? artworkPath;
  final double downloadProgress;
  final double playProgress;
  final DateTime? lastPlayedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? itunesId;
  final String? podcastITunesId;
  final String? itunesArtworkUrl;
  final DateTime? itunesReleaseDate;
  final String? itunesExplicitness;
  final String? itunesContentAdvisoryRating;

  Episode({
    required this.id,
    required this.podcastId,
    required this.title,
    required this.description,
    this.link,
    this.guid,
    this.author,
    required this.pubDate,
    required this.audioUrl,
    this.audioType = 'audio/mpeg',
    this.duration,
    this.artworkUrl,
    this.isExplicit = false,
    this.isPlayed = false,
    this.isDownloaded = false,
    this.isFavorite = false,
    this.downloadedPath,
    this.artworkPath,
    this.downloadProgress = 0.0,
    this.playProgress = 0.0,
    this.lastPlayedAt,
    required this.createdAt,
    required this.updatedAt,
    this.itunesId,
    this.podcastITunesId,
    this.itunesArtworkUrl,
    this.itunesReleaseDate,
    this.itunesExplicitness,
    this.itunesContentAdvisoryRating,
  });
}
