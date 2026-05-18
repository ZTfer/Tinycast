import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/features/settings/settings.dart';
import 'package:tinycast/presentation/features/subscribe/subscribe.dart';
import 'package:tinycast/presentation/features/episode_detail/episode_detail.dart';
import 'package:tinycast/core/router/app_router.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tinycast/macos_window_utils.dart';

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
      data['episode'] = {
        'id': episode!.id,
        'podcastId': episode!.podcastId,
        'title': episode!.title,
        'description': episode!.description,
        'link': episode!.link,
        'guid': episode!.guid,
        'author': episode!.author,
        'pubDate': episode!.pubDate.toIso8601String(),
        'audioUrl': episode!.audioUrl,
        'audioType': episode!.audioType,
        'duration': episode!.duration,
        'artworkUrl': episode!.artworkUrl,
        'isExplicit': episode!.isExplicit,
        'isPlayed': episode!.isPlayed,
        'isDownloaded': episode!.isDownloaded,
        'downloadedPath': episode!.downloadedPath,
        'downloadProgress': episode!.downloadProgress,
        'playProgress': episode!.playProgress,
        'lastPlayedAt': episode!.lastPlayedAt?.toIso8601String(),
        'createdAt': episode!.createdAt.toIso8601String(),
        'updatedAt': episode!.updatedAt.toIso8601String(),
      };
    }

    if (podcast != null) {
      data['podcast'] = {
        'id': podcast!.id,
        'title': podcast!.title,
        'subtitle': podcast!.subtitle,
        'author': podcast!.author,
        'description': podcast!.description,
        'artworkUrl': podcast!.artworkUrl,
        'rssUrl': podcast!.rssUrl,
        'websiteUrl': podcast!.websiteUrl,
        'language': podcast!.language,
        'copyright': podcast!.copyright,
        'categories': podcast!.categories,
        'keywords': podcast!.keywords,
        'isExplicit': podcast!.isExplicit,
        'ownerName': podcast!.ownerName,
        'ownerEmail': podcast!.ownerEmail,
        'lastUpdated': podcast!.lastUpdated.toIso8601String(),
        'episodeCount': podcast!.episodeCount,
        'isSubscribed': podcast!.isSubscribed,
        'subscribedAt': podcast!.subscribedAt?.toIso8601String(),
        'createdAt': podcast!.createdAt.toIso8601String(),
      };
    }

    return jsonEncode(data);
  }
}

/// 解析窗口参数
///
/// 从字符串参数中解析窗口类型和数据，如果参数为空则默认返回主窗口类型
///
/// [arguments] 窗口参数字符串（JSON 格式）
/// 返回 [WindowArguments] 对象
WindowArguments parseArguments(String arguments) {
  if (arguments.isEmpty) {
    return WindowArguments(type: 'main');
  }

  try {
    final Map<String, dynamic> data = jsonDecode(arguments);
    final String type = data['type'] ?? 'main';

    Episode? episode;
    if (data['episode'] != null) {
      final ep = data['episode'];
      episode = Episode(
        id: ep['id'],
        podcastId: ep['podcastId'],
        title: ep['title'],
        description: ep['description'],
        link: ep['link'],
        guid: ep['guid'],
        author: ep['author'],
        pubDate: DateTime.parse(ep['pubDate']),
        audioUrl: ep['audioUrl'],
        audioType: ep['audioType'] ?? 'audio/mpeg',
        duration: ep['duration'],
        artworkUrl: ep['artworkUrl'],
        isExplicit: ep['isExplicit'] ?? false,
        isPlayed: ep['isPlayed'] ?? false,
        isDownloaded: ep['isDownloaded'] ?? false,
        downloadedPath: ep['downloadedPath'],
        downloadProgress: ep['downloadProgress']?.toDouble() ?? 0.0,
        playProgress: ep['playProgress']?.toDouble() ?? 0.0,
        lastPlayedAt: ep['lastPlayedAt'] != null
            ? DateTime.parse(ep['lastPlayedAt'])
            : null,
        createdAt: DateTime.parse(ep['createdAt']),
        updatedAt: DateTime.parse(ep['updatedAt']),
        itunesId: ep['itunesId'],
        podcastITunesId: ep['podcastITunesId'],
        itunesArtworkUrl: ep['itunesArtworkUrl'],
        itunesReleaseDate: ep['itunesReleaseDate'] != null
            ? DateTime.parse(ep['itunesReleaseDate'])
            : null,
        itunesExplicitness: ep['itunesExplicitness'],
        itunesContentAdvisoryRating: ep['itunesContentAdvisoryRating'],
      );
    }

    Podcast? podcast;
    if (data['podcast'] != null) {
      final pod = data['podcast'];
      podcast = Podcast(
        id: pod['id'],
        title: pod['title'],
        subtitle: pod['subtitle'],
        author: pod['author'],
        description: pod['description'],
        artworkUrl: pod['artworkUrl'],
        rssUrl: pod['rssUrl'],
        websiteUrl: pod['websiteUrl'],
        language: pod['language'],
        copyright: pod['copyright'],
        categories: pod['categories']?.cast<String>(),
        keywords: pod['keywords']?.cast<String>(),
        isExplicit: pod['isExplicit'] ?? false,
        ownerName: pod['ownerName'],
        ownerEmail: pod['ownerEmail'],
        lastUpdated: DateTime.parse(pod['lastUpdated']),
        episodeCount: pod['episodeCount'] ?? 0,
        isSubscribed: pod['isSubscribed'] ?? false,
        subscribedAt: pod['subscribedAt'] != null
            ? DateTime.parse(pod['subscribedAt'])
            : null,
        createdAt: DateTime.parse(pod['createdAt']),
      );
    }

    return WindowArguments(type: type, episode: episode, podcast: podcast);
  } catch (e) {
    // 解析失败时返回主窗口类型
    return WindowArguments(type: 'main');
  }
}

/// 初始化主窗口
///
/// 配置并显示应用的主窗口，使用隐藏标题栏样式
/// 窗口大小为 400x800，居中显示
Future<void> initMainWindow() async {
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(400, 800),
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    backgroundColor: const Color(0x00000000),
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await AcrylicWindowUtils.applyFrostedGlassEffect();
  await AcrylicWindowUtils.enableFullSizeContent();
}

/// 初始化设置窗口
///
/// 配置并显示应用的设置窗口，使用隐藏标题栏样式
/// 窗口大小为 600x380，居中显示
/// 该窗口用于显示应用的设置界面
Future<void> initSettingsWindow() async {
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(600, 380),
    center: true,
    backgroundColor: const Color(0x00000000),
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await AcrylicWindowUtils.applyFrostedGlassEffect();
  await AcrylicWindowUtils.enableFullSizeContent();
}

/// 初始化订阅窗口
///
/// 配置并显示应用的订阅窗口，使用隐藏标题栏样式
/// 窗口大小为 500x600，居中显示
/// 该窗口用于显示应用的订阅界面
Future<void> initSubscribeWindow() async {
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(500, 600),
    center: true,
    backgroundColor: const Color(0x00000000),
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await AcrylicWindowUtils.applyFrostedGlassEffect();
  await AcrylicWindowUtils.enableFullSizeContent();
}

/// 初始化节目详情窗口
///
/// 配置并显示应用的节目详情窗口，使用隐藏标题栏样式
/// 窗口大小为 600x700，居中显示
/// 该窗口用于显示节目的详细信息
Future<void> initEpisodeDetailWindow() async {
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(600, 700),
    center: true,
    backgroundColor: const Color(0x00000000),
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await AcrylicWindowUtils.applyFrostedGlassEffect();
  await AcrylicWindowUtils.enableFullSizeContent();
}

/// 设置窗口应用组件
///
/// 这是设置窗口的根组件，使用 WidgetsApp 作为基础
/// 显示 Settings 页面作为主界面
class SettingsWindowApp extends StatelessWidget {
  const SettingsWindowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Settings',
      color: const Color(0xFFFFFFFF),
      onGenerateRoute: AppRouter.generateRoute,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
        );
      },
      textStyle: const TextStyle(
        color: Color(0xFF000000),
        fontSize: 16,
        decoration: TextDecoration.none,
      ),
      home: const Settings(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            color: const Color(0xFFFFFFFF),
            child: child ?? const SizedBox(),
          ),
        );
      },
    );
  }
}

/// 订阅窗口应用组件
///
/// 这是订阅窗口的根组件，使用 WidgetsApp 作为基础
/// 显示 Subscribe 页面作为主界面
class SubscribeWindowApp extends StatelessWidget {
  const SubscribeWindowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Subscribe',
      color: const Color(0x00000000),
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
        );
      },
      textStyle: const TextStyle(
        color: Color(0xFF000000),
        fontSize: 16,
        decoration: TextDecoration.none,
      ),
      home: const Subscribe(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            color: const Color(0x00000000),
            child: child ?? const SizedBox(),
          ),
        );
      },
    );
  }
}

/// 节目详情窗口应用组件
///
/// 这是节目详情窗口的根组件，使用 WidgetsApp 作为基础
/// 显示 EpisodeDetail 页面作为主界面
class EpisodeDetailWindowApp extends StatelessWidget {
  final Episode? episode;
  final Podcast? podcast;

  const EpisodeDetailWindowApp({super.key, this.episode, this.podcast});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Episode Detail',
      color: const Color(0x00000000),
      onGenerateRoute: AppRouter.generateRoute,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
        );
      },
      textStyle: const TextStyle(
        color: Color(0xFF000000),
        fontSize: 16,
        decoration: TextDecoration.none,
      ),
      home: EpisodeDetail(episode: episode, podcast: podcast),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            color: const Color(0x00000000),
            child: child ?? const SizedBox(),
          ),
        );
      },
    );
  }
}
