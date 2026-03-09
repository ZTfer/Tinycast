import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/library/library_episode_item/library_episode_play_button.dart';

class LibraryEpisodeItem extends StatelessWidget {
  final String title;

  const LibraryEpisodeItem({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 11, color: Color(0xD9000000)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        LibraryEpisodePlayButton(onPressed: () {}),
      ],
    );
  }
}
