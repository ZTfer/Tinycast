import 'package:flutter/widgets.dart';
import 'queue_episode_info.dart';
import 'queue_control_bar.dart';

class QueueItem extends StatelessWidget {
  const QueueItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // queue item info
          const QueueEpisodeInfo(),
          const SizedBox(width: 12),
          // control bar
          const QueueControlBar(),
        ],
      ),
    );
  }
}
