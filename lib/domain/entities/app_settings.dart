enum AutoDownloadPolicy {
  off,
  latest1,
  latest2,
  latest3,
  latest5,
  latest10,
  past24h,
  past7d,
  past14d,
  past30d,
  all,
}

class AppSettings {
  final bool downloadOnFavorite;
  final bool removePlayedDownloads;
  final AutoDownloadPolicy autoDownloadPolicy;
  final double playbackSpeed;
  final int skipForwardTime;
  final int skipBackwardTime;
  final bool continuousPlay;

  const AppSettings({
    this.downloadOnFavorite = false,
    this.removePlayedDownloads = false,
    this.autoDownloadPolicy = AutoDownloadPolicy.latest3,
    this.playbackSpeed = 1.0,
    this.skipForwardTime = 30,
    this.skipBackwardTime = 15,
    this.continuousPlay = true,
  });

  AppSettings copyWith({
    bool? downloadOnFavorite,
    bool? removePlayedDownloads,
    AutoDownloadPolicy? autoDownloadPolicy,
    double? playbackSpeed,
    int? skipForwardTime,
    int? skipBackwardTime,
    bool? continuousPlay,
  }) {
    return AppSettings(
      downloadOnFavorite: downloadOnFavorite ?? this.downloadOnFavorite,
      removePlayedDownloads: removePlayedDownloads ?? this.removePlayedDownloads,
      autoDownloadPolicy: autoDownloadPolicy ?? this.autoDownloadPolicy,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      skipForwardTime: skipForwardTime ?? this.skipForwardTime,
      skipBackwardTime: skipBackwardTime ?? this.skipBackwardTime,
      continuousPlay: continuousPlay ?? this.continuousPlay,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'downloadOnFavorite': downloadOnFavorite,
      'removePlayedDownloads': removePlayedDownloads,
      'autoDownloadPolicy': autoDownloadPolicy.name,
      'playbackSpeed': playbackSpeed,
      'skipForwardTime': skipForwardTime,
      'skipBackwardTime': skipBackwardTime,
      'continuousPlay': continuousPlay,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      downloadOnFavorite: json['downloadOnFavorite'] as bool? ?? false,
      removePlayedDownloads: json['removePlayedDownloads'] as bool? ?? false,
      autoDownloadPolicy: _parseAutoDownloadPolicy(json['autoDownloadPolicy']),
      playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
      skipForwardTime: json['skipForwardTime'] as int? ?? 30,
      skipBackwardTime: json['skipBackwardTime'] as int? ?? 15,
      continuousPlay: json['continuousPlay'] as bool? ?? true,
    );
  }

  static AutoDownloadPolicy _parseAutoDownloadPolicy(dynamic value) {
    if (value == null) return AutoDownloadPolicy.latest3;
    if (value is AutoDownloadPolicy) return value;
    if (value is String) {
      return AutoDownloadPolicy.values.byName(value);
    }
    return AutoDownloadPolicy.latest3;
  }
}
