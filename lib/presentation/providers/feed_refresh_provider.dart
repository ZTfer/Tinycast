import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/domain/repositories/podcast_repository.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';

enum FeedRefreshStatus { idle, loading, success, error }

class _NotProvided {
  const _NotProvided();
}

const _notProvided = _NotProvided();

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
    Object? errorMessage = _notProvided,
  }) {
    return FeedRefreshState(
      status: status ?? this.status,
      totalNewEpisodes: totalNewEpisodes ?? this.totalNewEpisodes,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      errorMessage: identical(errorMessage, _notProvided)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class FeedRefreshNotifier extends Notifier<FeedRefreshState> {
  int _refreshRequestId = 0;

  @override
  FeedRefreshState build() => FeedRefreshState();

  PodcastRepository get _repository =>
      ref.read(podcastRepositoryProvider);

  Future<void> refreshAll({bool force = false}) async {
    if (state.isRefreshing) {
      Logger.info('🔄 [FEED-REFRESH] refreshAll 已在进行中，跳过重复请求');
      return;
    }

    final requestId = ++_refreshRequestId;
    final stopwatch = Stopwatch()..start();
    Logger.info('🔄 [FEED-REFRESH] refreshAll 开始, force: $force');

    state = state.copyWith(
      status: FeedRefreshStatus.loading,
      errorMessage: null,
    );

    try {
      final result = await _repository.refreshAllFeeds(force: force);
      if (requestId != _refreshRequestId) return;

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
      if (requestId != _refreshRequestId) return;
      Logger.error('🔄 [FEED-REFRESH] refreshAll 失败: $e');
      state = state.copyWith(
        status: FeedRefreshStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshSingle(int podcastId) async {
    if (state.isRefreshing) {
      Logger.info('🔄 [FEED-REFRESH] refreshSingle 已在进行中，跳过重复请求');
      return;
    }

    final requestId = ++_refreshRequestId;
    final stopwatch = Stopwatch()..start();
    Logger.info('🔄 [FEED-REFRESH] refreshSingle 开始, podcastId: $podcastId');

    state = state.copyWith(
      status: FeedRefreshStatus.loading,
      errorMessage: null,
    );

    try {
      final result = await _repository.refreshPodcastFeed(podcastId);
      if (requestId != _refreshRequestId) return;

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
      if (requestId != _refreshRequestId) return;
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
