import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/features/history/history_empty_page/history_empty_page.dart';
import 'package:tinycast/presentation/providers/play_history_provider.dart';
import 'package:tinycast/domain/entities/play_history.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_item.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/core/utils/html_tag_remove_utils.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/models/episode_model.dart' as episode_model;

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

class _HistoryItem extends ConsumerStatefulWidget {
  final PlayHistory history;
  final bool showDivider;

  const _HistoryItem({required this.history, required this.showDivider});

  @override
  ConsumerState<_HistoryItem> createState() => _HistoryItemState();
}

class _HistoryItemState extends ConsumerState<_HistoryItem> {
  late Future<Episode?> _episodeFuture;

  @override
  void initState() {
    super.initState();
    _episodeFuture = _loadEpisode();
  }

  @override
  void didUpdateWidget(_HistoryItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.history.episodeId != widget.history.episodeId ||
        oldWidget.history.lastUpdateTime != widget.history.lastUpdateTime) {
      _episodeFuture = _loadEpisode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Episode?>(
      future: _episodeFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final episode = snapshot.data!;
          return EpisodeItem(
            episode: episode,
            showDivider: widget.showDivider,
            onPlayPressed: () => _onPlayPressed(episode),
            onEpisodeTap: () => _onPlayPressed(episode),
          );
        }

        return EpisodeItem(
          episode: _convertToEpisodeFromHistory(),
          showDivider: widget.showDivider,
          onPlayPressed: () {},
          onEpisodeTap: () {},
        );
      },
    );
  }

  Future<Episode?> _loadEpisode() async {
    try {
      final isar = IsarService.instance.isar;
      final episodeModel = await isar.episodes.get(widget.history.episodeId);

      if (episodeModel == null) {
        Logger.warning(
          '⚠️ [History] Episode ${widget.history.episodeId} not found in database, using cached data',
        );
        return null;
      }

      final rawDescription = episodeModel.description;
      final processedDescription = rawDescription.isNotEmpty
          ? HtmlTagRemoveUtils.getListItemSummary(rawDescription)
          : '';

      return Episode(
        id: episodeModel.id,
        podcastId: episodeModel.podcastId,
        title: episodeModel.title,
        description: processedDescription,
        audioUrl: episodeModel.audioUrl,
        duration: episodeModel.duration ?? 0,
        artworkUrl: episodeModel.artworkUrl ?? '',
        pubDate: episodeModel.pubDate,
        isPlayed: episodeModel.isPlayed,
        isFavorite: false,
        createdAt: episodeModel.createdAt,
        updatedAt: episodeModel.updatedAt,
        itunesId: episodeModel.itunesId,
        podcastITunesId: episodeModel.podcastITunesId,
        itunesArtworkUrl: episodeModel.itunesArtworkUrl,
        itunesReleaseDate: episodeModel.itunesReleaseDate,
        itunesExplicitness: episodeModel.itunesExplicitness,
        itunesContentAdvisoryRating: episodeModel.itunesContentAdvisoryRating,
      );
    } catch (e, stackTrace) {
      Logger.error('❌ [History] Error loading episode',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Episode _convertToEpisodeFromHistory() {
    final rawDescription = widget.history.description ?? '';
    final processedDescription = rawDescription.isNotEmpty
        ? HtmlTagRemoveUtils.getListItemSummary(rawDescription)
        : '';

    return Episode(
      id: widget.history.episodeId,
      podcastId: widget.history.podcastId,
      title: widget.history.title,
      description: processedDescription,
      audioUrl: '',
      duration: (widget.history.playedDuration / 1000).round(),
      artworkUrl: widget.history.artworkUrl,
      pubDate: widget.history.lastUpdateTime,
      isPlayed: widget.history.isPlayed,
      isFavorite: false,
      createdAt: widget.history.createdAt,
      updatedAt: widget.history.lastUpdateTime,
      itunesId: widget.history.episodeITunesId,
      podcastITunesId: widget.history.podcastITunesId,
    );
  }

  Future<void> _onPlayPressed(Episode episode) async {
    try {
      Logger.info('▶️ [History] Playing episode: ${episode.title}');

      if (episode.audioUrl.isEmpty) {
        final fullEpisode = await _loadEpisode();
        if (fullEpisode != null) {
          await ref.read(playbackProvider.notifier).playEpisode(fullEpisode);
        }
      } else {
        await ref.read(playbackProvider.notifier).playEpisode(episode);
      }
    } catch (e, stackTrace) {
      Logger.error('❌ [History] Error playing episode',
          error: e, stackTrace: stackTrace);
    }
  }
}
