import 'package:flutter/widgets.dart';
import 'package:tinycast/core/theme/app_theme.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/features/episode_detail/episode_info.dart';
import 'package:tinycast/presentation/features/episode_detail/show_info.dart';
import 'package:tinycast/presentation/features/episode_detail/episode_description.dart';

class EpisodeDetail extends StatelessWidget {
  final Episode? episode;
  final Podcast? podcast;

  const EpisodeDetail({super.key, this.episode, this.podcast});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.fromBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      color: theme.backgroundPrimary,
      child: ListView(
        children: [
          EpisodeInfo(episode: episode),
          const SizedBox(height: 4),
          ShowInfo(podcast: podcast),
          const SizedBox(height: 4),
          EpisodeDescription(description: episode?.description),
        ],
      ),
    );
  }
}
