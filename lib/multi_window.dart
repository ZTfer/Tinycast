import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/settings/settings.dart';
import 'package:window_manager/window_manager.dart';

/// 窗口参数类
///
/// 用于解析和存储窗口的配置参数，支持多种窗口类型
class WindowArguments {
  /// 窗口类型
  ///
  /// 可选值：
  /// - 'main': 主窗口
  /// - 'settings': 设置窗口
  final String type;

  WindowArguments({required this.type});
}

/// 解析窗口参数
///
/// 从字符串参数中解析窗口类型，如果参数为空则默认返回主窗口类型
///
/// [arguments] 窗口参数字符串
/// 返回 [WindowArguments] 对象
WindowArguments parseArguments(String arguments) {
  if (arguments.isEmpty) {
    return WindowArguments(type: 'main');
  }
  return WindowArguments(type: arguments);
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
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
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
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
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
