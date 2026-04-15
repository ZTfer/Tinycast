import '../repositories/queue_repository.dart';

class RemoveFromQueueByEpisodeIdUseCase {
  final QueueRepository _repository;

  RemoveFromQueueByEpisodeIdUseCase(this._repository);

  Future<void> call(int episodeId) async {
    await _repository.removeFromQueueByEpisodeId(episodeId);
  }
}
