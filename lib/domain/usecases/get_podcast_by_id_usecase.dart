import '../entities/podcast.dart';
import '../repositories/podcast_repository.dart';

class GetPodcastByIdUseCase {
  final PodcastRepository _repository;

  GetPodcastByIdUseCase(this._repository);

  Future<Podcast?> call(int id) async {
    if (id <= 0) {
      throw ArgumentError('Podcast ID must be a positive integer');
    }

    try {
      return await _repository.getPodcastById(id);
    } catch (e) {
      throw Exception('Failed to get podcast by ID: $e');
    }
  }
}
