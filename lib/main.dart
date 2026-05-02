import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tinycast/presentation/features/home/homepage.dart';
import 'package:tinycast/multi_window.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/services/audio_player_service.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/core/router/app_router.dart';
import 'package:tinycast/core/services/supabase_service.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';

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

/// Supabase 开发环境默认配置
/// 仅在 .env 文件未找到且未使用 --dart-define 时使用
const _devSupabaseUrl = 'https://mxbrxxwunpbxvxwraqyf.supabase.co';
const _devSupabaseAnonKey = 'sb_publishable_v7w2bXmX-jNi3eGIAkdgvQ_8U6J7Zxa';

/// 全局 Supabase 配置（用于 .env 加载失败时的回退）
String? _fallbackSupabaseUrl;
String? _fallbackSupabaseAnonKey;

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 加载 .env 环境变量文件
  // macOS 桌面应用运行时工作目录可能不是项目根目录
  bool envLoaded = false;
  try {
    await dotenv.load(fileName: '.env');
    envLoaded = true;
  } catch (_) {
    Logger.info('ℹ️ .env 文件未找到，将使用开发环境默认配置');
  }

  // 如果 .env 未加载，设置回退值
  if (!envLoaded) {
    Logger.info('🔧 设置 Supabase 开发环境默认配置');
    _fallbackSupabaseUrl = _devSupabaseUrl;
    _fallbackSupabaseAnonKey = _devSupabaseAnonKey;
    Logger.info('🔧 _fallbackSupabaseUrl = $_fallbackSupabaseUrl');
  }

  final windowController = await WindowController.fromCurrentEngine();
  final arguments = parseArguments(windowController.arguments);

  switch (arguments.type) {
    case 'main':
      await initMainWindow();
      await _initializeApp();
      runApp(const ProviderScope(child: MyApp()));
      break;
    case 'settings':
      await initSettingsWindow();
      await _initializeApp();
      runApp(const ProviderScope(child: SettingsWindowApp()));
      break;
    case 'subscribe':
      await initSubscribeWindow();
      await _initializeApp();
      runApp(const ProviderScope(child: SubscribeWindowApp()));
      break;
    case 'episode_detail':
      await initEpisodeDetailWindow();
      await _initializeApp();
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
      await _initializeApp();
      runApp(const ProviderScope(child: MyApp()));
  }
}

Future<void> _initializeApp() async {
  await IsarService.instance.open();
  await AudioPlayerService.instance.init();
  await Logger.initFileLogging();

  // 初始化 Supabase（如果配置了凭据）
  // 读取优先级：.env > 回退值 > --dart-define
  String? supabaseUrl;
  String? supabaseAnonKey;

  // 优先从 .env 读取
  try {
    supabaseUrl = dotenv.env['SUPABASE_URL'];
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  } catch (_) {
    // .env 未加载时访问 env 会抛出 NotInitializedError，安全忽略
  }

  // 其次使用回退值（开发模式）
  supabaseUrl ??= _fallbackSupabaseUrl;
  supabaseAnonKey ??= _fallbackSupabaseAnonKey;

  // 最后尝试编译时变量
  supabaseUrl ??= const String.fromEnvironment('SUPABASE_URL');
  supabaseAnonKey ??= const String.fromEnvironment('SUPABASE_ANON_KEY');

  // 过滤空字符串和纯空白字符，避免使用无效凭据初始化
  if (supabaseUrl.trim().isEmpty) supabaseUrl = null;
  if (supabaseAnonKey.trim().isEmpty) supabaseAnonKey = null;

  if (supabaseUrl != null && supabaseAnonKey != null) {
    await SupabaseService().initialize(
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
    );
    Logger.info('✅ Supabase 客户端初始化完成');
  } else {
    Logger.info('ℹ️ Supabase 未配置，跳过初始化');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Tinycast',
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
        fontFamily: 'PingFang SC',
        fontFamilyFallback: [
          'PingFang SC',
          'Noto Sans SC',
          'Roboto',
          'Heiti SC',
          'Microsoft YaHei',
          'sans-serif',
        ],
        color: Color(0xFF000000),
        fontSize: 16,
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.none,
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
