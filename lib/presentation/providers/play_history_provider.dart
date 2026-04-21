import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/data/models/play_history_model.dart';
import 'package:tinycast/data/repositories/play_history_repository.dart';
import 'package:tinycast/core/utils/logger.dart';

final playHistoryRepositoryProvider = Provider<PlayHistoryRepository>((ref) {
  return PlayHistoryRepository();
});

class PlayHistoryNotifier extends Notifier<List<PlayHistory>> {
  @override
  List<PlayHistory> build() {
    _loadCompletedHistories();
    return [];
  }

  Future<void> _loadCompletedHistories() async {
    final repository = ref.read(playHistoryRepositoryProvider);
    final histories = await repository.getCompletedHistories();
    state = histories;
  }

  Future<void> refresh() async {
    await _loadCompletedHistories();
  }

  void markAsCompletedLocally(int episodeId) {
    final index = state.indexWhere((h) => h.episodeId == episodeId);
    if (index != -1) {
      final updated = List<PlayHistory>.from(state);
      updated[index] = updated[index]
        ..isPlayed = true
        ..status = PlayHistoryStatus.completed
        ..lastUpdateTime = DateTime.now();
      state = updated;
    }
  }

  void removeByPodcastId(int podcastId) {
    Logger.info(' [HISTORY] removeByPodcastId($podcastId) 调用, 当前历史记录有 ${state.length} 条');
    final filtered = state.where((h) => h.podcastId != podcastId).toList();
    Logger.info('🔵 [HISTORY] 过滤后剩余 ${filtered.length} 条');
    if (filtered.length != state.length) {
      Logger.info('🔵 [HISTORY] 更新了历史状态');
      state = filtered;
    } else {
      Logger.info('🔵 [HISTORY] 没有匹配到该 podcast 的记录，状态未改变');
    }
  }
}

final completedHistoriesProvider =
    NotifierProvider<PlayHistoryNotifier, List<PlayHistory>>(
  PlayHistoryNotifier.new,
);

final latestPlayingHistoryProvider = FutureProvider<PlayHistory?>((ref) async {
  final repository = ref.watch(playHistoryRepositoryProvider);
  return repository.getLatestPlayingHistory();
});
