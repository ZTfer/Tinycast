import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/episode.dart';
import '../../domain/repositories/queue_repository.dart';
import '../../domain/usecases/get_queue_usecase.dart';
import '../../domain/usecases/add_to_queue_usecase.dart';
import '../../domain/usecases/remove_from_queue_usecase.dart';
import '../../domain/usecases/remove_from_queue_by_episode_id_usecase.dart';
import '../../domain/usecases/clear_queue_usecase.dart';
import '../../domain/usecases/insert_to_queue_front_usecase.dart';
import '../../data/repositories/queue_repository_impl.dart';
import 'podcast_provider.dart';
import '../../core/utils/logger.dart';

final queueRepositoryProvider = Provider<QueueRepository>((ref) {
  return QueueRepositoryImpl();
});

final getQueueUseCaseProvider = Provider<GetQueueUseCase>((ref) {
  final queueRepo = ref.watch(queueRepositoryProvider);
  final podcastRepo = ref.watch(podcastRepositoryProvider);
  return GetQueueUseCase(queueRepo, podcastRepo);
});

final addToQueueUseCaseProvider = Provider<AddToQueueUseCase>((ref) {
  final repository = ref.watch(queueRepositoryProvider);
  return AddToQueueUseCase(repository);
});

final insertToQueueFrontUseCaseProvider = Provider<InsertToQueueFrontUseCase>((ref) {
  final repository = ref.watch(queueRepositoryProvider);
  return InsertToQueueFrontUseCase(repository);
});

final removeFromQueueUseCaseProvider = Provider<RemoveFromQueueUseCase>((ref) {
  final repository = ref.watch(queueRepositoryProvider);
  return RemoveFromQueueUseCase(repository);
});

final removeFromQueueByEpisodeIdUseCaseProvider = Provider<RemoveFromQueueByEpisodeIdUseCase>((ref) {
  final repository = ref.watch(queueRepositoryProvider);
  return RemoveFromQueueByEpisodeIdUseCase(repository);
});

final clearQueueUseCaseProvider = Provider<ClearQueueUseCase>((ref) {
  final repository = ref.watch(queueRepositoryProvider);
  return ClearQueueUseCase(repository);
});

enum QueueStatus { initial, loading, success, error }

class QueueState {
  final QueueStatus status;
  final List<Episode> queueEpisodes;
  final String? errorMessage;

  QueueState({
    this.status = QueueStatus.initial,
    this.queueEpisodes = const [],
    this.errorMessage,
  });

  QueueState copyWith({
    QueueStatus? status,
    List<Episode>? queueEpisodes,
    String? errorMessage,
  }) {
    return QueueState(
      status: status ?? this.status,
      queueEpisodes: queueEpisodes ?? this.queueEpisodes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class QueueNotifier extends Notifier<QueueState> {
  @override
  QueueState build() {
    Future.microtask(() => loadQueue());
    return QueueState();
  }

  GetQueueUseCase get _getQueueUseCase => ref.read(getQueueUseCaseProvider);

  AddToQueueUseCase get _addToQueueUseCase =>
      ref.read(addToQueueUseCaseProvider);

  InsertToQueueFrontUseCase get _insertToQueueFrontUseCase =>
      ref.read(insertToQueueFrontUseCaseProvider);

  RemoveFromQueueUseCase get _removeFromQueueUseCase =>
      ref.read(removeFromQueueUseCaseProvider);

  RemoveFromQueueByEpisodeIdUseCase get _removeFromQueueByEpisodeIdUseCase =>
      ref.read(removeFromQueueByEpisodeIdUseCaseProvider);

  ClearQueueUseCase get _clearQueueUseCase =>
      ref.read(clearQueueUseCaseProvider);

  Future<void> loadQueue() async {
    Logger.info('📋 [QUEUE-PROVIDER] ====== loadQueue 开始 ======');
    state = state.copyWith(status: QueueStatus.loading, errorMessage: null);

    try {
      final episodes = await _getQueueUseCase();
      Logger.info(
          '📋 [QUEUE-PROVIDER] loadQueue 成功, 收到 ${episodes.length} 条队列记录');
      state = state.copyWith(status: QueueStatus.success, queueEpisodes: episodes);
      Logger.info(
          '📋 [QUEUE-PROVIDER] ====== loadQueue 完成, 当前队列数: ${state.queueEpisodes.length} ======');
    } catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-PROVIDER] loadQueue 失败',
          error: e, stackTrace: stackTrace);
      state = state.copyWith(
        status: QueueStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> addToQueue(int episodeId) async {
    Logger.info(
        '📋 [QUEUE-PROVIDER] ====== addToQueue 开始, episodeId: $episodeId ======');

    try {
      await _addToQueueUseCase(episodeId);
      Logger.info(
          '📋 [QUEUE-PROVIDER] addToQueue 成功! episodeId: $episodeId');
    } catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-PROVIDER] addToQueue 失败!',
          error: e, stackTrace: stackTrace);
      rethrow;
    }

    await refresh();
    Logger.info(
        '📋 [QUEUE-PROVIDER] ====== addToQueue 结束, 最终队列数: ${state.queueEpisodes.length} ======');
  }

  Future<void> insertToQueueFront(int episodeId) async {
    Logger.info(
        '📋 [QUEUE-PROVIDER] ====== insertToQueueFront 开始, episodeId: $episodeId ======');

    try {
      await _insertToQueueFrontUseCase(episodeId);
      Logger.info(
          '📋 [QUEUE-PROVIDER] insertToQueueFront 成功! episodeId: $episodeId');
    } catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-PROVIDER] insertToQueueFront 失败!',
          error: e, stackTrace: stackTrace);
      rethrow;
    }

    await refresh();
    Logger.info(
        '📋 [QUEUE-PROVIDER] ====== insertToQueueFront 结束, 最终队列数: ${state.queueEpisodes.length} ======');
  }

  Future<void> removeFromQueue(int id) async {
    Logger.info(
        '📋 [QUEUE-PROVIDER] ====== removeFromQueue 开始, id: $id ======');

    try {
      await _removeFromQueueUseCase(id);
      Logger.info('📋 [QUEUE-PROVIDER] removeFromQueue 成功! id: $id');
    } catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-PROVIDER] removeFromQueue 失败!',
          error: e, stackTrace: stackTrace);
      rethrow;
    }

    await refresh();
    Logger.info(
        '📋 [QUEUE-PROVIDER] ====== removeFromQueue 结束, 最终队列数: ${state.queueEpisodes.length} ======');
  }

  Future<void> removeFromQueueByEpisodeId(int episodeId) async {
    Logger.info(
        '📋 [QUEUE-PROVIDER] ====== removeFromQueueByEpisodeId 开始, episodeId: $episodeId ======');

    try {
      await _removeFromQueueByEpisodeIdUseCase(episodeId);
      Logger.info('📋 [QUEUE-PROVIDER] removeFromQueueByEpisodeId 成功! episodeId: $episodeId');
    } catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-PROVIDER] removeFromQueueByEpisodeId 失败!',
          error: e, stackTrace: stackTrace);
      rethrow;
    }

    await refresh();
    Logger.info(
        '📋 [QUEUE-PROVIDER] ====== removeFromQueueByEpisodeId 结束, 最终队列数: ${state.queueEpisodes.length} ======');
  }

  Future<void> clearQueue() async {
    Logger.info('📋 [QUEUE-PROVIDER] ====== clearQueue 开始 ======');

    try {
      await _clearQueueUseCase();
      Logger.info('📋 [QUEUE-PROVIDER] clearQueue 成功!');
    } catch (e, stackTrace) {
      Logger.error('📋 [QUEUE-PROVIDER] clearQueue 失败!',
          error: e, stackTrace: stackTrace);
      rethrow;
    }

    await refresh();
    Logger.info(
        '📋 [QUEUE-PROVIDER] ====== clearQueue 结束, 最终队列数: ${state.queueEpisodes.length} ======');
  }

  Future<void> refresh() async {
    await loadQueue();
  }

  void removeByPodcastId(int podcastId) {
    final filtered = state.queueEpisodes.where((e) => e.podcastId != podcastId).toList();
    if (filtered.length != state.queueEpisodes.length) {
      state = state.copyWith(queueEpisodes: filtered);
    }
  }
}

final queueNotifierProvider =
    NotifierProvider<QueueNotifier, QueueState>(QueueNotifier.new);

final queueEpisodesProvider = Provider<List<Episode>>((ref) {
  final state = ref.watch(queueNotifierProvider);
  return state.queueEpisodes;
});

final queueLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(queueNotifierProvider);
  return state.status == QueueStatus.loading;
});
