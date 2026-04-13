import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/features/history/history_empty_page/history_empty_page.dart';
import 'package:tinycast/presentation/providers/play_history_provider.dart';
import 'package:tinycast/data/models/play_history_model.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_item.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/core/utils/html_tag_remove_utils.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/models/episode_model.dart' as episode_model;

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

        return _HistoryItem(
          history: history,
          showDivider: !isLast,
        );
      },
    );
  }
}

class _HistoryItem extends ConsumerWidget {
  final PlayHistory history;
  final bool showDivider;

  const _HistoryItem({
    required this.history,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Episode?>(
      future: _loadEpisode(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final episode = snapshot.data!;
          return EpisodeItem(
            episode: episode,
            showDivider: showDivider,
            onPlayPressed: () => _onPlayPressed(ref, episode),
            onEpisodeTap: () => _onPlayPressed(ref, episode),
          );
        }

        return EpisodeItem(
          episode: _convertToEpisodeFromHistory(),
          showDivider: showDivider,
          onPlayPressed: () {},
          onEpisodeTap: () {},
        );
      },
    );
  }

  Future<Episode?> _loadEpisode() async {
    try {
      final isar = IsarService.instance.isar;
      final episodeModel = await isar.episodes.get(history.episodeId);

      if (episodeModel == null) {
        debugPrint('⚠️ [History] Episode ${history.episodeId} not found in database, using cached data');
        return null;
      }

      final rawDescription = episodeModel.description ?? '';
      final processedDescription = rawDescription.isNotEmpty
          ? HtmlTagRemoveUtils.getListItemSummary(rawDescription)
          : '';

      return Episode(
        id: episodeModel.id,
        podcastId: episodeModel.podcastId,
        title: episodeModel.title,
        description: processedDescription,
        audioUrl: episodeModel.audioUrl ?? '',
        duration: episodeModel.duration ?? 0,
        artworkUrl: episodeModel.artworkUrl,
        pubDate: episodeModel.pubDate ?? DateTime.now(),
        isPlayed: episodeModel.isPlayed,
        isFavorite: false,
        createdAt: episodeModel.createdAt,
        updatedAt: episodeModel.updatedAt ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ [History] Error loading episode: $e');
      return null;
    }
  }

  Episode _convertToEpisodeFromHistory() {
    final rawDescription = history.description ?? '';
    final processedDescription = rawDescription.isNotEmpty
        ? HtmlTagRemoveUtils.getListItemSummary(rawDescription)
        : '';

    return Episode(
      id: history.episodeId,
      podcastId: history.podcastId,
      title: history.title,
      description: processedDescription,
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
      
      if (episode.audioUrl.isEmpty) {
        final fullEpisode = await _loadEpisode();
        if (fullEpisode != null) {
          await ref.read(playbackProvider.notifier).playEpisode(fullEpisode);
        }
      } else {
        await ref.read(playbackProvider.notifier).playEpisode(episode);
      }
    } catch (e) {
      debugPrint('❌ [History] Error playing episode: $e');
    }
  }
}
