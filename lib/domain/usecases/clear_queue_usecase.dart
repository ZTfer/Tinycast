import 'package:tinycast/domain/repositories/queue_repository.dart';

class ClearQueueUseCase {
  final QueueRepository _repository;

  ClearQueueUseCase(this._repository);

  Future<void> call() async {
    await _repository.clearQueue();
  }
}
