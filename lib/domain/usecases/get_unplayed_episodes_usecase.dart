import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/repositories/podcast_repository.dart';

class GetUnplayedEpisodesUseCase {
  final PodcastRepository _repository;

  GetUnplayedEpisodesUseCase(this._repository);

  Future<List<Episode>> call() async => _repository.getUnplayedEpisodes();
}
