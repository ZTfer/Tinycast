import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/features/home/homepage.dart';
import 'package:tinycast/presentation/features/home/mobile_home.dart';
import 'package:tinycast/multi_window.dart';
import 'package:tinycast/window_utils.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/services/audio_player_service.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/core/router/app_router.dart';
import 'package:tinycast/core/services/supabase_service.dart';
import 'package:tinycast/core/theme/theme_loader.dart';
import 'package:tinycast/core/theme/theme_source_flag.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/core/theme/app_text_styles.dart';
import 'package:tinycast/core/services/feed_refresh_scheduler.dart';

/// 打开节目详情窗口
///
/// 创建并显示一个新的窗口，用于展示节目详情
/// [episode] 要展示的 episode 数据
/// [podcast] 关联的 podcast 数据
Future<void> openEpisodeDetailWindow(Episode episode, Podcast podcast) async {
  final arguments = WindowArguments(
    type: 'episode_detail',
    episode: episode,
    podcast: podcast,
  );

  final controller = await WindowController.create(
    WindowConfiguration(hiddenAtLaunch: true, arguments: arguments.toJson()),
  );
  await controller.show();
}

/// Supabase 配置占位符（编译时默认值）
/// 实际使用时通过 --dart-define 传入，不要硬编码真实凭据
/// 获取方式：https://supabase.com/dashboard/project/_/settings/api
/// 运行命令：flutter run --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx

/// 应用配置（统一管理所有编译时参数）
class AppConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;

  const AppConfig({required this.supabaseUrl, required this.supabaseAnonKey});

  factory AppConfig.fromEnvironment() {
    return AppConfig(
      supabaseUrl: const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://YOUR_PROJECT_ID.supabase.co',
      ),
      supabaseAnonKey: const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: 'YOUR_SUPABASE_ANON_KEY',
      ),
    );
  }

  bool get isPlaceholder {
    return supabaseUrl == 'https://YOUR_PROJECT_ID.supabase.co' ||
        supabaseAnonKey == 'YOUR_SUPABASE_ANON_KEY' ||
        supabaseUrl.trim().isEmpty ||
        supabaseAnonKey.trim().isEmpty;
  }
}

class FeedRefreshLifecycleObserver extends WidgetsBindingObserver {
  static final FeedRefreshLifecycleObserver _instance =
      FeedRefreshLifecycleObserver._();
  static FeedRefreshLifecycleObserver get instance => _instance;

  FeedRefreshLifecycleObserver._();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        FeedRefreshScheduler.instance.handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        FeedRefreshScheduler.instance.handleAppResumed();
        break;
      case AppLifecycleState.detached:
        FeedRefreshScheduler.instance.stop();
        WidgetsBinding.instance.removeObserver(this);
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void dispose() {
    FeedRefreshScheduler.instance.stop();
    WidgetsBinding.instance.removeObserver(this);
  }
}

void main(List<String> args) async {
  if (Platform.isIOS || Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    await _initializeApp(AppConfig.fromEnvironment());
    WidgetsBinding.instance.addObserver(FeedRefreshLifecycleObserver.instance);
    unawaited(FeedRefreshScheduler.instance.start());
    runApp(const ProviderScope(child: MyAppMobile()));
    return;
  }

  WidgetsFlutterBinding.ensureInitialized();
  await WindowUtils.initialize();

  if (!ThemeSource.useHardcoded) {
    await ThemeLoader.preloadThemeConfigs();
    Logger.info('✅ HOCON 主题配置加载完成（使用 .conf 文件）');
  } else {
    Logger.info('ℹ️ 使用硬编码主题常量（lib/core/theme）');
  }

  final config = AppConfig.fromEnvironment();

  final windowController = await WindowController.fromCurrentEngine();
  final arguments = parseArguments(windowController.arguments);

  switch (arguments.type) {
    case 'main':
      await initMainWindow();
      await _initializeApp(config);
      WidgetsBinding.instance.addObserver(
        FeedRefreshLifecycleObserver.instance,
      );
      unawaited(FeedRefreshScheduler.instance.start());
      runApp(const ProviderScope(child: MyApp()));
      break;
    case 'settings':
      await initSettingsWindow();
      await _initializeApp(config);
      runApp(const ProviderScope(child: SettingsWindowApp()));
      break;
    case 'subscribe':
      await initSubscribeWindow();
      await _initializeApp(config);
      runApp(const ProviderScope(child: SubscribeWindowApp()));
      break;
    case 'episode_detail':
      await initEpisodeDetailWindow();
      await _initializeApp(config);
      runApp(
        ProviderScope(
          child: EpisodeDetailWindowApp(
            episode: arguments.episode,
            podcast: arguments.podcast,
          ),
        ),
      );
      break;
    default:
      await initMainWindow();
      await _initializeApp(config);
      WidgetsBinding.instance.addObserver(
        FeedRefreshLifecycleObserver.instance,
      );
      unawaited(FeedRefreshScheduler.instance.start());
      runApp(const ProviderScope(child: MyApp()));
  }
}

Future<void> _initializeApp(AppConfig config) async {
  await IsarService.instance.open();
  await AudioPlayerService.instance.init();
  await Logger.initFileLogging();

  // 初始化 Supabase（如果配置了有效凭据）
  if (!config.isPlaceholder) {
    await SupabaseService().initialize(
      supabaseUrl: config.supabaseUrl,
      supabaseAnonKey: config.supabaseAnonKey,
    );
    Logger.info('✅ Supabase 客户端初始化完成');
  } else {
    Logger.info('ℹ️ Supabase 未配置（使用占位符），跳过初始化');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    FeedRefreshLifecycleObserver.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Tinycast',
      color: const Color(0x00000000),
      onGenerateRoute: AppRouter.generateRoute,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
        );
      },
      textStyle: TextStyle(
        fontFamilyFallback: AppTextStyles.fontFamilyFallback,
        color: const Color(0xFF000000),
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      home: const HomePage(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}

class MyAppMobile extends StatefulWidget {
  const MyAppMobile({super.key});

  @override
  State<MyAppMobile> createState() => _MyAppMobileState();
}

class _MyAppMobileState extends State<MyAppMobile> {
  @override
  void dispose() {
    FeedRefreshLifecycleObserver.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TinyCast Mobile',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamilyFallback: AppTextStyles.fontFamilyFallback,
          ),
          bodyMedium: TextStyle(
            fontFamilyFallback: AppTextStyles.fontFamilyFallback,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamilyFallback: AppTextStyles.fontFamilyFallback,
          ),
          bodyMedium: TextStyle(
            fontFamilyFallback: AppTextStyles.fontFamilyFallback,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MobileHome(),
    );
  }
}
