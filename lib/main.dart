import 'dart:async';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'package:tinycast/core/theme/app_text_styles.dart';
import 'package:tinycast/core/services/feed_refresh_scheduler.dart';
import 'package:tinycast/core/utils/app_window_context.dart';

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
  WidgetsFlutterBinding.ensureInitialized();
  _installGlobalErrorHandlers();
  await Logger.initFileLogging();

  final config = AppConfig.fromEnvironment();

  if (Platform.isIOS || Platform.isAndroid) {
    await _preloadTheme();
    await _startWindow(
      config,
      child: const MyApp(home: MobileHome()),
      initializeAudio: true,
      initializeSupabase: true,
      enableFeedRefresh: true,
    );
    return;
  }

  await WindowUtils.initialize();
  await _preloadTheme();

  final windowController = await WindowController.fromCurrentEngine();
  final arguments = parseArguments(windowController.arguments);

  switch (arguments.type) {
    case 'settings':
      AppWindowContext.isMainWindow = false;
      await initSettingsWindow();
      await _startWindow(
        config,
        child: const SettingsWindowApp(),
        initializeAudio: false,
        initializeSupabase: true,
      );
      break;
    case 'subscribe':
      AppWindowContext.isMainWindow = false;
      await initSubscribeWindow();
      await _startWindow(
        config,
        child: const SubscribeWindowApp(),
        initializeAudio: false,
        initializeSupabase: false,
      );
      break;
    case 'episode_detail':
      AppWindowContext.isMainWindow = false;
      await initEpisodeDetailWindow();
      await _startWindow(
        config,
        child: EpisodeDetailWindowApp(
          episode: arguments.episode,
          podcast: arguments.podcast,
        ),
        initializeAudio: false,
        initializeSupabase: false,
      );
      break;
    default:
      if (arguments.type != 'main') {
        Logger.warning('⚠️ [APP] 未知窗口类型，按主窗口启动: ${arguments.type}');
      }
      AppWindowContext.isMainWindow = true;
      await initMainWindow();
      await _startWindow(
        config,
        child: const MyApp(),
        initializeAudio: true,
        initializeSupabase: true,
        enableFeedRefresh: true,
      );
  }
}

void _installGlobalErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    Logger.error(
      '❌ [APP] Flutter 框架异常',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    Logger.error(
      '❌ [APP] 未捕获的异步异常',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  };
}

Future<void> _preloadTheme() async {
  if (ThemeSource.useHardcoded) {
    Logger.info('ℹ️ 使用硬编码主题常量（lib/core/theme）');
    return;
  }
  await ThemeLoader.preloadThemeConfigs();
  Logger.info('✅ HOCON 主题配置加载完成（使用 .conf 文件）');
}

/// 初始化当前窗口所需的本地服务。
///
/// 桌面多窗口各自运行在独立引擎中，Isar 必须逐窗口打开；音频与云同步
/// 只在真正需要的窗口初始化，避免重复注册媒体会话和认证监听。
Future<void> _initializeApp(
  AppConfig config, {
  required bool initializeAudio,
  required bool initializeSupabase,
}) async {
  try {
    await IsarService.instance.open();
    Logger.info('✅ Isar 数据库初始化完成');
  } catch (e, stackTrace) {
    Logger.error(
      '❌ [APP] Isar 数据库初始化失败，应用无法启动',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }

  if (initializeAudio) {
    try {
      await AudioPlayerService.instance.init();
      Logger.info('✅ 音频服务初始化完成');
    } catch (e, stackTrace) {
      Logger.error(
        '❌ [APP] 音频服务初始化失败，播放功能不可用',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  if (!initializeSupabase) return;

  if (config.isPlaceholder) {
    Logger.info('ℹ️ Supabase 未配置（使用占位符），跳过初始化');
    return;
  }

  try {
    await SupabaseService().initialize(
      supabaseUrl: config.supabaseUrl,
      supabaseAnonKey: config.supabaseAnonKey,
    );
    Logger.info('✅ Supabase 客户端初始化完成');
  } catch (e, stackTrace) {
    Logger.error(
      '❌ [APP] Supabase 初始化失败，云同步不可用',
      error: e,
      stackTrace: stackTrace,
    );
  }
}

Future<void> _startWindow(
  AppConfig config, {
  required Widget child,
  required bool initializeAudio,
  required bool initializeSupabase,
  bool enableFeedRefresh = false,
}) async {
  try {
    await _initializeApp(
      config,
      initializeAudio: initializeAudio,
      initializeSupabase: initializeSupabase,
    );
  } catch (e) {
    runApp(
      ProviderScope(child: StartupErrorApp(message: e.toString())),
    );
    return;
  }

  if (enableFeedRefresh) {
    WidgetsBinding.instance.addObserver(FeedRefreshLifecycleObserver.instance);
    unawaited(FeedRefreshScheduler.instance.start());
  }

  runApp(ProviderScope(child: child));
}

/// 应用根组件，桌面与移动端共用同一套路由、本地化与主题配置。
class MyApp extends StatefulWidget {
  final Widget home;

  const MyApp({super.key, this.home = const HomePage()});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Brightness _platformBrightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    if (brightness != _platformBrightness) {
      setState(() => _platformBrightness = brightness);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FeedRefreshLifecycleObserver.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Tinycast',
      color: const Color(0x00000000),
      onGenerateRoute: AppRouter.generateRoute,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CN'), Locale('en')],
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
        );
      },
      textStyle: TextStyle(
        fontFamilyFallback: AppTextStyles.fontFamilyFallback,
        color: _platformBrightness == Brightness.dark
            ? const Color(0xFFFFFFFF)
            : const Color(0xFF000000),
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      home: widget.home,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}

/// 启动失败时显示的最小界面，避免窗口静默空白。
class StartupErrorApp extends StatelessWidget {
  final String message;

  const StartupErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Tinycast',
      color: const Color(0xFFFEFEFE),
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
        );
      },
      textStyle: const TextStyle(
        color: Color(0xFF000000),
        fontSize: 14,
        decoration: TextDecoration.none,
      ),
      home: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'TinyCast 启动失败',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
