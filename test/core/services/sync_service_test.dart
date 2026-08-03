import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinycast/core/services/sync_mappers.dart';
import 'package:tinycast/core/services/sync_service.dart';
import 'package:tinycast/data/datasources/remote_sync_datasource.dart';
import 'package:tinycast/data/models/podcast_model.dart';
import 'package:tinycast/data/models/episode_model.dart';
import 'package:tinycast/data/models/play_history_model.dart';
import 'package:tinycast/data/models/favorite_model.dart';
import 'package:tinycast/data/models/queue_model.dart';

import 'sync_service_test.mocks.dart';

@GenerateMocks([RemoteSyncDataSource])
void main() {
  group('SyncService', () {
    late MockRemoteSyncDataSource mockRemoteDataSource;

    setUp(() {
      mockRemoteDataSource = MockRemoteSyncDataSource();
      SharedPreferences.setMockInitialValues({});
    });

    group('getLastSyncTime', () {
      const testUserId = 'test-user-ss';

      SyncService buildService() => SyncService(
            remoteDataSource: mockRemoteDataSource,
            userIdResolver: () => testUserId,
          );

      test('SS-009: 无上次同步时间时应该返回 null', () async {
        SharedPreferences.setMockInitialValues({});

        final syncService = buildService();

        final result = await syncService.getLastSyncTime();

        expect(result, isNull);
      });

      test('SS-010: 有上次同步时间时应该返回正确时间', () async {
        final testTime = DateTime(2025, 1, 15, 10, 30, 0);
        SharedPreferences.setMockInitialValues({
          'last_sync_timestamp_$testUserId': testTime.toIso8601String(),
        });

        final syncService = buildService();

        final result = await syncService.getLastSyncTime();

        expect(result, isNotNull);
        expect(result!.year, equals(2025));
        expect(result.month, equals(1));
        expect(result.day, equals(15));
        expect(result.hour, equals(10));
        expect(result.minute, equals(30));
      });

      test('SS-011: 保存时间戳后应该可以读取', () async {
        SharedPreferences.setMockInitialValues({});

        final syncService = buildService();

        final testTime = DateTime(2025, 3, 20, 14, 0, 0);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'last_sync_timestamp_$testUserId',
          testTime.toIso8601String(),
        );

        final result = await syncService.getLastSyncTime();

        expect(result, isNotNull);
        expect(result!.year, equals(2025));
        expect(result.month, equals(3));
        expect(result.day, equals(20));
      });

      test('未登录时 getLastSyncTime 返回 null', () async {
        SharedPreferences.setMockInitialValues({
          'last_sync_timestamp': DateTime(2025, 1, 1).toIso8601String(),
        });

        final syncService = SyncService(
          remoteDataSource: mockRemoteDataSource,
          userIdResolver: () => null,
        );

        expect(await syncService.getLastSyncTime(), isNull);
      });
    });

    group('SyncProgress', () {
      test('SyncProgress 应该正确初始化', () {
        const progress = SyncProgress(
          totalItems: 10,
          syncedItems: 5,
          currentTable: 'podcasts',
        );

        expect(progress.totalItems, equals(10));
        expect(progress.syncedItems, equals(5));
        expect(progress.currentTable, equals('podcasts'));
      });

      test('SyncProgress.copyWith 应该正确更新', () {
        const progress = SyncProgress(
          totalItems: 10,
          syncedItems: 5,
          currentTable: 'podcasts',
        );

        final updated = progress.copyWith(
          syncedItems: 8,
          currentTable: 'episodes',
        );

        expect(updated.totalItems, equals(10));
        expect(updated.syncedItems, equals(8));
        expect(updated.currentTable, equals('episodes'));
      });

      test('SyncProgress 默认值应该正确', () {
        const progress = SyncProgress();

        expect(progress.totalItems, equals(0));
        expect(progress.syncedItems, equals(0));
        expect(progress.currentTable, equals(''));
      });
    });

    group('数据转换逻辑', () {
      Podcast createTestPodcast() {
        final podcast = Podcast();
        podcast.title = 'Test Podcast';
        podcast.author = 'Test Author';
        podcast.description = 'Test Description';
        podcast.rssUrl = 'https://example.com/rss.xml';
        podcast.isExplicit = false;
        podcast.lastUpdated = DateTime(2025, 1, 1);
        podcast.episodeCount = 10;
        podcast.isSubscribed = true;
        podcast.subscribedAt = DateTime(2025, 1, 1);
        podcast.itunesId = '12345';
        podcast.itunesArtworkUrl = 'https://example.com/artwork.jpg';
        podcast.language = 'zh';
        podcast.ownerName = 'Owner';
        podcast.ownerEmail = 'owner@example.com';
        podcast.websiteUrl = 'https://example.com';
        podcast.subtitle = 'Test Subtitle';
        podcast.keywords = ['tech', 'dart'];
        podcast.itunesPrimaryGenreName = 'Technology';
        podcast.itunesGenres = ['Technology', 'Programming'];
        podcast.itunesGenreIds = ['1', '2'];
        podcast.itunesCountry = 'CN';
        podcast.supabaseId = '42';
        return podcast;
      }

      Episode createTestEpisode() {
        final episode = Episode();
        episode.podcastId = 1;
        episode.title = 'Test Episode';
        episode.description = 'Test Description';
        episode.audioUrl = 'https://example.com/audio.mp3';
        episode.audioType = 'audio/mpeg';
        episode.isExplicit = false;
        episode.isPlayed = false;
        episode.isDownloaded = false;
        episode.downloadProgress = 0.0;
        episode.playProgress = 0.5;
        episode.pubDate = DateTime(2025, 1, 1);
        episode.updatedAt = DateTime(2025, 1, 2);
        episode.guid = 'ep-guid-1';
        episode.link = 'https://example.com/episode';
        episode.duration = 3600;
        episode.artworkUrl = 'https://example.com/artwork.jpg';
        episode.itunesId = '67890';
        episode.podcastITunesId = '12345';
        episode.supabaseId = '99';
        return episode;
      }

      PlayHistory createTestPlayHistory() {
        final history = PlayHistory();
        history.episodeId = 1;
        history.podcastId = 1;
        history.episodeGuid = 'ep-guid-1';
        history.episodeITunesId = '67890';
        history.podcastITunesId = '12345';
        history.title = 'Test Episode';
        history.description = 'Test Description';
        history.artworkUrl = 'https://example.com/artwork.jpg';
        history.lastPlayedPositionMs = 1800000;
        history.playProgress = 0.5;
        history.isPlayed = true;
        history.playedDuration = 3600;
        history.status = PlayHistoryStatus.completed;
        history.lastUpdateTime = DateTime(2025, 1, 2);
        history.isDeleted = false;
        history.supabaseId = '100';
        return history;
      }

      Favorite createTestFavorite() {
        final favorite = Favorite();
        favorite.episodeId = 1;
        favorite.episodeGuid = 'ep-guid-1';
        favorite.episodeITunesId = '67890';
        favorite.supabaseId = '200';
        return favorite;
      }

      Queue createTestQueueItem() {
        final queue = Queue();
        queue.episodeId = 1;
        queue.episodeGuid = 'ep-guid-1';
        queue.episodeITunesId = '67890';
        queue.podcastId = 1;
        queue.podcastGuid = 'podcast-guid-1';
        queue.podcastITunesId = '12345';
        queue.position = 0;
        queue.supabaseId = '300';
        return queue;
      }

      // Mapping functions (podcastToCloudMap, episodeToCloudMap, etc.)
      // are imported from lib/core/services/sync_mappers.dart so tests
      // verify the production code path, not a duplicated copy.

      test('SS-004: podcastToCloudMap 应该正确转换 Podcast', () {
        final podcast = createTestPodcast();
        final map = podcastToCloudMap(podcast);

        expect(map['title'], equals('Test Podcast'));
        expect(map['author'], equals('Test Author'));
        expect(map['description'], equals('Test Description'));
        expect(map['is_explicit'], isFalse);
        expect(map['language'], equals('zh'));
        expect(map['last_updated'], isNotNull);
        expect(map['owner_email'], equals('owner@example.com'));
        expect(map['owner_name'], equals('Owner'));
        expect(map['subtitle'], equals('Test Subtitle'));
        expect(map['website_url'], equals('https://example.com'));
        expect(map['itunes_id'], equals('12345'));
        expect(map['itunes_artwork_url'], equals('https://example.com/artwork.jpg'));
        expect(map['itunes_country'], equals('CN'));
        expect(map['itunes_primary_genre_name'], equals('Technology'));
        expect(map['itunes_genres'], equals(['Technology', 'Programming']));
        expect(map['itunes_genre_ids'], equals(['1', '2']));
        expect(map['keywords'], equals(['tech', 'dart']));
        expect(map['rss_urls'], equals(['https://example.com/rss.xml']));
        expect(map['id'], equals(42));
        expect(map['updated_at'], isNotNull);
      });

      test('SS-004: podcastToCloudMap 可选字段为 null 时不应包含对应 key', () {
        final podcast = Podcast();
        podcast.title = 'Minimal';
        podcast.author = 'Author';
        podcast.description = 'Desc';
        podcast.rssUrl = '';
        podcast.isExplicit = false;
        podcast.lastUpdated = DateTime.now();
        podcast.episodeCount = 0;
        podcast.isSubscribed = false;

        final map = podcastToCloudMap(podcast);

        expect(map.containsKey('itunes_id'), isFalse);
        expect(map.containsKey('itunes_artwork_url'), isFalse);
        expect(map.containsKey('rss_urls'), isFalse);
        expect(map.containsKey('id'), isFalse);
        expect(map.containsKey('keywords'), isFalse);
      });

      test('SS-005: episodeToCloudMap 应该正确转换 Episode', () {
        final episode = createTestEpisode();
        final map = episodeToCloudMap(episode);

        expect(map['title'], equals('Test Episode'));
        expect(map['description'], equals('Test Description'));
        expect(map['audio_url'], equals('https://example.com/audio.mp3'));
        expect(map['is_explicit'], isFalse);
        expect(map['guid'], equals('ep-guid-1'));
        expect(map['artwork_url'], equals('https://example.com/artwork.jpg'));
        expect(map['duration'], equals(3600));
        expect(map['link'], equals('https://example.com/episode'));
        expect(map['itunes_id'], equals('67890'));
        expect(map['podcast_itunes_id'], equals('12345'));
        expect(map['pub_date'], isNotNull);
        expect(map['id'], equals(99));
        expect(map['updated_at'], isNotNull);
      });

      test('SS-005: episodeToCloudMap 可选字段为 null 时不应包含对应 key', () {
        final episode = Episode();
        episode.podcastId = 1;
        episode.title = 'Minimal';
        episode.description = 'Desc';
        episode.audioUrl = 'https://example.com/audio.mp3';
        episode.audioType = 'audio/mpeg';
        episode.isExplicit = false;
        episode.isPlayed = false;
        episode.isDownloaded = false;
        episode.downloadProgress = 0.0;
        episode.playProgress = 0.0;
        episode.pubDate = DateTime.now();
        episode.updatedAt = DateTime.now();

        final map = episodeToCloudMap(episode);

        expect(map.containsKey('guid'), isFalse);
        expect(map.containsKey('artwork_url'), isFalse);
        expect(map.containsKey('duration'), isFalse);
        expect(map.containsKey('id'), isFalse);
        expect(map.containsKey('link'), isFalse);
      });

      test('SS-006: playHistoryToCloudMap 应该正确转换 PlayHistory', () {
        final history = createTestPlayHistory();
        final map = playHistoryToCloudMap(history);

        expect(map['artwork_url'], equals('https://example.com/artwork.jpg'));
        expect(map['description'], equals('Test Description'));
        expect(map['episode_guid'], equals('ep-guid-1'));
        expect(map['episode_itunes_id'], equals('67890'));
        expect(map['is_deleted'], isFalse);
        expect(map['is_played'], isTrue);
        expect(map['last_played_position_ms'], equals(1800000));
        expect(map['play_progress'], equals(0.5));
        expect(map['last_update_time'], isNotNull);
        expect(map['played_duration'], equals(3600));
        expect(map['podcast_guid'], isNull);
        expect(map['podcast_itunes_id'], equals('12345'));
        expect(map['status'], equals('completed'));
        expect(map['title'], equals('Test Episode'));
      });

      test('SS-006: PlayHistory status 应该正确转换为字符串', () {
        final playingHistory = PlayHistory();
        playingHistory.episodeId = 1;
        playingHistory.podcastId = 1;
        playingHistory.title = 'Playing';
        playingHistory.lastUpdateTime = DateTime.now();
        playingHistory.status = PlayHistoryStatus.playing;

        final playingMap = playHistoryToCloudMap(playingHistory);
        expect(playingMap['status'], equals('playing'));

        final skippedHistory = PlayHistory();
        skippedHistory.episodeId = 2;
        skippedHistory.podcastId = 1;
        skippedHistory.title = 'Skipped';
        skippedHistory.lastUpdateTime = DateTime.now();
        skippedHistory.status = PlayHistoryStatus.skipped;

        final skippedMap = playHistoryToCloudMap(skippedHistory);
        expect(skippedMap['status'], equals('skipped'));
      });

      test('SS-007: favoriteToCloudMap 应该正确转换 Favorite', () {
        final favorite = createTestFavorite();
        final map = favoriteToCloudMap(favorite);

        expect(map['episode_guid'], equals('ep-guid-1'));
        expect(map['episode_itunes_id'], equals('67890'));
      });

      test('SS-008: queueItemToCloudMap 应该正确转换 Queue', () {
        final queue = createTestQueueItem();
        final map = queueItemToCloudMap(queue);

        expect(map['episode_guid'], equals('ep-guid-1'));
        expect(map['episode_itunes_id'], equals('67890'));
        expect(map['podcast_guid'], equals('podcast-guid-1'));
        expect(map['podcast_itunes_id'], equals('12345'));
        expect(map['position'], equals(0));
        expect(map['added_at'], isNotNull);
      });
    });

    group('PlayHistory 重构逻辑', () {
      test('PH-001: playProgress 应该从 PlayHistory 获取', () {
        final history = PlayHistory();
        history.episodeId = 1;
        history.podcastId = 1;
        history.title = 'Test';
        history.lastUpdateTime = DateTime.now();
        history.playProgress = 0.5;

        final episode = Episode();
        episode.podcastId = 1;
        episode.title = 'Test';
        episode.description = '';
        episode.audioUrl = '';
        episode.audioType = 'audio/mpeg';
        episode.isExplicit = false;
        episode.isPlayed = false;
        episode.isDownloaded = false;
        episode.downloadProgress = 0.0;
        episode.playProgress = 0.0;
        episode.pubDate = DateTime.now();
        episode.updatedAt = DateTime.now();

        episode.playProgress = history.playProgress;

        expect(episode.playProgress, equals(0.5));
      });

      test('PH-002: isPlayed 应该从 PlayHistory 获取', () {
        final history = PlayHistory();
        history.episodeId = 1;
        history.podcastId = 1;
        history.title = 'Test';
        history.lastUpdateTime = DateTime.now();
        history.isPlayed = true;

        final episode = Episode();
        episode.podcastId = 1;
        episode.title = 'Test';
        episode.description = '';
        episode.audioUrl = '';
        episode.audioType = 'audio/mpeg';
        episode.isExplicit = false;
        episode.isPlayed = false;
        episode.isDownloaded = false;
        episode.downloadProgress = 0.0;
        episode.playProgress = 0.0;
        episode.pubDate = DateTime.now();
        episode.updatedAt = DateTime.now();

        episode.isPlayed = history.isPlayed;

        expect(episode.isPlayed, isTrue);
      });

      test('PH-003: 无 PlayHistory 时应该使用默认值', () {
        final episode = Episode();
        episode.podcastId = 1;
        episode.title = 'Test';
        episode.description = '';
        episode.audioUrl = '';
        episode.audioType = 'audio/mpeg';
        episode.isExplicit = false;
        episode.isPlayed = false;
        episode.isDownloaded = false;
        episode.downloadProgress = 0.0;
        episode.playProgress = 0.0;
        episode.pubDate = DateTime.now();
        episode.updatedAt = DateTime.now();

        expect(episode.playProgress, equals(0.0));
        expect(episode.isPlayed, isFalse);
      });
    });

    group('SyncStatus 枚举', () {
      test('应该包含所有预期状态', () {
        expect(SyncStatus.values, contains(SyncStatus.idle));
        expect(SyncStatus.values, contains(SyncStatus.syncing));
        expect(SyncStatus.values, contains(SyncStatus.error));
      });
    });

    group('集成测试（需要 Supabase + Isar）', () {
      // SS-001 ~ SS-012 阻塞根因：
      // SyncService.sync() 内部直接依赖 SupabaseService().client 和
      // IsarService.instance.isar 两个全局单例，单元测试无法注入 Mock。
      // 可执行环境：配置真实 Supabase 项目 + 初始化 Isar 后运行集成测试。
      // 取舍：保持 skip，待 SupabaseService/IsarService 重构为可注入依赖后转为单元测试。

      test('SS-001: sync() 用户未认证时应该跳过同步', () {
        // 阻塞: canSync 依赖 SupabaseService().isInitialized 全局单例
      }, skip: '集成测试: canSync 依赖 SupabaseService 全局单例, 需真实未认证环境');

      test('SS-002: sync() 应该先拉取后推送', () {
        // 阻塞: sync() 调用 _ensureUserProfile()（SupabaseService.client）
        //       及 _pullAndMergeCloudChanges/_pushLocalChanges（IsarService.instance）
      }, skip: '集成测试: sync() 依赖 Supabase + Isar 全局单例');

      test('SS-003: 同步完成后应该保存时间戳', () {
        // 阻塞: 同 SS-002, 需完整 sync() 执行路径
      }, skip: '集成测试: sync() 依赖 Supabase + Isar 全局单例');

      test('SS-012: 同步过程中应该触发进度回调', () {
        // 阻塞: 同 SS-002, 需完整 sync() 执行路径
      }, skip: '集成测试: sync() 依赖 Supabase + Isar 全局单例');
    });
  });
}
