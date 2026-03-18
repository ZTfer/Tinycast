class AppConstants {
  AppConstants._();

  static const String appName = 'TinyCast';
  static const String appVersion = '1.0.0';

  static const int defaultTimeout = 30000;
  static const int maxRetryCount = 3;

  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String timeFormat = 'HH:mm:ss';

  static const String storageKey = 'tinycast_storage';
  static const String settingsKey = 'tinycast_settings';
  static const String cacheKey = 'tinycast_cache';

  static const String downloadPath = '/downloads';
  static const String tempPath = '/temp';
  static const String logPath = '/logs';

  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'zh', 'ja', 'ko'];

  static const double defaultPlaybackSpeed = 1.0;
  static const List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  static const int defaultSkipTime = 30;
  static const List<int> skipTimes = [15, 30, 45, 60];
}
