import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/features/history/history_empty_page/history_empty_page.dart';
import 'package:tinycast/presentation/providers/play_history_provider.dart';
import 'package:tinycast/data/models/play_history_model.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_item.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';
import 'package:tinycast/domain/entities/episode.dart';

class History extends ConsumerWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🔍 [History] ====== BUILD METHOD CALLED ======');
    final histories = ref.watch(completedHistoriesProvider);
    debugPrint('🔍 [History] 📊 Current state length: ${histories.length}');

    if (histories.isEmpty) {
      debugPrint('🔍 [History] 📭 Showing empty page (no completed records)');
      return const HistoryEmptyPage();
    }

    debugPrint('🔍 [History] 📝 Building list with ${histories.length} items');
    return ListView.builder(
      itemCount: histories.length,
      itemBuilder: (context, index) {
        final history = histories[index];
        final isLast = index == histories.length - 1;

        return _buildHistoryItem(
          context,
          ref,
          history,
          showDivider: !isLast,
        );
      },
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    WidgetRef ref,
    PlayHistory history, {
    required bool showDivider,
  }) {
    final episode = _convertToEpisode(history);

    return EpisodeItem(
      episode: episode,
      showDivider: showDivider,
      onPlayPressed: () => _onPlayPressed(ref, episode),
      onEpisodeTap: () => _onPlayPressed(ref, episode),
    );
  }

  Episode _convertToEpisode(PlayHistory history) {
    return Episode(
      id: history.episodeId,
      podcastId: history.podcastId,
      title: history.title,
      description: '',
      audioUrl: '',
      duration: (history.playedDuration / 1000).round(),
      artworkUrl: history.artworkUrl,
      pubDate: history.lastUpdateTime,
      isPlayed: history.isPlayed,
      isFavorite: false,
      createdAt: history.createdAt,
      updatedAt: history.lastUpdateTime,
    );
  }

  Future<void> _onPlayPressed(WidgetRef ref, Episode episode) async {
    try {
      debugPrint('▶️ [History] Playing episode: ${episode.title}');
      await ref.read(playbackProvider.notifier).playEpisode(episode);
    } catch (e) {
      debugPrint('❌ [History] Error playing episode: $e');
    }
  }
}
