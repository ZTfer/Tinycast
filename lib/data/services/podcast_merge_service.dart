import '../../core/utils/logger.dart';
import '../models/podcast_model.dart' as model;

class PodcastMergeResult {
  final model.Podcast primary;
  final List<model.Podcast> duplicates;

  PodcastMergeResult({required this.primary, this.duplicates = const []});
}

class PodcastMergeService {
  static List<PodcastMergeResult> findDuplicates(List<model.Podcast> podcasts) {
    final subscribed =
        podcasts.where((p) => p.isSubscribed).toList();
    final rssUrlGroups = <String, List<model.Podcast>>{};

    for (final podcast in subscribed) {
      final normalizedRss = podcast.rssUrl.toLowerCase().trim();
      rssUrlGroups.putIfAbsent(normalizedRss, () => []).add(podcast);
    }

    final results = <PodcastMergeResult>[];

    for (final entry in rssUrlGroups.entries) {
      final group = entry.value;
      if (group.length > 1) {
        group.sort((a, b) {
          if (a.subscribedAt != null && b.subscribedAt == null) return -1;
          if (a.subscribedAt == null && b.subscribedAt != null) return 1;
          if (a.subscribedAt != null && b.subscribedAt != null) {
            return b.subscribedAt!.compareTo(a.subscribedAt!);
          }
          return 0;
        });
        results.add(PodcastMergeResult(
          primary: group.first,
          duplicates: group.skip(1).toList(),
        ));
      } else {
        results.add(PodcastMergeResult(primary: group.first));
      }
    }

    Logger.info(
      'PodcastMergeService: ${results.length} 个合并组, '
      '${results.where((r) => r.duplicates.isNotEmpty).length} 个存在重复',
    );

    return results;
  }

  static List<model.Podcast> filterPrimaryPodcasts(
    List<model.Podcast> podcasts,
  ) {
    final results = findDuplicates(podcasts);
    return results.map((r) => r.primary).toList();
  }

  static Set<int> getDuplicateIds(List<model.Podcast> podcasts) {
    final results = findDuplicates(podcasts);
    final ids = <int>{};
    for (final result in results) {
      for (final dup in result.duplicates) {
        ids.add(dup.id);
      }
    }
    return ids;
  }
}
