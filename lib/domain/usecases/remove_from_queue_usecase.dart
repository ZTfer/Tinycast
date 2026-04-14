import '../repositories/queue_repository.dart';

class RemoveFromQueueUseCase {
  final QueueRepository _repository;

  RemoveFromQueueUseCase(this._repository);

  Future<void> call(int id) async {
    await _repository.removeFromQueue(id);
  }
}
