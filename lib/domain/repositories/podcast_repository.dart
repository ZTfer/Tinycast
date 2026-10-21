import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/feed_refresh_result.dart';
import 'dart:async';

abstract class PodcastRepository {
  Future<Podcast> subscribe(String rssUrl);

  Future<void> unsubscribe(int podcastId);

  Future<List<Podcast>> getSubscribedPodcasts();

  Future<List<Podcast>> getMergedSubscribedPodcasts();

  Future<Podcast?> getPodcastById(int id);

  Future<List<Episode>> getEpisodesByPodcastId(int podcastId);

  Future<List<Episode>> getLatestEpisodesByPodcastId(
    int podcastId, {
    int limit = 3,
  });

  Future<List<Episode>> getUnplayedEpisodes();

  Future<List<Episode>> getEpisodesByIds(List<int> ids);

  Future<List<Episode>> getDownloadedEpisodes();

  Future<List<Podcast>> searchPodcasts(String keyword);

  Future<List<Episode>> searchEpisodes(String keyword);

  Future<void> updateIsPlayed(int episodeId, bool isPlayed);

  Future<void>? getITunesSearchFuture(int podcastId);

  Future<FeedRefreshResult> refreshPodcastFeed(int podcastId);

  Future<BatchRefreshResult> refreshAllFeeds({bool force = false});
}
