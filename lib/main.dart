import 'package:flutter/widgets.dart';
// import 'package:flutter/material.dart';
import 'package:tinycast/ui/page/homepage.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  // 必须添加这一行，否则 window_manager 会报错
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化窗口管理器
  await windowManager.ensureInitialized();

  // 设置窗口选项
  WindowOptions windowOptions = WindowOptions(
    size: Size(400, 800),
    center: true,
    // backgroundColor: const Color.fromARGB(0, 255, 255, 255),
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // 运行 App
  runApp(const MyApp());
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
