import 'package:tinycast/domain/repositories/podcast_repository.dart';

class UnsubscribePodcastUseCase {
  final PodcastRepository _repository;

  UnsubscribePodcastUseCase(this._repository);

  Future<void> call(int podcastId) async {
    if (podcastId <= 0) {
      throw ArgumentError('Podcast ID must be a positive integer');
    }

    await _repository.unsubscribe(podcastId);
  }
}
