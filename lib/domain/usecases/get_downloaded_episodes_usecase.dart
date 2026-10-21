import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/repositories/podcast_repository.dart';

class GetDownloadedEpisodesUseCase {
  final PodcastRepository _repository;

  GetDownloadedEpisodesUseCase(this._repository);

  Future<List<Episode>> call() async => _repository.getDownloadedEpisodes();
}
