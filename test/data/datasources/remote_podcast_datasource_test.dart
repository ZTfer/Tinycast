import 'package:flutter_test/flutter_test.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/datasources/local_podcast_datasource.dart';
import 'package:tinycast/data/datasources/remote_podcast_datasource.dart';
import 'package:tinycast/data/models/podcast_model.dart' as model;
import 'package:tinycast/data/services/itunes_search_service.dart';
import 'package:tinycast/data/services/rss_parser_service.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';

import '../../helpers/isar_test_env.dart';

const _rssUrl = 'https://example.com/feed.xml';

class _FakeRssParserService extends RssParserService {
  _FakeRssParserService(this.podcast);

  final Podcast podcast;

  @override
  Future<Map<String, dynamic>> parseRssFeed(String rssUrl) async {
    return {
      'podcast': podcast,
      'episodes': <Episode>[],
    };
  }
}

class _FakeITunesSearchService extends ITunesSearchService {
  _FakeITunesSearchService({
    this.results = const [],
    this.feedUrlResult,
  }) : super(maxRetryCount: 0);

  final List<ITunesSearchResult> results;
  final ITunesSearchResult? feedUrlResult;

  @override
  Future<List<ITunesSearchResult>> searchPodcastOnITunes({
    required String term,
    int limit = 5,
  }) async {
    return results;
  }

  @override
  Future<ITunesSearchResult?> lookupByFeedUrl(String feedUrl) async {
    return feedUrlResult;
  }
}

Podcast _podcastEntity() {
  final now = DateTime.now();
  return Podcast(
    id: 1,
    title: 'My Podcast',
    author: 'Author',
    description: 'Desc',
    artworkUrl: 'https://example.com/art.jpg',
    rssUrl: _rssUrl,
    lastUpdated: now,
    createdAt: now,
  );
}

Future<model.Podcast> _seedPodcast(IsarTestEnv env) async {
  final podcast = model.Podcast()
    ..title = 'My Podcast'
    ..author = 'Author'
    ..description = 'Desc'
    ..artworkUrl = 'https://example.com/art.jpg'
    ..rssUrl = _rssUrl
    ..isExplicit = false
    ..lastUpdated = DateTime.now()
    ..episodeCount = 0
    ..isSubscribed = true;
  podcast.id = await env.isar.writeTxn(() => env.isar.podcasts.put(podcast));
  return podcast;
}

void main() {
  late IsarTestEnv env;
  late LocalPodcastDataSource localDataSource;

  setUpAll(() async {
    await initializeIsarCoreForTests();
  });

  setUp(() async {
    env = await IsarTestEnv.open();
    localDataSource = LocalPodcastDataSource(
      isarService: IsarService.forTesting(env.isar),
    );
  });

  tearDown(() async {
    await env.close();
  });

  Future<void> runITunesSearch(ITunesSearchService searchService) async {
    final dataSource = RemotePodcastDataSource(
      rssParserService: _FakeRssParserService(_podcastEntity()),
      itunesSearchService: searchService,
      localDataSource: localDataSource,
    );

    final result = await dataSource.getPodcastFromRss(_rssUrl);
    await (result[RemotePodcastDataSource.itunesSearchFutureKey]
        as Future<void>?);
  }

  test('关键词结果无精确匹配时不写入无关的 iTunes ID', () async {
    final podcast = await _seedPodcast(env);
    await runITunesSearch(
      _FakeITunesSearchService(
        results: [
          ITunesSearchResult(
            collectionId: '999',
            collectionName: 'Unrelated Show',
            feedUrl: 'https://other.example.com/feed.xml',
          ),
        ],
      ),
    );

    final stored = await env.isar.podcasts.get(podcast.id);
    expect(stored?.itunesId, isNull);
  });

  test('关键词结果 feedUrl 精确匹配时写入 iTunes ID', () async {    final podcast = await _seedPodcast(env);
    await runITunesSearch(
      _FakeITunesSearchService(
        results: [
          ITunesSearchResult(
            collectionId: '123',
            collectionName: 'My Podcast',
            feedUrl: _rssUrl,
            artworkUrl600: 'https://example.com/itunes-art.jpg',
          ),
        ],
      ),
    );

    final stored = await env.isar.podcasts.get(podcast.id);
    expect(stored?.itunesId, '123');
    expect(stored?.itunesArtworkUrl, 'https://example.com/itunes-art.jpg');
  });

  test('feedUrl 精确查询命中时写入 iTunes ID', () async {
    final podcast = await _seedPodcast(env);
    await runITunesSearch(
      _FakeITunesSearchService(
        feedUrlResult: ITunesSearchResult(
          collectionId: '456',
          collectionName: 'My Podcast',
          feedUrl: _rssUrl,
        ),
      ),
    );

    final stored = await env.isar.podcasts.get(podcast.id);
    expect(stored?.itunesId, '456');
  });
}
