import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/common_widgets/sidebar/sidebar.dart';
import 'package:tinycast/ui/page/library/library.dart';
import 'package:tinycast/ui/page/up_next_queue/up_next_queue.dart';

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
      default:
        return const UpNextQueue();
    }
  }
}
