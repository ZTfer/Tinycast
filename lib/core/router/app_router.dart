import 'package:flutter/material.dart';
import 'package:tinycast/core/router/app_routes.dart';
import 'package:tinycast/presentation/pages/homepage.dart';
import 'package:tinycast/presentation/pages/library/library.dart';
import 'package:tinycast/presentation/pages/favorite/favorite.dart';
import 'package:tinycast/presentation/pages/downloads/downloads.dart';
import 'package:tinycast/presentation/pages/subscribe/subscribe.dart';
import 'package:tinycast/presentation/pages/settings/settings.dart';
import 'package:tinycast/presentation/pages/test_page/test_page.dart';
import 'package:tinycast/presentation/pages/up_next_queue/up_next_queue.dart';
import 'package:tinycast/presentation/pages/search/search_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MyHomePage(),
        );
      case AppRoutes.queue:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const UpNextQueue(),
        );
      case AppRoutes.library:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Library(),
        );
      case AppRoutes.favorite:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Favorite(),
        );
      case AppRoutes.downloads:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Downloads(),
        );
      case AppRoutes.subscribe:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Subscribe(),
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Settings(),
        );
      case AppRoutes.search:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SearchPage(),
        );
      case AppRoutes.testPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TestPage(),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MyHomePage(),
        );
    }
  }

  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateToAndRemoveUntil(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void navigateToAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void pop(BuildContext context, {dynamic result}) {
    Navigator.pop(context, result);
  }

  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }
}
