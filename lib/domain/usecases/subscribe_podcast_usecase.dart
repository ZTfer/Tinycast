import '../entities/podcast.dart';
import '../repositories/podcast_repository.dart';

class SubscribePodcastUseCase {
  final PodcastRepository _repository;

  SubscribePodcastUseCase(this._repository);

  Future<Podcast> call(String rssUrl) async {
    if (rssUrl.isEmpty) {
      throw ArgumentError('RSS URL cannot be empty');
    }

    if (!_isValidUrl(rssUrl)) {
      throw ArgumentError('Invalid RSS URL format');
    }

    try {
      return await _repository.subscribe(rssUrl);
    } catch (e) {
      throw Exception('Failed to subscribe to podcast: $e');
    }
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
