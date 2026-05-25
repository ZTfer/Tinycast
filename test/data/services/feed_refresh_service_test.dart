import 'package:flutter_test/flutter_test.dart';
import 'package:tinycast/data/services/feed_refresh_service.dart';
import 'package:tinycast/domain/entities/podcast.dart';

void main() {
  group('FeedRefreshService 单元测试', () {
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
        expect(result.results, isEmpty);
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
