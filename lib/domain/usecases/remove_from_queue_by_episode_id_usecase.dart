import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/repositories/queue_repository.dart';

class RemoveFromQueueByEpisodeIdUseCase {
  final QueueRepository _repository;

  RemoveFromQueueByEpisodeIdUseCase(this._repository);

  Future<void> call(Episode episode) async {
    await _repository.removeFromQueueByEpisode(episode);
  }
}
