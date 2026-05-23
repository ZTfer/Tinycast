import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/podcast_repository.dart';
import '../../core/utils/logger.dart';
import '../providers/podcast_provider.dart';

enum FeedRefreshStatus { idle, loading, success, error }

class FeedRefreshState {
  final FeedRefreshStatus status;
  final int totalNewEpisodes;
  final int successCount;
  final int failureCount;
  final String? errorMessage;

  FeedRefreshState({
    this.status = FeedRefreshStatus.idle,
    this.totalNewEpisodes = 0,
    this.successCount = 0,
    this.failureCount = 0,
    this.errorMessage,
  });

  bool get isRefreshing => status == FeedRefreshStatus.loading;

  FeedRefreshState copyWith({
    FeedRefreshStatus? status,
    int? totalNewEpisodes,
    int? successCount,
    int? failureCount,
    String? errorMessage,
  }) {
    return FeedRefreshState(
      status: status ?? this.status,
      totalNewEpisodes: totalNewEpisodes ?? this.totalNewEpisodes,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class FeedRefreshNotifier extends Notifier<FeedRefreshState> {
  @override
  FeedRefreshState build() => FeedRefreshState();

  PodcastRepository get _repository =>
      ref.read(podcastRepositoryProvider);

  Future<void> refreshAll({bool force = false}) async {
    final stopwatch = Stopwatch()..start();
    Logger.info('🔄 [FEED-REFRESH] refreshAll 开始, force: $force');

    state = state.copyWith(
      status: FeedRefreshStatus.loading,
      errorMessage: null,
    );

    try {
      final result = await _repository.refreshAllFeeds(force: force);

      state = state.copyWith(
        status: FeedRefreshStatus.success,
        totalNewEpisodes: result.totalNewEpisodes,
        successCount: result.successCount,
        failureCount: result.failureCount,
      );

      Logger.info(
        '🔄 [FEED-REFRESH] refreshAll 完成: 新剧集 ${result.totalNewEpisodes}, '
        '成功 ${result.successCount}, 失败 ${result.failureCount}, '
        '耗时 ${stopwatch.elapsedMilliseconds}ms',
      );

      _refreshUI();
    } catch (e) {
      Logger.error('🔄 [FEED-REFRESH] refreshAll 失败: $e');
      state = state.copyWith(
        status: FeedRefreshStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshSingle(int podcastId) async {
    final stopwatch = Stopwatch()..start();
    Logger.info('🔄 [FEED-REFRESH] refreshSingle 开始, podcastId: $podcastId');

    state = state.copyWith(
      status: FeedRefreshStatus.loading,
      errorMessage: null,
    );

    try {
      final result = await _repository.refreshPodcastFeed(podcastId);

      if (result.success) {
        state = state.copyWith(
          status: FeedRefreshStatus.success,
          totalNewEpisodes: result.newEpisodesCount,
          successCount: 1,
          failureCount: 0,
        );

        Logger.info(
          '🔄 [FEED-REFRESH] refreshSingle 完成, podcastId: $podcastId, '
          '新剧集 ${result.newEpisodesCount}, 耗时 ${stopwatch.elapsedMilliseconds}ms',
        );

        _refreshUI();
      } else {
        state = state.copyWith(
          status: FeedRefreshStatus.error,
          failureCount: 1,
          errorMessage: result.error,
        );

        Logger.warning(
          '🔄 [FEED-REFRESH] refreshSingle 失败, podcastId: $podcastId, '
          '错误: ${result.error}',
        );
      }
    } catch (e) {
      Logger.error('🔄 [FEED-REFRESH] refreshSingle 异常, podcastId: $podcastId, 错误: $e');
      state = state.copyWith(
        status: FeedRefreshStatus.error,
        failureCount: 1,
        errorMessage: e.toString(),
      );
    }
  }

  void _refreshUI() {
    ref.read(podcastProvider.notifier).loadSubscribedPodcasts();
  }

  void reset() {
    state = FeedRefreshState();
  }
}

final feedRefreshProvider = NotifierProvider<FeedRefreshNotifier, FeedRefreshState>(
  FeedRefreshNotifier.new,
);
