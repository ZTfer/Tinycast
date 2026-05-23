enum FeedRefreshInterval {
  manual,
  hourly,
  every3h,
  every6h,
  every12h,
  daily;

  Duration get toDuration {
    switch (this) {
      case FeedRefreshInterval.manual:
        return Duration.zero;
      case FeedRefreshInterval.hourly:
        return const Duration(hours: 1);
      case FeedRefreshInterval.every3h:
        return const Duration(hours: 3);
      case FeedRefreshInterval.every6h:
        return const Duration(hours: 6);
      case FeedRefreshInterval.every12h:
        return const Duration(hours: 12);
      case FeedRefreshInterval.daily:
        return const Duration(days: 1);
    }
  }
}

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
  final FeedRefreshInterval feedRefreshInterval;
  final bool refreshOnCellular;
  final bool notifyOnNewEpisodes;
  final bool backgroundRefreshEnabled;
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
    this.feedRefreshInterval = FeedRefreshInterval.every6h,
    this.refreshOnCellular = false,
    this.notifyOnNewEpisodes = true,
    this.backgroundRefreshEnabled = true,
    this.playbackSpeed = defaultPlaybackSpeed,
    this.volume = defaultVolume,
    this.skipForwardTime = defaultSkipForwardTime,
    this.skipBackwardTime = defaultSkipBackwardTime,
    this.continuousPlay = true,
    this.sleepTimer = SleepTimerOption.off,
    this.sleepTimerEndTimeMillis,
  });

  Duration get refreshIntervalDuration => feedRefreshInterval.toDuration;

  AppSettings copyWith({
    bool? downloadOnFavorite,
    bool? removePlayedDownloads,
    AutoDownloadPolicy? autoDownloadPolicy,
    FeedRefreshInterval? feedRefreshInterval,
    bool? refreshOnCellular,
    bool? notifyOnNewEpisodes,
    bool? backgroundRefreshEnabled,
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
      feedRefreshInterval: feedRefreshInterval ?? this.feedRefreshInterval,
      refreshOnCellular: refreshOnCellular ?? this.refreshOnCellular,
      notifyOnNewEpisodes: notifyOnNewEpisodes ?? this.notifyOnNewEpisodes,
      backgroundRefreshEnabled: backgroundRefreshEnabled ?? this.backgroundRefreshEnabled,
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
      'feedRefreshInterval': feedRefreshInterval.name,
      'refreshOnCellular': refreshOnCellular,
      'notifyOnNewEpisodes': notifyOnNewEpisodes,
      'backgroundRefreshEnabled': backgroundRefreshEnabled,
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
      feedRefreshInterval: _parseFeedRefreshInterval(json['feedRefreshInterval']),
      refreshOnCellular: json['refreshOnCellular'] as bool? ?? false,
      notifyOnNewEpisodes: json['notifyOnNewEpisodes'] as bool? ?? true,
      backgroundRefreshEnabled: json['backgroundRefreshEnabled'] as bool? ?? true,
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

  static FeedRefreshInterval _parseFeedRefreshInterval(dynamic value) {
    if (value == null) return FeedRefreshInterval.every6h;
    if (value is FeedRefreshInterval) return value;
    if (value is String) {
      try {
        return FeedRefreshInterval.values.byName(value);
      } catch (_) {
        return FeedRefreshInterval.every6h;
      }
    }
    return FeedRefreshInterval.every6h;
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
