import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/features/history/history_empty_page/history_empty_page.dart';
import 'package:tinycast/presentation/providers/play_history_provider.dart';
import 'package:tinycast/domain/entities/play_history.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_item.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/core/utils/html_tag_remove_utils.dart';
import 'package:tinycast/core/utils/logger.dart';

class History extends ConsumerWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histories = ref.watch(completedHistoriesProvider);

    if (histories.isEmpty) {
      return const HistoryEmptyPage();
    }

    return ListView.builder(
      itemCount: histories.length,
      itemBuilder: (context, index) {
        final history = histories[index];
        final isLast = index == histories.length - 1;

        return _HistoryItem(history: history, showDivider: !isLast);
      },
    );
  }
}

class _HistoryItem extends ConsumerWidget {
  final PlayHistory history;
  final bool showDivider;

  const _HistoryItem({required this.history, required this.showDivider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episode = ref.watch(episodeByIdProvider(history.episodeId)).value;

    if (episode != null) {
      return EpisodeItem(
        episode: _withSummaryDescription(episode),
        showDivider: showDivider,
        onPlayPressed: () => _play(ref, episode),
        onEpisodeTap: () => _play(ref, episode),
      );
    }

    return EpisodeItem(
      episode: _convertToEpisodeFromHistory(),
      showDivider: showDivider,
      onPlayPressed: () => _play(ref, null),
      onEpisodeTap: () => _play(ref, null),
    );
  }

  Episode _withSummaryDescription(Episode episode) {
    if (episode.description.isEmpty) return episode;
    return episode.copyWith(
      description: HtmlTagRemoveUtils.getListItemSummary(episode.description),
    );
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
      itunesId: history.episodeITunesId,
      podcastITunesId: history.podcastITunesId,
    );
  }

  Future<void> _play(WidgetRef ref, Episode? resolvedEpisode) async {
    try {
      var episode = resolvedEpisode;
      if (episode == null || episode.audioUrl.isEmpty) {
        episode = await ref.read(episodeByIdProvider(history.episodeId).future);
      }
      if (episode == null) {
        Logger.warning(
          '⚠️ [History] Episode ${history.episodeId} 已不存在，无法播放',
        );
        return;
      }
      Logger.info('▶️ [History] Playing episode: ${episode.title}');
      await ref.read(playbackProvider.notifier).playEpisode(episode);
    } catch (e, stackTrace) {
      Logger.error(
        '❌ [History] Error playing episode',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
