import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinycast/core/services/local_account_data_service.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/models/app_settings_model.dart';
import 'package:tinycast/data/models/episode_model.dart' as episode_model;
import 'package:tinycast/data/models/favorite_model.dart';
import 'package:tinycast/data/models/play_history_model.dart';
import 'package:tinycast/data/models/podcast_model.dart' as podcast_model;
import 'package:tinycast/data/models/queue_model.dart';
import 'package:tinycast/data/models/search_history_model.dart';

import '../../helpers/isar_test_env.dart';

void main() {
  late IsarTestEnv env;
  late IsarService isarService;
  late LocalAccountDataService service;

  setUpAll(() async {
    await initializeIsarCoreForTests();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    env = await IsarTestEnv.open();
    isarService = IsarService.forTesting(env.isar);
    service = LocalAccountDataService(isarService: isarService);
  });

  tearDown(() async {
    await env.close();
  });

  Future<void> seedUserData() async {
    final now = DateTime.now();
    await env.isar.writeTxn(() async {
      await env.isar.podcasts.put(
        podcast_model.Podcast()
          ..id = 1
          ..title = '播客'
          ..author = '作者'
          ..description = '描述'
          ..artworkUrl = 'https://example.com/art.jpg'
          ..rssUrl = 'https://example.com/feed.xml'
          ..isExplicit = false
          ..lastUpdated = now
          ..episodeCount = 1
          ..isSubscribed = true,
      );
      await env.isar.episodes.put(
        episode_model.Episode()
          ..id = 1
          ..podcastId = 1
          ..title = '节目'
          ..description = '描述'
          ..pubDate = now
          ..audioUrl = 'https://example.com/ep.mp3'
          ..audioType = 'audio/mpeg'
          ..isExplicit = false
          ..isPlayed = false
          ..isDownloaded = false
          ..downloadProgress = 0
          ..playProgress = 0
          ..createdAt = now
          ..updatedAt = now,
      );
      await env.isar.favorites.put(Favorite()..episodeId = 1);
      await env.isar.queues.put(Queue()..episodeId = 1..position = 0);
      await env.isar.playHistorys.put(
        PlayHistory()
          ..episodeId = 1
          ..podcastId = 1
          ..title = '节目'
          ..lastUpdateTime = now,
      );
      await env.isar.searchHistoryModels.put(
        SearchHistoryModel()
          ..keyword = '关键词'
          ..searchedAt = now,
      );
      await env.isar.appSettingsModels.put(AppSettingsModel());
    });
  }

  Future<int> countUserCollections() async {
    return (await env.isar.podcasts.count()) +
        (await env.isar.episodes.count()) +
        (await env.isar.favorites.count()) +
        (await env.isar.queues.count()) +
        (await env.isar.playHistorys.count()) +
        (await env.isar.searchHistoryModels.count());
  }

  test('clearUserData 清空用户数据但保留应用设置', () async {
    await seedUserData();

    await service.clearUserData();

    expect(await countUserCollections(), equals(0));
    expect(await env.isar.appSettingsModels.count(), equals(1));
  });

  test('首次登录不会清空已有本地数据', () async {
    await seedUserData();

    final switched = await service.prepareForUser('user-a');

    expect(switched, isFalse);
    expect(await countUserCollections(), greaterThan(0));
    expect(await service.getLastUserId(), equals('user-a'));
  });

  test('切换账号时清空上一账号的本地数据', () async {
    await service.prepareForUser('user-a');
    await seedUserData();

    final switched = await service.prepareForUser('user-b');

    expect(switched, isTrue);
    expect(await countUserCollections(), equals(0));
    expect(await env.isar.appSettingsModels.count(), equals(1));
    expect(await service.getLastUserId(), equals('user-b'));
  });

  test('同一账号再次登录保留本地数据', () async {
    await service.prepareForUser('user-a');
    await seedUserData();

    final switched = await service.prepareForUser('user-a');

    expect(switched, isFalse);
    expect(await countUserCollections(), greaterThan(0));
  });

  test('clearForSignOut 清空数据并移除账号标记', () async {
    await service.prepareForUser('user-a');
    await seedUserData();

    await service.clearForSignOut();

    expect(await countUserCollections(), equals(0));
    expect(await service.getLastUserId(), isNull);
  });
}
