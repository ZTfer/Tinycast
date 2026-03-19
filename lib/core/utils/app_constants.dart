/// 应用级常量
///
/// 此类包含 TinyCast 应用中使用的所有常量值，
/// 包括应用元数据、超时设置、分页设置、格式、存储键、
/// 路径、语言设置和播放选项。
class AppConstants {
  /// 私有构造函数，防止实例化
  AppConstants._();

  /// 应用名称
  static const String appName = "TinyCast";

  /// 当前应用版本
  static const String appVersion = "1.0.0";

  /// 网络操作的默认超时时间（毫秒）
  static const int defaultTimeout = 30000;

  /// 失败操作的最大重试次数
  static const int maxRetryCount = 3;

  /// 分页列表的默认每页项目数
  static const int defaultPageSize = 20;

  /// 每页允许的最大项目数
  static const int maxPageSize = 100;

  /// 日期格式字符串（例如：2023-12-25）
  static const String dateFormat = "yyyy-MM-dd";

  /// 日期和时间格式字符串（例如：2023-12-25 14:30:00）
  static const String dateTimeFormat = "yyyy-MM-dd HH:mm:ss";

  /// 时间格式字符串（例如：14:30:00）
  static const String timeFormat = "HH:mm:ss";

  /// 持久化存储键
  static const String storageKey = "tinycast_storage";

  /// 应用设置键
  static const String settingsKey = "tinycast_settings";

  /// 缓存数据键
  static const String cacheKey = "tinycast_cache";

  /// 默认下载目录路径
  // Todo：根据平台调整
  static const String downloadPath = "/downloads";

  /// 临时文件目录路径
  // Todo：根据平台调整
  static const String tempPath = "/temp";

  /// 日志文件目录路径
  // Todo：根据平台调整
  static const String logPath = "/logs";

  /// 默认应用语言代码（ISO 639-1）
  static const String defaultLanguage = "en";

  /// 支持的语言代码列表
  static const List<String> supportedLanguages = ["en", "zh", "ja", "ko"];

  /// 默认播放速度倍数（1.0 = 正常速度）
  static const double defaultPlaybackSpeed = 1.0;

  /// 可用的播放速度选项
  static const List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  /// 默认快进/快退时长（秒）
  static const int defaultSkipTime = 30;

  /// 可用的跳过时长选项（秒）
  static const List<int> skipTimes = [15, 30, 45, 60];
}
