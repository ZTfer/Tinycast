import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/domain/entities/episode.dart';

class SearchResult {
  final List<Podcast> podcasts;
  final List<Episode> episodes;

  SearchResult({
    required this.podcasts,
    required this.episodes,
  });

  bool get isEmpty => podcasts.isEmpty && episodes.isEmpty;

  bool get isNotEmpty => !isEmpty;
}
