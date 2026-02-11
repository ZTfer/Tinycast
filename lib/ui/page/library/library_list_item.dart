import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/library/library_episode_item.dart';
import 'package:tinycast/ui/page/library/library_show_info.dart';

class LibraryListItem extends StatelessWidget {
  const LibraryListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LibraryShowInfo(showName: '半拿铁'),
              const SizedBox(height: 8),
              Column(
                children: const [
                  LibraryEpisodeItem(title: 'Vol.107 标题文字，标题文字，标题文...'),
                  LibraryEpisodeItem(title: 'Vol.107 标题文字，标题文字，标题文...'),
                  LibraryEpisodeItem(title: 'Vol.107 标题文字，标题文字，标题文...'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
