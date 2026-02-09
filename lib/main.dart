import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // App 根目录
  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Flutter Demo',
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
