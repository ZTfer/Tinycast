import '../../core/utils/logger.dart';
import '../models/podcast_model.dart' as model;

class PodcastMergeResult {
  final model.Podcast primary;
  final List<model.Podcast> duplicates;

  PodcastMergeResult({required this.primary, this.duplicates = const []});
}

class PodcastMergeService {
  static String? extractDomain(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();
      if (host.isEmpty) return null;
      return host.startsWith('www.') ? host.substring(4) : host;
    } catch (_) {
      final trimmed = url.trim().toLowerCase();
      final withoutScheme = trimmed
          .replaceFirst(RegExp(r'^https?://'), '')
          .replaceFirst(RegExp(r'^www\.'), '');
      final domain = withoutScheme.split('/').first.split('?').first;
      return domain.isEmpty ? null : domain;
    }
  }

  static double calculateFeedUrlSimilarity(String url1, String url2) {
    final normalized1 = url1.toLowerCase().trim();
    final normalized2 = url2.toLowerCase().trim();
    if (normalized1 == normalized2) return 1.0;
    final uri1 = Uri.tryParse(normalized1);
    final uri2 = Uri.tryParse(normalized2);
    if (uri1 == null || uri2 == null) return 0.0;
    if (uri1.host == uri2.host) return 0.7;
    final segments1 = uri1.pathSegments.join('/').toLowerCase();
    final segments2 = uri2.pathSegments.join('/').toLowerCase();
    if (segments1 == segments2 && uri1.host == uri2.host) return 0.9;
    final longer =
        segments1.length > segments2.length ? segments1 : segments2;
    final shorter =
        segments1.length > segments2.length ? segments2 : segments1;
    if (longer.isEmpty) return 0.0;
    var matches = 0;
    for (var i = 0; i <= longer.length - shorter.length; i++) {
      if (longer.substring(i, i + shorter.length) == shorter) {
        matches++;
      }
    }
    return matches > 0 ? 0.3 * (matches / longer.length) : 0.0;
  }

  static List<PodcastMergeResult> findDuplicates(List<model.Podcast> podcasts) {
    final subscribed =
        podcasts.where((p) => p.isSubscribed).toList();
    final domainGroups = <String, List<model.Podcast>>{};
    final noDomain = <model.Podcast>[];

    for (final podcast in subscribed) {
      final domain = extractDomain(podcast.websiteUrl);
      if (domain != null) {
        domainGroups.putIfAbsent(domain, () => []).add(podcast);
      } else {
        noDomain.add(podcast);
      }
    }

    final results = <PodcastMergeResult>[];

    for (final entry in domainGroups.entries) {
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

    for (var i = 0; i < noDomain.length; i++) {
      var matched = false;
      for (final result in results) {
        final similarity = calculateFeedUrlSimilarity(
          noDomain[i].rssUrl,
          result.primary.rssUrl,
        );
        if (similarity >= 0.7) {
          result.duplicates.add(noDomain[i]);
          matched = true;
          break;
        }
      }
      if (!matched) {
        var crossMatched = false;
        for (var j = 0; j < noDomain.length; j++) {
          if (i == j) continue;
          final similarity = calculateFeedUrlSimilarity(
            noDomain[i].rssUrl,
            noDomain[j].rssUrl,
          );
          if (similarity >= 0.7) {
            final existing = results.where(
              (r) => r.primary == noDomain[j],
            );
            if (existing.isNotEmpty) {
              existing.first.duplicates.add(noDomain[i]);
            } else {
              final other = results.where(
                (r) => r.duplicates.contains(noDomain[j]),
              );
              if (other.isNotEmpty) {
                other.first.duplicates.add(noDomain[i]);
              } else {
                results.add(PodcastMergeResult(
                  primary: noDomain[j],
                  duplicates: [noDomain[i]],
                ));
              }
            }
            crossMatched = true;
            break;
          }
        }
        if (!crossMatched) {
          results.add(PodcastMergeResult(primary: noDomain[i]));
        }
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
