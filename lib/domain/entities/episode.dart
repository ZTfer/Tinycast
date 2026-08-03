class Episode {
  final int id;
  final String? supabaseId;
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
    this.supabaseId,
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

  Episode copyWith({
    int? id,
    String? supabaseId,
    int? podcastId,
    String? title,
    String? description,
    String? link,
    String? guid,
    String? author,
    DateTime? pubDate,
    String? audioUrl,
    String? audioType,
    int? duration,
    String? artworkUrl,
    bool? isExplicit,
    bool? isPlayed,
    bool? isDownloaded,
    bool? isFavorite,
    String? downloadedPath,
    String? artworkPath,
    double? downloadProgress,
    double? playProgress,
    DateTime? lastPlayedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? itunesId,
    String? podcastITunesId,
    String? itunesArtworkUrl,
    DateTime? itunesReleaseDate,
    String? itunesExplicitness,
    String? itunesContentAdvisoryRating,
  }) {
    return Episode(
      id: id ?? this.id,
      supabaseId: supabaseId ?? this.supabaseId,
      podcastId: podcastId ?? this.podcastId,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      guid: guid ?? this.guid,
      author: author ?? this.author,
      pubDate: pubDate ?? this.pubDate,
      audioUrl: audioUrl ?? this.audioUrl,
      audioType: audioType ?? this.audioType,
      duration: duration ?? this.duration,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      isExplicit: isExplicit ?? this.isExplicit,
      isPlayed: isPlayed ?? this.isPlayed,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isFavorite: isFavorite ?? this.isFavorite,
      downloadedPath: downloadedPath ?? this.downloadedPath,
      artworkPath: artworkPath ?? this.artworkPath,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      playProgress: playProgress ?? this.playProgress,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      itunesId: itunesId ?? this.itunesId,
      podcastITunesId: podcastITunesId ?? this.podcastITunesId,
      itunesArtworkUrl: itunesArtworkUrl ?? this.itunesArtworkUrl,
      itunesReleaseDate: itunesReleaseDate ?? this.itunesReleaseDate,
      itunesExplicitness: itunesExplicitness ?? this.itunesExplicitness,
      itunesContentAdvisoryRating:
          itunesContentAdvisoryRating ?? this.itunesContentAdvisoryRating,
    );
  }
}
