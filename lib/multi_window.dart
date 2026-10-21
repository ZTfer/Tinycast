import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tinycast/core/theme/app_text_styles.dart';
import 'package:tinycast/core/theme/app_theme.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/features/settings/settings.dart';
import 'package:tinycast/presentation/features/subscribe/subscribe.dart';
import 'package:tinycast/presentation/features/episode_detail/episode_detail.dart';
import 'package:tinycast/presentation/widgets/common/window_controls.dart';
import 'package:tinycast/core/router/app_router.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tinycast/window_utils.dart';

/// 窗口参数类
///
/// 用于解析和存储窗口的配置参数，支持多种窗口类型
class WindowArguments {
  /// 窗口类型
  ///
  /// 可选值：
  /// - 'main': 主窗口
  /// - 'settings': 设置窗口
  /// - 'subscribe': 订阅窗口
  /// - 'episode_detail': 节目详情窗口
  final String type;

  /// Episode 数据（用于 episode_detail 窗口）
  final Episode? episode;

  /// Podcast 数据（用于 episode_detail 窗口）
  final Podcast? podcast;

  WindowArguments({required this.type, this.episode, this.podcast});

  /// 将 WindowArguments 序列化为 JSON 字符串
  String toJson() {
    final Map<String, dynamic> data = {'type': type};

    if (episode != null) {
      data['episode'] = _episodeToJson(episode!);
    }

    if (podcast != null) {
      data['podcast'] = _podcastToJson(podcast!);
    }

    return jsonEncode(data);
  }
}

Map<String, dynamic> _episodeToJson(Episode episode) {
  return {
    'id': episode.id,
    'supabaseId': episode.supabaseId,
    'podcastId': episode.podcastId,
    'title': episode.title,
    'description': episode.description,
    'link': episode.link,
    'guid': episode.guid,
    'author': episode.author,
    'pubDate': episode.pubDate.toIso8601String(),
    'audioUrl': episode.audioUrl,
    'audioType': episode.audioType,
    'duration': episode.duration,
    'artworkUrl': episode.artworkUrl,
    'isExplicit': episode.isExplicit,
    'isPlayed': episode.isPlayed,
    'isDownloaded': episode.isDownloaded,
    'isFavorite': episode.isFavorite,
    'downloadedPath': episode.downloadedPath,
    'artworkPath': episode.artworkPath,
    'downloadProgress': episode.downloadProgress,
    'playProgress': episode.playProgress,
    'lastPlayedAt': episode.lastPlayedAt?.toIso8601String(),
    'createdAt': episode.createdAt.toIso8601String(),
    'updatedAt': episode.updatedAt.toIso8601String(),
    'itunesId': episode.itunesId,
    'podcastITunesId': episode.podcastITunesId,
    'itunesArtworkUrl': episode.itunesArtworkUrl,
    'itunesReleaseDate': episode.itunesReleaseDate?.toIso8601String(),
    'itunesExplicitness': episode.itunesExplicitness,
    'itunesContentAdvisoryRating': episode.itunesContentAdvisoryRating,
  };
}

Map<String, dynamic> _podcastToJson(Podcast podcast) {
  return {
    'id': podcast.id,
    'supabaseId': podcast.supabaseId,
    'title': podcast.title,
    'subtitle': podcast.subtitle,
    'author': podcast.author,
    'description': podcast.description,
    'artworkUrl': podcast.artworkUrl,
    'rssUrl': podcast.rssUrl,
    'websiteUrl': podcast.websiteUrl,
    'language': podcast.language,
    'copyright': podcast.copyright,
    'categories': podcast.categories,
    'keywords': podcast.keywords,
    'isExplicit': podcast.isExplicit,
    'ownerName': podcast.ownerName,
    'ownerEmail': podcast.ownerEmail,
    'lastUpdated': podcast.lastUpdated.toIso8601String(),
    'episodeCount': podcast.episodeCount,
    'isSubscribed': podcast.isSubscribed,
    'subscribedAt': podcast.subscribedAt?.toIso8601String(),
    'artworkPath': podcast.artworkPath,
    'createdAt': podcast.createdAt.toIso8601String(),
    'itunesId': podcast.itunesId,
    'itunesArtworkUrl': podcast.itunesArtworkUrl,
    'itunesPrimaryGenreName': podcast.itunesPrimaryGenreName,
    'itunesGenres': podcast.itunesGenres,
    'itunesGenreIds': podcast.itunesGenreIds,
    'itunesCollectionViewUrl': podcast.itunesCollectionViewUrl,
    'itunesCountry': podcast.itunesCountry,
    'itunesReleaseDate': podcast.itunesReleaseDate?.toIso8601String(),
    'itunesCollectionExplicitness': podcast.itunesCollectionExplicitness,
    'itunesContentAdvisoryRating': podcast.itunesContentAdvisoryRating,
    'lastFetchedAt': podcast.lastFetchedAt?.toIso8601String(),
    'refreshFailedCount': podcast.refreshFailedCount,
  };
}

Episode _episodeFromJson(Map<String, dynamic> json) {
  return Episode(
    id: _requiredInt(json, 'id'),
    supabaseId: _optionalString(json['supabaseId']),
    podcastId: _optionalInt(json['podcastId']) ?? 0,
    title: _optionalString(json['title']) ?? '',
    description: _optionalString(json['description']) ?? '',
    link: _optionalString(json['link']),
    guid: _optionalString(json['guid']),
    author: _optionalString(json['author']),
    pubDate: _dateTime(json['pubDate']) ?? DateTime.now(),
    audioUrl: _optionalString(json['audioUrl']) ?? '',
    audioType: _optionalString(json['audioType']) ?? 'audio/mpeg',
    duration: _optionalInt(json['duration']),
    artworkUrl: _optionalString(json['artworkUrl']),
    isExplicit: _bool(json['isExplicit']),
    isPlayed: _bool(json['isPlayed']),
    isDownloaded: _bool(json['isDownloaded']),
    isFavorite: _bool(json['isFavorite']),
    downloadedPath: _optionalString(json['downloadedPath']),
    artworkPath: _optionalString(json['artworkPath']),
    downloadProgress: _double(json['downloadProgress']),
    playProgress: _double(json['playProgress']),
    lastPlayedAt: _dateTime(json['lastPlayedAt']),
    createdAt: _dateTime(json['createdAt']) ?? DateTime.now(),
    updatedAt: _dateTime(json['updatedAt']) ?? DateTime.now(),
    itunesId: _optionalString(json['itunesId']),
    podcastITunesId: _optionalString(json['podcastITunesId']),
    itunesArtworkUrl: _optionalString(json['itunesArtworkUrl']),
    itunesReleaseDate: _dateTime(json['itunesReleaseDate']),
    itunesExplicitness: _optionalString(json['itunesExplicitness']),
    itunesContentAdvisoryRating: _optionalString(
      json['itunesContentAdvisoryRating'],
    ),
  );
}

Podcast _podcastFromJson(Map<String, dynamic> json) {
  return Podcast(
    id: _requiredInt(json, 'id'),
    supabaseId: _optionalString(json['supabaseId']),
    title: _optionalString(json['title']) ?? '',
    subtitle: _optionalString(json['subtitle']),
    author: _optionalString(json['author']) ?? '',
    description: _optionalString(json['description']) ?? '',
    artworkUrl: _optionalString(json['artworkUrl']) ?? '',
    rssUrl: _optionalString(json['rssUrl']) ?? '',
    websiteUrl: _optionalString(json['websiteUrl']),
    language: _optionalString(json['language']),
    copyright: _optionalString(json['copyright']),
    categories: _stringList(json['categories']),
    keywords: _stringList(json['keywords']),
    isExplicit: _bool(json['isExplicit']),
    ownerName: _optionalString(json['ownerName']),
    ownerEmail: _optionalString(json['ownerEmail']),
    lastUpdated: _dateTime(json['lastUpdated']) ?? DateTime.now(),
    episodeCount: _optionalInt(json['episodeCount']) ?? 0,
    isSubscribed: _bool(json['isSubscribed']),
    subscribedAt: _dateTime(json['subscribedAt']),
    artworkPath: _optionalString(json['artworkPath']),
    createdAt: _dateTime(json['createdAt']) ?? DateTime.now(),
    itunesId: _optionalString(json['itunesId']),
    itunesArtworkUrl: _optionalString(json['itunesArtworkUrl']),
    itunesPrimaryGenreName: _optionalString(json['itunesPrimaryGenreName']),
    itunesGenres: _stringList(json['itunesGenres']),
    itunesGenreIds: _stringList(json['itunesGenreIds']),
    itunesCollectionViewUrl: _optionalString(json['itunesCollectionViewUrl']),
    itunesCountry: _optionalString(json['itunesCountry']),
    itunesReleaseDate: _dateTime(json['itunesReleaseDate']),
    itunesCollectionExplicitness: _optionalString(
      json['itunesCollectionExplicitness'],
    ),
    itunesContentAdvisoryRating: _optionalString(
      json['itunesContentAdvisoryRating'],
    ),
    lastFetchedAt: _dateTime(json['lastFetchedAt']),
    refreshFailedCount: _optionalInt(json['refreshFailedCount']) ?? 0,
  );
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) return value.toInt();
  throw FormatException('窗口参数缺少有效的 "$key"');
}

int? _optionalInt(Object? value) => value is num ? value.toInt() : null;

double _double(Object? value) => value is num ? value.toDouble() : 0.0;

bool _bool(Object? value) => value is bool ? value : false;

String? _optionalString(Object? value) => value is String ? value : null;

List<String>? _stringList(Object? value) {
  return value is List ? value.whereType<String>().toList() : null;
}

DateTime? _dateTime(Object? value) {
  return value is String ? DateTime.tryParse(value) : null;
}

/// 解析窗口参数
///
/// 从字符串参数中解析窗口类型和数据，如果参数为空则默认返回主窗口类型
///
/// [arguments] 窗口参数字符串（JSON 格式）
/// 返回 [WindowArguments] 对象
WindowArguments parseArguments(String arguments) {
  if (arguments.trim().isEmpty) {
    return WindowArguments(type: 'main');
  }

  try {
    final decoded = jsonDecode(arguments);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('窗口参数不是 JSON 对象');
    }

    final type = _optionalString(decoded['type']) ?? 'main';

    Episode? episode;
    final episodeJson = decoded['episode'];
    if (episodeJson is Map<String, dynamic>) {
      try {
        episode = _episodeFromJson(episodeJson);
      } catch (e, stackTrace) {
        Logger.error(
          '❌ [WINDOW] Episode 参数解析失败',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }

    Podcast? podcast;
    final podcastJson = decoded['podcast'];
    if (podcastJson is Map<String, dynamic>) {
      try {
        podcast = _podcastFromJson(podcastJson);
      } catch (e, stackTrace) {
        Logger.error(
          '❌ [WINDOW] Podcast 参数解析失败',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }

    return WindowArguments(type: type, episode: episode, podcast: podcast);
  } catch (e, stackTrace) {
    Logger.error(
      '❌ [WINDOW] 窗口参数解析失败，回退主窗口',
      error: e,
      stackTrace: stackTrace,
    );
    return WindowArguments(type: 'main');
  }
}

Future<void> _initWindow({
  required String title,
  required Size size,
}) async {
  if (Platform.isIOS || Platform.isAndroid) {
    return;
  }

  await windowManager.ensureInitialized();

  final windowOptions = WindowOptions(
    size: size,
    center: true,
    title: title,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    backgroundColor: Platform.isWindows
        ? windowBackgroundColor
        : const Color(0x00000000),
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await WindowUtils.applyFrostedGlassEffect();
  await WindowUtils.enableFullSizeContent();
}

/// 初始化主窗口
///
/// 配置并显示应用的主窗口，使用隐藏标题栏样式
Future<void> initMainWindow() {
  return _initWindow(title: 'Tinycast', size: AppTheme.light.mainWindowSize);
}

/// 初始化设置窗口
///
/// 配置并显示应用的设置窗口，使用隐藏标题栏样式
Future<void> initSettingsWindow() {
  return _initWindow(title: 'Settings', size: AppTheme.light.settingsWindowSize);
}

/// 初始化订阅窗口
///
/// 配置并显示应用的订阅窗口，使用隐藏标题栏样式
Future<void> initSubscribeWindow() {
  return _initWindow(
    title: 'Subscribe',
    size: AppTheme.light.subscribeWindowSize,
  );
}

/// 初始化节目详情窗口
///
/// 配置并显示应用的节目详情窗口，使用隐藏标题栏样式
Future<void> initEpisodeDetailWindow() {
  return _initWindow(
    title: 'Episode Detail',
    size: AppTheme.light.episodeDetailWindowSize,
  );
}

PageRouteBuilder<T> _windowPageRouteBuilder<T>(
  RouteSettings settings,
  WidgetBuilder builder,
) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
  );
}

/// 桌面子窗口的统一根组件：窗口控制条、本地化与命名路由配置保持一致。
class _SubWindowApp extends StatelessWidget {
  final String title;
  final Widget home;
  final Color appColor;
  final Route<dynamic> Function(RouteSettings) onGenerateRoute;

  const _SubWindowApp({
    required this.title,
    required this.home,
    required this.appColor,
    required this.onGenerateRoute,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: title,
      color: appColor,
      onGenerateRoute: onGenerateRoute,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CN'), Locale('en')],
      pageRouteBuilder: _windowPageRouteBuilder,
      textStyle: const TextStyle(
        fontFamilyFallback: AppTextStyles.fontFamilyFallback,
        color: Color(0xFF000000),
        fontSize: 16,
        decoration: TextDecoration.none,
      ),
      home: home,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              if (Platform.isWindows) WindowControls(title: title),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  color: Platform.isWindows
                      ? windowBackgroundColor
                      : const Color(0x00000000),
                  child: child ?? const SizedBox(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 设置窗口应用组件
///
/// 显示 Settings 页面作为主界面
class SettingsWindowApp extends StatelessWidget {
  const SettingsWindowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return _SubWindowApp(
      title: 'Settings',
      home: const Settings(),
      appColor: const Color(0xFFFFFFFF),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

/// 订阅窗口应用组件
///
/// 显示 Subscribe 页面作为主界面
class SubscribeWindowApp extends StatelessWidget {
  const SubscribeWindowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return _SubWindowApp(
      title: 'Subscribe',
      home: const Subscribe(),
      appColor: const Color(0x00000000),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

/// 节目详情窗口应用组件
///
/// 显示 EpisodeDetail 页面作为主界面
class EpisodeDetailWindowApp extends StatelessWidget {
  final Episode? episode;
  final Podcast? podcast;

  const EpisodeDetailWindowApp({super.key, this.episode, this.podcast});

  @override
  Widget build(BuildContext context) {
    return _SubWindowApp(
      title: 'Episode Detail',
      home: EpisodeDetail(episode: episode, podcast: podcast),
      appColor: const Color(0x00000000),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
