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

enum SleepTimerOption {
  off,
  min5,
  min10,
  min15,
  min30,
  min45,
  min60,
  episodeEnd;

  int? get minutes {
    switch (this) {
      case SleepTimerOption.min5: return 5;
      case SleepTimerOption.min10: return 10;
      case SleepTimerOption.min15: return 15;
      case SleepTimerOption.min30: return 30;
      case SleepTimerOption.min45: return 45;
      case SleepTimerOption.min60: return 60;
      default: return null;
    }
  }
}

class AppSettings {
  static const defaultPlaybackSpeed = 1.0;
  static const defaultVolume = 0.3;
  static const defaultSkipForwardTime = 30;
  static const defaultSkipBackwardTime = 15;

  final bool downloadOnFavorite;
  final bool removePlayedDownloads;
  final AutoDownloadPolicy autoDownloadPolicy;
  final double playbackSpeed;
  final double volume;
  final int skipForwardTime;
  final int skipBackwardTime;
  final bool continuousPlay;
  final SleepTimerOption sleepTimer;
  final int? sleepTimerEndTimeMillis;

  const AppSettings({
    this.downloadOnFavorite = false,
    this.removePlayedDownloads = false,
    this.autoDownloadPolicy = AutoDownloadPolicy.latest3,
    this.playbackSpeed = defaultPlaybackSpeed,
    this.volume = defaultVolume,
    this.skipForwardTime = defaultSkipForwardTime,
    this.skipBackwardTime = defaultSkipBackwardTime,
    this.continuousPlay = true,
    this.sleepTimer = SleepTimerOption.off,
    this.sleepTimerEndTimeMillis,
  });

  AppSettings copyWith({
    bool? downloadOnFavorite,
    bool? removePlayedDownloads,
    AutoDownloadPolicy? autoDownloadPolicy,
    double? playbackSpeed,
    double? volume,
    int? skipForwardTime,
    int? skipBackwardTime,
    bool? continuousPlay,
    SleepTimerOption? sleepTimer,
    int? sleepTimerEndTimeMillis,
  }) {
    return AppSettings(
      downloadOnFavorite: downloadOnFavorite ?? this.downloadOnFavorite,
      removePlayedDownloads: removePlayedDownloads ?? this.removePlayedDownloads,
      autoDownloadPolicy: autoDownloadPolicy ?? this.autoDownloadPolicy,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      volume: volume ?? this.volume,
      skipForwardTime: skipForwardTime ?? this.skipForwardTime,
      skipBackwardTime: skipBackwardTime ?? this.skipBackwardTime,
      continuousPlay: continuousPlay ?? this.continuousPlay,
      sleepTimer: sleepTimer ?? this.sleepTimer,
      sleepTimerEndTimeMillis: sleepTimerEndTimeMillis ?? this.sleepTimerEndTimeMillis,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'downloadOnFavorite': downloadOnFavorite,
      'removePlayedDownloads': removePlayedDownloads,
      'autoDownloadPolicy': autoDownloadPolicy.name,
      'playbackSpeed': playbackSpeed,
      'volume': volume,
      'skipForwardTime': skipForwardTime,
      'skipBackwardTime': skipBackwardTime,
      'continuousPlay': continuousPlay,
      'sleepTimer': sleepTimer.name,
      'sleepTimerEndTimeMillis': sleepTimerEndTimeMillis,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      downloadOnFavorite: json['downloadOnFavorite'] as bool? ?? false,
      removePlayedDownloads: json['removePlayedDownloads'] as bool? ?? false,
      autoDownloadPolicy: _parseAutoDownloadPolicy(json['autoDownloadPolicy']),
      playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble() ?? defaultPlaybackSpeed,
      volume: (json['volume'] as num?)?.toDouble() ?? defaultVolume,
      skipForwardTime: json['skipForwardTime'] as int? ?? defaultSkipForwardTime,
      skipBackwardTime: json['skipBackwardTime'] as int? ?? defaultSkipBackwardTime,
      continuousPlay: json['continuousPlay'] as bool? ?? true,
      sleepTimer: _parseSleepTimer(json['sleepTimer']),
      sleepTimerEndTimeMillis: json['sleepTimerEndTimeMillis'] as int?,
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

  static SleepTimerOption _parseSleepTimer(dynamic value) {
    if (value == null) return SleepTimerOption.off;
    if (value is SleepTimerOption) return value;
    if (value is String) {
      try {
        return SleepTimerOption.values.byName(value);
      } catch (_) {
        return SleepTimerOption.off;
      }
    }
    return SleepTimerOption.off;
  }
}
