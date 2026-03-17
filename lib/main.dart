import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/homepage.dart';
import 'package:tinycast/ui/page/settings/settings.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

class WindowArguments {
  final String type;

  WindowArguments({required this.type});
}

WindowArguments parseArguments(String arguments) {
  if (arguments.isEmpty) {
    return WindowArguments(type: 'main');
  }
  return WindowArguments(type: arguments);
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final windowController = await WindowController.fromCurrentEngine();
  final arguments = parseArguments(windowController.arguments);

  switch (arguments.type) {
    case 'main':
      await _initMainWindow();
      runApp(const MyApp());
      break;
    case 'settings':
      await _initSettingsWindow();
      runApp(const SettingsWindowApp());
      break;
    default:
      await _initMainWindow();
      runApp(const MyApp());
  }
}

Future<void> _initMainWindow() async {
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(400, 800),
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

Future<void> _initSettingsWindow() async {
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(600, 800),
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

class SettingsWindowApp extends StatelessWidget {
  const SettingsWindowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Settings',
      color: const Color(0xFFFFFFFF),
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
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // App 根目录
  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Tinycast',
      color: const Color(0xFFFFFFFF),
      // WidgetsApp 需要 explicit 的 pageRouteBuilder
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
        );
      },
      // WidgetsApp 不提供默认的 textStyle，需要手动指定
      textStyle: const TextStyle(
        color: Color(0xFF000000),
        fontSize: 16,
        decoration: TextDecoration.none,
      ),
      home: const MyHomePage(),
      // WidgetsApp 默认不包含 Directionality，除非配置 localizationsDelegates
      // 在 builder 中包裹 Directionality 是最简单的做法
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
