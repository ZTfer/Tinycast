import '../../core/utils/logger.dart';
import '../models/podcast_model.dart' as model;

class PodcastMergeResult {
  final model.Podcast primary;
  final List<model.Podcast> duplicates;

  PodcastMergeResult({required this.primary, this.duplicates = const []});
}

class PodcastMergeService {
  /// 查找重复的播客。
  ///
  /// 去重优先级：
  /// 1. **itunesId** — 最稳定的业务唯一标识，跨平台/跨区域一致
  /// 2. **id (自增主键)** — 本地数据库唯一标识，兜底方案
  ///
  /// 注意：不使用 rssUrl 或 domain，因为：
  /// - 同一域名下可能有多个播客（如 megaphone.fm 托管数千个播客）
  /// - RSS URL 可能因 CDN、重定向等原因发生变化
  static List<PodcastMergeResult> findDuplicates(List<model.Podcast> podcasts) {
    final subscribed = podcasts.where((p) => p.isSubscribed).toList();

    // 按 itunesId 分组（最优先）
    final itunesIdGroups = <String, List<model.Podcast>>{};
    // 未匹配到 itunesId 的播客，按 id 分组
    final unmatchedByItunesId = <model.Podcast>[];

    for (final podcast in subscribed) {
      final itunesId = podcast.itunesId;
      if (itunesId != null && itunesId.isNotEmpty) {
        itunesIdGroups.putIfAbsent(itunesId, () => []).add(podcast);
      } else {
        unmatchedByItunesId.add(podcast);
      }
    }

    final results = <PodcastMergeResult>[];

    // 处理有 itunesId 的组
    for (final entry in itunesIdGroups.entries) {
      final group = entry.value;
      if (group.length > 1) {
        // 按 subscribedAt 倒序，最新的作为主记录
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

    // 没有 itunesId 的播客，每个都是独立的（按 id 区分）
    for (final podcast in unmatchedByItunesId) {
      results.add(PodcastMergeResult(primary: podcast));
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
