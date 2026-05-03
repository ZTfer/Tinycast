import '../entities/episode.dart';
import '../repositories/queue_repository.dart';

class InsertToQueueFrontUseCase {
  final QueueRepository _repository;

  InsertToQueueFrontUseCase(this._repository);

  Future<void> call(Episode episode) async {
    await _repository.insertToQueueFront(episode);
  }
}
