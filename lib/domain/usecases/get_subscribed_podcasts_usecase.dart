import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/domain/repositories/podcast_repository.dart';

class GetSubscribedPodcastsUseCase {
  final PodcastRepository _repository;

  GetSubscribedPodcastsUseCase(this._repository);

  Future<List<Podcast>> call() async => _repository.getSubscribedPodcasts();
}
