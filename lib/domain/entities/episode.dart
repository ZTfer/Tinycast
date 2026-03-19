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
  final String? downloadedPath;
  final double downloadProgress;
  final double playProgress;
  final DateTime? lastPlayedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    this.downloadedPath,
    this.downloadProgress = 0.0,
    this.playProgress = 0.0,
    this.lastPlayedAt,
    required this.createdAt,
    required this.updatedAt,
  });
}
