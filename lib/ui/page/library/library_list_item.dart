import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/library/library_episode_item.dart';
import 'package:tinycast/ui/page/library/library_show_info.dart';

class LibraryListItem extends StatelessWidget {
  final String showName;
  final String timeAgo;
  final List<String> episodeTitles;

  const LibraryListItem({
    super.key,
    required this.showName,
    required this.timeAgo,
    required this.episodeTitles,
  });

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
              LibraryShowInfo(showName: showName, timeAgo: timeAgo),
              const SizedBox(height: 8),
              Column(
                children: episodeTitles
                    .map((title) => LibraryEpisodeItem(title: title))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
