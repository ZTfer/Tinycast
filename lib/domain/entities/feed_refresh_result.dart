/// Feed 刷新结果（领域层值对象，避免 Domain 依赖 Data 层服务）
class FeedRefreshResult {
  final int podcastId;
  final int newEpisodesCount;
  final bool success;
  final bool skipped;
  final String? error;

  FeedRefreshResult({
    required this.podcastId,
    this.newEpisodesCount = 0,
    this.success = false,
    this.skipped = false,
    this.error,
  });

  @override
  String toString() {
    if (success) {
      return 'FeedRefreshResult{podcastId: $podcastId, newEpisodes: $newEpisodesCount}';
    } else if (skipped) {
      return 'FeedRefreshResult{podcastId: $podcastId, skipped}';
    } else {
      return 'FeedRefreshResult{podcastId: $podcastId, error: $error}';
    }
  }
}

/// 批量 Feed 刷新结果
class BatchRefreshResult {
  final int totalNewEpisodes;
  final int successCount;
  final int skippedCount;
  final int failureCount;
  final List<FeedRefreshResult> results;

  BatchRefreshResult({
    this.totalNewEpisodes = 0,
    this.successCount = 0,
    this.skippedCount = 0,
    this.failureCount = 0,
    required this.results,
  });

  @override
  String toString() {
    return 'BatchRefreshResult{totalNew: $totalNewEpisodes, success: $successCount, skipped: $skippedCount, failures: $failureCount}';
  }
}
