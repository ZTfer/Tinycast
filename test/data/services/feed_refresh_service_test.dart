import 'package:flutter_test/flutter_test.dart';
import 'package:tinycast/data/datasources/local_podcast_datasource.dart';
import 'package:tinycast/data/datasources/remote_podcast_datasource.dart';
import 'package:tinycast/data/models/episode_model.dart' as episode_model;
import 'package:tinycast/data/models/podcast_model.dart' as model;
import 'package:tinycast/data/services/feed_refresh_service.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';

class _FakeLocalPodcastDataSource implements LocalPodcastDataSource {
  final Map<int, model.Podcast> podcasts = {};
  final List<int> failedCountUpdates = [];
  final List<DateTime> lastFetchedUpdates = [];

  @override
  Future<model.Podcast?> getPodcastById(int id) async => podcasts[id];

  @override
  Future<Set<String>> getExistingEpisodeGuids(int podcastId) async => {};

  @override
  Future<int> bulkInsertNewEpisodes(
    List<episode_model.Episode> newEpisodes,
  ) async {
    return newEpisodes.length;
  }

  @override
  Future<void> updatePodcastEpisodeCount(int id, int count) async {}

  @override
  Future<void> updateLastFetchedAt(
    int podcastId,
    DateTime lastFetchedAt,
  ) async {
    lastFetchedUpdates.add(lastFetchedAt);
    podcasts[podcastId]?.lastFetchedAt = lastFetchedAt;
  }

  @override
  Future<void> updateRefreshFailedCount(int podcastId, int count) async {
    failedCountUpdates.add(count);
    podcasts[podcastId]?.refreshFailedCount = count;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRemotePodcastDataSource implements RemotePodcastDataSource {
  int rssCalls = 0;
  Object? error;
  final Map<String, List<Episode>> episodesByUrl = {};

  @override
  Future<Map<String, dynamic>> getPodcastFromRss(String rssUrl) async {
    rssCalls++;
    final error = this.error;
    if (error != null) throw error;
    return {'episodes': episodesByUrl[rssUrl] ?? <Episode>[]};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

model.Podcast _podcastModel({
  int id = 1,
  int refreshFailedCount = 0,
  DateTime? lastFetchedAt,
}) {
  return model.Podcast()
    ..id = id
    ..title = 'Test Podcast $id'
    ..author = 'Author'
    ..description = 'Desc'
    ..artworkUrl = 'https://example.com/artwork.jpg'
    ..rssUrl = 'https://example.com/feed-$id.xml'
    ..isExplicit = false
    ..lastUpdated = DateTime(2025, 1, 1)
    ..episodeCount = 0
    ..isSubscribed = true
    ..lastFetchedAt = lastFetchedAt
    ..refreshFailedCount = refreshFailedCount;
}

Podcast _podcastEntity(int id) {
  return Podcast(
    id: id,
    title: 'Test Podcast $id',
    author: 'Author',
    description: 'Desc',
    artworkUrl: 'https://example.com/artwork.jpg',
    rssUrl: 'https://example.com/feed-$id.xml',
    lastUpdated: DateTime(2025, 1, 1),
    createdAt: DateTime(2025, 1, 1),
  );
}

void main() {
  group('FeedRefreshService 单元测试', () {
    late _FakeLocalPodcastDataSource local;
    late _FakeRemotePodcastDataSource remote;
    late FeedRefreshService service;

    setUp(() {
      local = _FakeLocalPodcastDataSource();
      remote = _FakeRemotePodcastDataSource();
      service = FeedRefreshService(
        remoteDataSource: remote,
        localDataSource: local,
      );
    });

    group('冷却与退化策略', () {
      test('刷新成功后重复刷新会被冷却跳过', () async {
        local.podcasts[1] = _podcastModel();

        final first = await service.refreshSingleFeed(1);
        final second = await service.refreshSingleFeed(1);

        expect(first.success, isTrue);
        expect(first.skipped, isFalse);
        expect(second.skipped, isTrue);
        expect(second.success, isFalse);
        expect(remote.rssCalls, equals(1));
      });

      test('刷新失败不启动冷却，可以立即重试', () async {
        local.podcasts[1] = _podcastModel();
        remote.error = Exception('network down');

        final first = await service.refreshSingleFeed(1);
        final second = await service.refreshSingleFeed(1);

        expect(first.success, isFalse);
        expect(first.error, contains('network down'));
        expect(first.skipped, isFalse);
        expect(second.skipped, isFalse);
        expect(remote.rssCalls, equals(2));
        expect(local.failedCountUpdates, containsAllInOrder([1, 2]));
      });

      test('force 参数可以绕过冷却', () async {
        local.podcasts[1] = _podcastModel();

        await service.refreshSingleFeed(1);
        final forced = await service.refreshSingleFeed(1, force: true);

        expect(forced.success, isTrue);
        expect(remote.rssCalls, equals(2));
      });

      test('退化模式在延长间隔内跳过刷新', () async {
        local.podcasts[1] = _podcastModel(
          refreshFailedCount: 3,
          lastFetchedAt: DateTime.now(),
        );

        final result = await service.refreshSingleFeed(1);

        expect(result.skipped, isTrue);
        expect(result.success, isFalse);
        expect(remote.rssCalls, equals(0));
      });

      test('批量刷新分别统计成功与跳过', () async {
        local.podcasts[1] = _podcastModel();
        local.podcasts[2] = _podcastModel(id: 2);

        await service.refreshSingleFeed(1);
        final batch = await service.refreshAllFeeds([
          _podcastEntity(1),
          _podcastEntity(2),
        ]);

        expect(batch.successCount, equals(1));
        expect(batch.skippedCount, equals(1));
        expect(batch.failureCount, equals(0));
        expect(batch.results.length, equals(2));
      });
    });

    group('FeedRefreshResult', () {
      test('成功结果应该正确格式化', () {
        final result = FeedRefreshResult(
          podcastId: 1,
          newEpisodesCount: 5,
          success: true,
        );

        expect(
          result.toString(),
          contains('FeedRefreshResult'),
        );
        expect(result.podcastId, equals(1));
        expect(result.newEpisodesCount, equals(5));
        expect(result.success, isTrue);
        expect(result.error, isNull);
      });

      test('失败结果应该包含错误信息', () {
        final result = FeedRefreshResult(
          podcastId: 2,
          success: false,
          error: '网络超时',
        );

        expect(result.success, isFalse);
        expect(result.error, equals('网络超时'));
        expect(result.newEpisodesCount, equals(0));
      });

      test('跳过结果应该与失败区分', () {
        final result = FeedRefreshResult(podcastId: 3, skipped: true);

        expect(result.skipped, isTrue);
        expect(result.success, isFalse);
        expect(result.error, isNull);
        expect(result.toString(), contains('skipped'));
      });
    });

    group('BatchRefreshResult', () {
      test('应该正确统计批量结果', () {
        final result = BatchRefreshResult(
          totalNewEpisodes: 10,
          successCount: 3,
          failureCount: 1,
          results: [
            FeedRefreshResult(podcastId: 1, newEpisodesCount: 5, success: true),
            FeedRefreshResult(podcastId: 2, newEpisodesCount: 3, success: true),
            FeedRefreshResult(podcastId: 3, newEpisodesCount: 2, success: true),
            FeedRefreshResult(podcastId: 4, success: false, error: '失败'),
          ],
        );

        expect(result.totalNewEpisodes, equals(10));
        expect(result.successCount, equals(3));
        expect(result.failureCount, equals(1));
        expect(result.results.length, equals(4));
      });

      test('空结果应该正确处理', () {
        final result = BatchRefreshResult(results: []);

        expect(result.totalNewEpisodes, equals(0));
        expect(result.successCount, equals(0));
        expect(result.failureCount, equals(0));
        expect(result.skippedCount, equals(0));
        expect(result.results, isEmpty);
      });

      test('跳过数量不应计入成功或失败', () {
        final result = BatchRefreshResult(
          successCount: 1,
          skippedCount: 2,
          failureCount: 1,
          results: [],
        );

        expect(result.toString(), contains('skipped: 2'));
        expect(result.successCount + result.skippedCount + result.failureCount, equals(4));
      });
    });

    group('Podcast 实体字段验证', () {
      test('Podcast 应该包含 lastFetchedAt 字段', () {
        final podcast = Podcast(
          id: 1,
          title: 'Test',
          author: 'Author',
          description: 'Desc',
          rssUrl: 'https://example.com/feed.xml',
          artworkUrl: 'https://example.com/artwork.jpg',
          lastFetchedAt: DateTime.now(),
          refreshFailedCount: 2,
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(podcast.lastFetchedAt, isNotNull);
        expect(podcast.refreshFailedCount, equals(2));
      });

      test('Podcast 的 lastFetchedAt 应该可以为 null', () {
        final podcast = Podcast(
          id: 1,
          title: 'Test',
          author: 'Author',
          description: 'Desc',
          rssUrl: 'https://example.com/feed.xml',
          artworkUrl: 'https://example.com/artwork.jpg',
          lastFetchedAt: null,
          refreshFailedCount: 0,
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(podcast.lastFetchedAt, isNull);
        expect(podcast.refreshFailedCount, equals(0));
      });
    });
  });
}
