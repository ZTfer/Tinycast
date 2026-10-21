import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/usecases/get_unplayed_episodes_usecase.dart';
import 'package:tinycast/domain/repositories/play_history_repository.dart';
import 'package:tinycast/data/repositories/play_history_repository_impl.dart';
import 'package:tinycast/core/services/feed_refresh_scheduler.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';

enum UnplayedEpisodesStatus { initial, loading, success, error }

class _NotProvided {
  const _NotProvided();
}

const _notProvided = _NotProvided();

class UnplayedEpisodesState {
  final UnplayedEpisodesStatus status;
  final List<Episode> episodes;
  final String? errorMessage;

  UnplayedEpisodesState({
    this.status = UnplayedEpisodesStatus.initial,
    this.episodes = const [],
    this.errorMessage,
  });

  UnplayedEpisodesState copyWith({
    UnplayedEpisodesStatus? status,
    List<Episode>? episodes,
    Object? errorMessage = _notProvided,
  }) {
    return UnplayedEpisodesState(
      status: status ?? this.status,
      episodes: episodes ?? this.episodes,
      errorMessage: identical(errorMessage, _notProvided)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

final playHistoryRepositoryForUnplayedProvider = Provider<PlayHistoryRepository>((ref) {
  return PlayHistoryRepositoryImpl();
});

final getUnplayedEpisodesUseCaseProvider = Provider<GetUnplayedEpisodesUseCase>((ref) {
  final repository = ref.watch(podcastRepositoryProvider);
  return GetUnplayedEpisodesUseCase(repository);
});

class UnplayedEpisodesNotifier extends Notifier<UnplayedEpisodesState> {
  int _loadRequestId = 0;

  @override
  UnplayedEpisodesState build() {
    final subscription = FeedRefreshScheduler.instance.onRefreshCompleted.listen(
      (_) => loadUnplayedEpisodes(),
    );
    ref.onDispose(subscription.cancel);
    // Skip if a load was already kicked off before this microtask runs
    // (e.g. an immediate call from a test or caller after reading the notifier).
    Future.microtask(() {
      if (_loadRequestId == 0) {
        loadUnplayedEpisodes();
      }
    });
    return UnplayedEpisodesState();
  }

  GetUnplayedEpisodesUseCase get _getUnplayedEpisodesUseCase =>
      ref.read(getUnplayedEpisodesUseCaseProvider);

  PlayHistoryRepository get _playHistoryRepository =>
      ref.read(playHistoryRepositoryForUnplayedProvider);

  Future<void> loadUnplayedEpisodes() async {
    final requestId = ++_loadRequestId;
    state = state.copyWith(status: UnplayedEpisodesStatus.loading, errorMessage: null);
    try {
      // 从 Episode 表获取未播放列表（Episode.isPlayed 为缓存字段）
      final episodes = await _getUnplayedEpisodesUseCase();
      if (!ref.mounted || requestId != _loadRequestId) return;

      // 交叉验证：从 PlayHistory（唯一数据源）获取已播放的 episode ID
      final playedEpisodeIds = await _playHistoryRepository.getPlayedEpisodeIds();
      if (!ref.mounted || requestId != _loadRequestId) return;

      // 过滤掉 PlayHistory 中标记为已播放但 Episode 缓存未同步的条目
      final filteredEpisodes = episodes
          .where((episode) => !playedEpisodeIds.contains(episode.id))
          .toList();

      state = state.copyWith(status: UnplayedEpisodesStatus.success, episodes: filteredEpisodes);
    } catch (e) {
      if (!ref.mounted || requestId != _loadRequestId) return;
      state = state.copyWith(
        status: UnplayedEpisodesStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadUnplayedEpisodes();
  }

  void reset() {
    state = UnplayedEpisodesState();
  }
}

final unplayedEpisodesNotifierProvider = NotifierProvider<UnplayedEpisodesNotifier, UnplayedEpisodesState>(
  UnplayedEpisodesNotifier.new,
);

final unplayedEpisodesProvider = Provider<List<Episode>>((ref) {
  final state = ref.watch(unplayedEpisodesNotifierProvider);
  final sortedEpisodes = [...state.episodes];
  sortedEpisodes.sort((a, b) => b.pubDate.compareTo(a.pubDate));
  return sortedEpisodes;
});

final unplayedEpisodesLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(unplayedEpisodesNotifierProvider);
  return state.status == UnplayedEpisodesStatus.loading;
});
