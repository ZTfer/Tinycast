import 'dart:async';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/domain/repositories/podcast_repository.dart';

class SubscribePodcastResult {
  final Podcast podcast;
  final Future<void>? itunesSearchFuture;

  SubscribePodcastResult({required this.podcast, this.itunesSearchFuture});
}

class SubscribePodcastUseCase {
  final PodcastRepository _repository;

  SubscribePodcastUseCase(this._repository);

  Future<SubscribePodcastResult> call(String rssUrl) async {
    if (rssUrl.isEmpty) {
      throw ArgumentError('RSS URL cannot be empty');
    }

    final normalizedUrl = _normalizeUrl(rssUrl);
    if (!_isValidUrl(normalizedUrl)) {
      throw ArgumentError('Invalid RSS URL format');
    }

    final podcast = await _repository.subscribe(normalizedUrl);
    final itunesFuture = _repository.getITunesSearchFuture(podcast.id);

    return SubscribePodcastResult(
      podcast: podcast,
      itunesSearchFuture: itunesFuture,
    );
  }

  String _normalizeUrl(String url) {
    final trimmedUrl = url.trim();
    final lowerCasedUrl = trimmedUrl.toLowerCase();
    if (lowerCasedUrl.startsWith('http://') ||
        lowerCasedUrl.startsWith('https://')) {
      return trimmedUrl;
    }
    return 'https://$trimmedUrl';
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
