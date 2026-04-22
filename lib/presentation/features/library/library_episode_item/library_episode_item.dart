import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/presentation/features/library/library_episode_item/library_episode_play_button.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';

class LibraryEpisodeItem extends ConsumerWidget {
  final Episode episode;
  final VoidCallback? onTap;

  const LibraryEpisodeItem({super.key, required this.episode, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            ref.read(playbackProvider.notifier).playEpisode(episode);
          },
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              episode.title,
              style: const TextStyle(
                fontSize: 11,
                decoration: TextDecoration.none,
                color: Color(0xD9000000),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          LibraryEpisodePlayButton(
            episode: episode,
            onPressed: () {
              ref.read(playbackProvider.notifier).playEpisode(episode);
            },
          ),
        ],
      ),
    );
  }
}
