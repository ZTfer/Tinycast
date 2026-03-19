import '../repositories/podcast_repository.dart';

class UnsubscribePodcastUseCase {
  final PodcastRepository _repository;

  UnsubscribePodcastUseCase(this._repository);

  Future<void> call(int podcastId) async {
    if (podcastId <= 0) {
      throw ArgumentError('Podcast ID must be a positive integer');
    }

    try {
      await _repository.unsubscribe(podcastId);
    } catch (e) {
      throw Exception('Failed to unsubscribe from podcast: $e');
    }
  }
}
