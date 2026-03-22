import '../entities/podcast.dart';
import '../entities/episode.dart';

abstract class PodcastRepository {
  Future<Podcast> subscribe(String rssUrl);

  Future<void> unsubscribe(int podcastId);

  Future<List<Podcast>> getSubscribedPodcasts();

  Future<Podcast?> getPodcastById(int id);

  Future<List<Episode>> getEpisodesByPodcastId(int podcastId);

  Future<List<Episode>> getUnplayedEpisodes();
}
