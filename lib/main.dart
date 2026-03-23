import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/pages/homepage.dart';
import 'package:tinycast/multi_window.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/services/audio_player_service.dart';
import 'package:tinycast/core/router/app_router.dart';

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
    default:
      await initMainWindow();
      await _initializeApp();
      runApp(const ProviderScope(child: MyApp()));
  }
}

Future<void> _initializeApp() async {
  await IsarService.instance.open();
  await AudioPlayerService.instance.init();
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
