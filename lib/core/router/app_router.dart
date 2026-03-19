import 'package:flutter/material.dart';
import 'package:tinycast/core/router/app_routes.dart';
import 'package:tinycast/presentation/pages/homepage.dart';
import 'package:tinycast/presentation/pages/library/library.dart';
import 'package:tinycast/presentation/pages/favorite/favorite.dart';
import 'package:tinycast/presentation/pages/downloads/downloads.dart';
import 'package:tinycast/presentation/pages/subscribe/subscribe.dart';
import 'package:tinycast/presentation/pages/settings/settings.dart';
import 'package:tinycast/presentation/pages/test_page/test_page.dart';
import 'package:tinycast/presentation/pages/search/search_page.dart';
import 'package:tinycast/presentation/pages/up_next_queue/up_next_queue.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomePage(),
          transitionDuration: Duration.zero,
        );
      case AppRoutes.queue:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const UpNextQueue(),
          transitionDuration: Duration.zero,
        );
      case AppRoutes.library:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Library(),
          transitionDuration: Duration.zero,
        );
      case AppRoutes.favorite:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Favorite(),
          transitionDuration: Duration.zero,
        );
      case AppRoutes.downloads:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Downloads(),
          transitionDuration: Duration.zero,
        );
      case AppRoutes.subscribe:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Subscribe(),
          transitionDuration: Duration.zero,
        );
      case AppRoutes.settings:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Settings(),
          transitionDuration: Duration.zero,
        );
      case AppRoutes.search:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SearchPage(),
          transitionDuration: Duration.zero,
        );
      case AppRoutes.testPage:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const TestPage(),
          transitionDuration: Duration.zero,
        );
      default:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomePage(),
          transitionDuration: Duration.zero,
        );
    }
  }

  static void navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateToAndRemoveUntil(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void navigateToAndReplace(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void pop(BuildContext context, {dynamic result}) {
    Navigator.pop(context, result);
  }

  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  /// 打开设置窗口
  static Future<void> openSettingsWindow() async {
    final controller = await WindowController.create(
      WindowConfiguration(hiddenAtLaunch: true, arguments: 'settings'),
    );
    await controller.show();
  }

  /// 打开订阅窗口
  static Future<void> openSubscribeWindow() async {
    final controller = await WindowController.create(
      WindowConfiguration(hiddenAtLaunch: true, arguments: 'subscribe'),
    );
    await controller.show();
  }
}
