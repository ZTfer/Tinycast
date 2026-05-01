import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

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
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
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
