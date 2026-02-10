import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tinycast/ui/common_widgets/mini_player/episode_control_button.dart';

class EpisodeControlBar extends StatelessWidget {
  const EpisodeControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          EpisodeControlButton(
            icon: const Icon(LucideIcons.gauge, size: 16),
            onPressed: () {},
          ),
          Row(
            spacing: 40,
            children: [
              EpisodeControlButton(
                icon: const Icon(LucideIcons.skipBack, size: 20),
                onPressed: () {},
              ),
              EpisodeControlButton(
                icon: const Icon(LucideIcons.play, size: 24),
                onPressed: () {},
              ),
              EpisodeControlButton(
                icon: const Icon(LucideIcons.skipForward, size: 20),
                onPressed: () {},
              ),
            ],
          ),
          EpisodeControlButton(
            icon: const Icon(LucideIcons.volume2, size: 16),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
