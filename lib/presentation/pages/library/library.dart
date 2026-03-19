import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/pages/library/library_list_item/library_list_item.dart';

class Library extends StatelessWidget {
  const Library({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LibraryListItem(
              showName: '半拿铁',
              timeAgo: '1 h ago',
              episodeTitles: [
                'Vol.107 标题文字，标题文字，标题文...',
                'Vol.107 标题文字，标题文字，标题文...',
                'Vol.107 标题文字，标题文字，标题文...',
              ],
            ),
            const LibraryListItem(
              showName: '半拿铁',
              timeAgo: '2 h ago',
              episodeTitles: [
                'Vol.106 标题文字，标题文字，标题文...',
                'Vol.106 标题文字，标题文字，标题文...',
                'Vol.106 标题文字，标题文字，标题文...',
              ],
            ),
            const LibraryListItem(
              showName: '半拿铁',
              timeAgo: '3 h ago',
              episodeTitles: [
                'Vol.105 标题文字，标题文字，标题文...',
                'Vol.105 标题文字，标题文字，标题文...',
                'Vol.105 标题文字，标题文字，标题文...',
              ],
            ),
            const LibraryListItem(
              showName: '半拿铁',
              timeAgo: '4 h ago',
              episodeTitles: [
                'Vol.104 标题文字，标题文字，标题文...',
                'Vol.104 标题文字，标题文字，标题文...',
                'Vol.104 标题文字，标题文字，标题文...',
              ],
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }
}
