import '../entities/episode.dart';
import '../repositories/queue_repository.dart';

class AddToQueueUseCase {
  final QueueRepository _repository;

  AddToQueueUseCase(this._repository);

  Future<void> call(Episode episode) async {
    await _repository.addToQueue(episode);
  }
}
