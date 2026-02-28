import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tinycast/ui/common_widgets/mini_player/episode_control_bar/episode_control_button.dart';

class EpisodeControlBar extends StatelessWidget {
  const EpisodeControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 播放速度控制按钮
          EpisodeControlButton(
            icon: const Icon(LucideIcons.gauge, size: 16),
            onPressed: () {},
          ),
          Row(
            spacing: 40,
            children: [
              // 后退15秒按钮
              EpisodeControlButton(
                icon: const Icon(LucideIcons.skipBack, size: 20),
                onPressed: () {},
              ),
              // 播放/暂停按钮
              EpisodeControlButton(
                icon: const Icon(LucideIcons.play, size: 24),
                onPressed: () {},
              ),
              // 前进15秒按钮
              EpisodeControlButton(
                icon: const Icon(LucideIcons.skipForward, size: 20),
                onPressed: () {},
              ),
            ],
          ),
          // 音量控制按钮
          EpisodeControlButton(
            icon: const Icon(LucideIcons.volume2, size: 16),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
