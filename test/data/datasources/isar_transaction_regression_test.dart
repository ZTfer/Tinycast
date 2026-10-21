import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/datasources/local_podcast_datasource.dart';
import 'package:tinycast/data/mappers/podcast_mapper.dart';
import 'package:tinycast/data/models/episode_model.dart' as episode_model;
import 'package:tinycast/data/models/play_history_model.dart';
import 'package:tinycast/data/models/podcast_model.dart' as podcast_model;
import 'package:tinycast/data/repositories/play_history_repository_impl.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';

import '../../helpers/isar_test_env.dart';

/// 回归测试：Isar 的同步查询 API 不能在异步 writeTxn 内使用，
/// 否则会抛 "Isar does not support nesting transactions"。
void main() {
  late IsarTestEnv env;
  late IsarService isarService;

  setUpAll(() async {
    await initializeIsarCoreForTests();
  });

  setUp(() async {
    env = await IsarTestEnv.open();
    isarService = IsarService.forTesting(env.isar);
  });

  tearDown(() async {
    await env.close();
  });

  Podcast buildPodcast({int id = 1, String? itunesId = 'itunes-123'}) {
    final now = DateTime.now();
    return Podcast(
      id: id,
      title: '测试播客',
      author: '作者',
      description: '描述',
      artworkUrl: 'https://example.com/art.jpg',
      rssUrl: 'https://example.com/feed.xml',
      lastUpdated: now,
      createdAt: now,
      itunesId: itunesId,
    );
  }

  Episode buildEpisode({required int podcastId}) {
    final now = DateTime.now();
    return Episode(
      id: 0,
      podcastId: podcastId,
      title: '新节目',
      description: '节目描述',
      pubDate: now,
      audioUrl: 'https://example.com/episode.mp3',
      createdAt: now,
      updatedAt: now,
    );
  }

  test('saveEpisodes 在事务内查询播客时不应抛嵌套事务错误', () async {
    await env.isar.writeTxn(() async {
      await env.isar.podcasts.put(PodcastMapper.toModel(buildPodcast()));
    });

    final datasource = LocalPodcastDataSource(isarService: isarService);

    await expectLater(
      datasource.saveEpisodes([buildEpisode(podcastId: 1)]),
      completes,
    );

    final saved = await env.isar.episodes
        .filter()
        .podcastIdEqualTo(1)
        .findFirst();
    expect(saved, isNotNull);
    expect(saved!.podcastITunesId, equals('itunes-123'));
  });

  test('removeByPodcastId 在事务内查询历史时不应抛嵌套事务错误', () async {
    await env.isar.writeTxn(() async {
      await env.isar.playHistorys.putAll([
        PlayHistory()
          ..episodeId = 11
          ..podcastId = 1
          ..title = 'a'
          ..lastUpdateTime = DateTime.now(),
        PlayHistory()
          ..episodeId = 12
          ..podcastId = 1
          ..title = 'b'
          ..lastUpdateTime = DateTime.now(),
        PlayHistory()
          ..episodeId = 13
          ..podcastId = 2
          ..title = 'c'
          ..lastUpdateTime = DateTime.now(),
      ]);
    });

    final repository = PlayHistoryRepositoryImpl(isarService: isarService);

    await expectLater(repository.removeByPodcastId(1), completes);

    expect(
      await env.isar.playHistorys.filter().podcastIdEqualTo(1).count(),
      equals(0),
    );
    expect(
      await env.isar.playHistorys.filter().podcastIdEqualTo(2).count(),
      equals(1),
    );
  });
}
