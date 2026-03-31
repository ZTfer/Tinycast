import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/features/library/library_empty_page/library_empty_control_bar/library_empty_button.dart';

class LibraryEmptyControlBar extends StatelessWidget {
  final VoidCallback onRssSubscribe;
  final VoidCallback onSearchPodcast;

  const LibraryEmptyControlBar({
    super.key,
    required this.onRssSubscribe,
    required this.onSearchPodcast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 12,
      children: [
        LibraryEmptyButton(
          icon: Icon(LucideIcons.rss, size: 16),
          label: 'RSS 订阅',
          onPressed: onRssSubscribe,
        ),
        LibraryEmptyButton(
          icon: Icon(LucideIcons.search, size: 16),
          label: '搜索播客',
          onPressed: onSearchPodcast,
        ),
      ],
    );
  }
}
