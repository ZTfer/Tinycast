import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/widgets/molecules/mini_player/episode_info.dart';
import 'show_info.dart';
import 'episode_description.dart';

class EpisodeDetail extends StatelessWidget {
  const EpisodeDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: [
          const EpisodeInfo(),
          const SizedBox(height: 4),
          const ShowInfo(),
          const SizedBox(height: 4),
          const EpisodeDescription(),
        ],
      ),
    );
  }
}