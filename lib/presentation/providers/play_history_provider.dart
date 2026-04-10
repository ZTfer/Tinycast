import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/data/models/play_history_model.dart';
import 'package:tinycast/data/repositories/play_history_repository.dart';

final playHistoryRepositoryProvider = Provider<PlayHistoryRepository>((ref) {
  return PlayHistoryRepository();
});

final completedHistoriesProvider = FutureProvider<List<PlayHistory>>((ref) async {
  final repository = ref.watch(playHistoryRepositoryProvider);
  return repository.getCompletedHistories();
});

final latestPlayingHistoryProvider = FutureProvider<PlayHistory?>((ref) async {
  final repository = ref.watch(playHistoryRepositoryProvider);
  return repository.getLatestPlayingHistory();
});

class PlayHistoryNotifier extends Notifier<List<PlayHistory>> {
  @override
  List<PlayHistory> build() {
    return [];
  }

  Future<void> refreshCompleted() async {
    final repository = ref.read(playHistoryRepositoryProvider);
    state = await repository.getCompletedHistories();
  }
}

final playHistoryNotifierProvider =
    NotifierProvider<PlayHistoryNotifier, List<PlayHistory>>(
  PlayHistoryNotifier.new,
);
