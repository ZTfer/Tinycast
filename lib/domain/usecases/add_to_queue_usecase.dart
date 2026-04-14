import '../repositories/queue_repository.dart';

class AddToQueueUseCase {
  final QueueRepository _repository;

  AddToQueueUseCase(this._repository);

  Future<void> call(int episodeId) async {
    await _repository.addToQueue(episodeId);
  }
}
