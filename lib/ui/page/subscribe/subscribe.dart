import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/subscribe/subscribe_action_bar/subscribe_action_bar.dart';
import 'package:tinycast/ui/page/subscribe/subscribe_by_opml/subscribe_by_opml.dart';
import 'package:tinycast/ui/page/subscribe/subscribe_by_rss/subscribe_by_rss.dart';
import 'package:tinycast/ui/page/subscribe/subscribe_tab/subscribe_tab.dart';


class Subscribe extends StatefulWidget {
  const Subscribe({super.key});

  @override
  State<Subscribe> createState() => _SubscribeState();
}

class _SubscribeState extends State<Subscribe> {
  String _currentPage = 'rss';

  void _navigateToPage(String page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SubscribeTab(
          currentPage: _currentPage,
          onPageChanged: _navigateToPage,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            alignment: Alignment.topLeft,
            child: _buildCurrentPage(),
          ),
        ),
        // 操作栏
        Container(
          padding: const EdgeInsets.all(12),
          alignment: Alignment.center,
          child: const SubscribeActionBar(),
        ),
      ],
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case 'rss':
        return const SubscribeByRss();
      case 'opml':
        return const SubscribeByOpml();
      default:
        return const SizedBox.shrink();
    }
  }
}
