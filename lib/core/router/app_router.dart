import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:tinycast/core/router/app_routes.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/features/home/homepage.dart';
import 'package:tinycast/presentation/features/library/library.dart';
import 'package:tinycast/presentation/features/favorite/favorite.dart';
import 'package:tinycast/presentation/features/history/history.dart';
import 'package:tinycast/presentation/features/downloads/downloads.dart';
import 'package:tinycast/presentation/features/subscribe/subscribe.dart';
import 'package:tinycast/presentation/features/settings/settings.dart';
import 'package:tinycast/presentation/features/debug/test_page.dart';
import 'package:tinycast/presentation/features/search/search_page.dart';
import 'package:tinycast/presentation/features/queue/queue.dart';
import 'package:tinycast/presentation/features/library/podcast_detail/podcast_detail.dart';
import 'package:tinycast/presentation/features/episode_detail/episode_detail.dart';
import 'package:tinycast/presentation/features/debug/database_cleanup_page.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

class AppRouter {
  static PageRouteBuilder<dynamic> _buildRoute(
    RouteSettings settings,
    WidgetBuilder builder,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: Duration.zero,
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final isDebugOnlyRoute =
        settings.name == AppRoutes.testPage ||
        settings.name == AppRoutes.databaseCleanup;
    if (!kDebugMode && isDebugOnlyRoute) {
      Logger.warning('⚠️ [ROUTER] 调试路由在生产环境不可用: ${settings.name}');
      settings = const RouteSettings(name: AppRoutes.home);
    }

    switch (settings.name) {
      case AppRoutes.home:
        return _buildRoute(settings, (_) => const HomePage());
      case AppRoutes.queue:
        return _buildRoute(settings, (_) => const Queue());
      case AppRoutes.library:
        return _buildRoute(settings, (_) => const Library());
      case AppRoutes.favorite:
        return _buildRoute(settings, (_) => const Favorite());
      case AppRoutes.history:
        return _buildRoute(settings, (_) => const History());
      case AppRoutes.downloads:
        return _buildRoute(settings, (_) => const Downloads());
      case AppRoutes.subscribe:
        return _buildRoute(settings, (_) => const Subscribe());
      case AppRoutes.settings:
        return _buildRoute(settings, (_) => const Settings());
      case AppRoutes.search:
        return _buildRoute(settings, (_) => const SearchPage());
      case AppRoutes.testPage:
        return _buildRoute(settings, (_) => const TestPage());
      case AppRoutes.podcastDetail:
        final podcastId = switch (settings.arguments) {
          final int id => id,
          final Podcast podcast => podcast.id,
          _ => null,
        };
        if (podcastId == null) {
          Logger.error(
            '❌ [ROUTER] podcastDetail 缺少有效的播客参数: '
            '${settings.arguments}',
          );
          return _buildRoute(settings, (_) => const HomePage());
        }
        return _buildRoute(
          settings,
          (_) => PodcastDetail(podcastId: podcastId),
        );
      case AppRoutes.episodeDetail:
        final args = settings.arguments;
        final episode = switch (args) {
          final Episode episode => episode,
          final Map<String, dynamic> map when map['episode'] is Episode =>
            map['episode'] as Episode,
          _ => null,
        };
        if (episode == null) {
          Logger.warning(
            '⚠️ [ROUTER] episodeDetail 未携带可用的 Episode 参数: $args',
          );
        }
        return _buildRoute(
          settings,
          (_) => EpisodeDetail(episode: episode),
        );
      case AppRoutes.databaseCleanup:
        return _buildRoute(settings, (_) => const DatabaseCleanupPage());
      default:
        Logger.warning('⚠️ [ROUTER] 未注册的路由，回退首页: ${settings.name}');
        return _buildRoute(settings, (_) => const HomePage());
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

  static const _settingsWindowArguments = '{"type":"settings"}';

  static Future<void>? _settingsWindowOpening;

  /// 打开设置窗口
  static Future<void> openSettingsWindow() {
    return _settingsWindowOpening ??=
        _showSingletonWindow(_settingsWindowArguments).whenComplete(() {
      _settingsWindowOpening = null;
    });
  }

  static Future<void> _showSingletonWindow(String arguments) async {
    final windows = await WindowController.getAll();
    for (final window in windows) {
      if (window.arguments == arguments) {
        await window.show();
        return;
      }
    }
    final controller = await WindowController.create(
      WindowConfiguration(hiddenAtLaunch: true, arguments: arguments),
    );
    await controller.show();
  }
}
