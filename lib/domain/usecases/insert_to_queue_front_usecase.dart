import '../repositories/queue_repository.dart';

class InsertToQueueFrontUseCase {
  final QueueRepository _repository;

  InsertToQueueFrontUseCase(this._repository);

  Future<void> call(int episodeId) async {
    await _repository.insertToQueueFront(episodeId);
  }
}
