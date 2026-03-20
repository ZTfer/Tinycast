import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/pages/library/library_empty_page/library_empty_info.dart';
import 'package:tinycast/presentation/pages/library/library_empty_page/library_empty_control_bar/library_empty_control_bar.dart';

class LibraryEmptyPage extends StatelessWidget {
  final VoidCallback onRssSubscribe;
  final VoidCallback onSearchPodcast;

  const LibraryEmptyPage({
    super.key,
    required this.onRssSubscribe,
    required this.onSearchPodcast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 18.0,
      children: [
        LibraryEmptyInfo(),
        LibraryEmptyControlBar(
          onRssSubscribe: onRssSubscribe,
          onSearchPodcast: onSearchPodcast,
        ),
        Text('通过搜索或 RSS 订阅播客'),
      ],
    );
  }
}
