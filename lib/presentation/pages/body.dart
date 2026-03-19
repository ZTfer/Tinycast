import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/widgets/molecules/sidebar/sidebar.dart';
import 'package:tinycast/presentation/pages/downloads/downloads.dart';
import 'package:tinycast/presentation/pages/favorite/favorite.dart';
import 'package:tinycast/presentation/pages/library/library.dart';
import 'package:tinycast/presentation/pages/subscribe/subscribe.dart';
import 'package:tinycast/presentation/pages/test_page/test_page.dart';
import 'package:tinycast/presentation/pages/up_next_queue/up_next_queue.dart';
import 'package:tinycast/presentation/pages/settings/settings.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String _currentPage = 'queue';

  void _navigateToPage(String page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Row(
        children: [
          Sidebar(currentPage: _currentPage, onPageChanged: _navigateToPage),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              alignment: Alignment.topLeft,
              child: _buildCurrentPage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case 'library':
        return const Library();
      case 'favorite':
        return const Favorite();
      case 'downloads':
        return const Downloads();
      case 'subscribe':
        return const Subscribe();
      case 'testpage':
        return const TestPage();
      case 'settings':
        return const Settings();
      default:
        return const UpNextQueue();
    }
  }
}
