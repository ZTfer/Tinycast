import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/features/library/library_episode_item/library_episode_play_button.dart';

class LibraryEpisodeItem extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const LibraryEpisodeItem({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                decoration: TextDecoration.none,
                color: Color(0xD9000000),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          LibraryEpisodePlayButton(onPressed: onTap ?? () {}),
        ],
      ),
    );
  }
}
