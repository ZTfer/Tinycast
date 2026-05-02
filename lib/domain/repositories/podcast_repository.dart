import '../entities/podcast.dart';
import '../entities/episode.dart';
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
}
