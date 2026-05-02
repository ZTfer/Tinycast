import 'dart:async';
import '../entities/podcast.dart';
import '../repositories/podcast_repository.dart';

class SubscribePodcastResult {
  final Podcast podcast;
  final Future<void>? itunesSearchFuture;

  SubscribePodcastResult({
    required this.podcast,
    this.itunesSearchFuture,
  });
}

class SubscribePodcastUseCase {
  final PodcastRepository _repository;

  SubscribePodcastUseCase(this._repository);

  Future<SubscribePodcastResult> call(String rssUrl) async {
    if (rssUrl.isEmpty) {
      throw ArgumentError('RSS URL cannot be empty');
    }

    if (!_isValidUrl(rssUrl)) {
      throw ArgumentError('Invalid RSS URL format');
    }

    try {
      final podcast = await _repository.subscribe(rssUrl);
      final itunesFuture = _repository.getITunesSearchFuture(podcast.id);

      return SubscribePodcastResult(
        podcast: podcast,
        itunesSearchFuture: itunesFuture,
      );
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
