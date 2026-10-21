import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/domain/repositories/podcast_repository.dart';

class GetPodcastByIdUseCase {
  final PodcastRepository _repository;

  GetPodcastByIdUseCase(this._repository);

  Future<Podcast?> call(int id) async {
    if (id <= 0) {
      throw ArgumentError('Podcast ID must be a positive integer');
    }

    return _repository.getPodcastById(id);
  }
}
