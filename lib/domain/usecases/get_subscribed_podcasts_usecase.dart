import '../entities/podcast.dart';
import '../repositories/podcast_repository.dart';

class GetSubscribedPodcastsUseCase {
  final PodcastRepository _repository;

  GetSubscribedPodcastsUseCase(this._repository);

  Future<List<Podcast>> call() async {
    try {
      return await _repository.getSubscribedPodcasts();
    } catch (e) {
      throw Exception('Failed to get subscribed podcasts: $e');
    }
  }
}
