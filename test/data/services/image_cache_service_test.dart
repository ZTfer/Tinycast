import 'package:flutter_test/flutter_test.dart';
import 'package:tinycast/data/models/episode_model.dart';
import 'package:tinycast/data/models/podcast_model.dart';
import 'package:tinycast/data/services/image_cache_service.dart';

import '../../helpers/isar_test_env.dart';

void main() {
  late IsarTestEnv env;

  setUpAll(initializeIsarCoreForTests);
  setUp(() async {
    env = await IsarTestEnv.open();
  });
  tearDown(() async {
    await env.close();
  });

  Future<Episode> seedEpisode() async {
    final now = DateTime.now();
    final episode = Episode()
      ..podcastId = 1
      ..title = '最新标题'
      ..description = '最新描述'
      ..pubDate = now
      ..audioUrl = 'https://example.test/audio.mp3'
      ..audioType = 'audio/mpeg'
      ..isExplicit = false
      ..isPlayed = true
      ..isDownloaded = true
      ..downloadProgress = 1.0
      ..playProgress = 0.5
      ..createdAt = now
      ..updatedAt = now;
    episode.id = await env.isar.writeTxn(
      () => env.isar.episodes.put(episode),
    );
    return episode;
  }

  Future<Podcast> seedPodcast() async {
    final now = DateTime.now();
    final podcast = Podcast()
      ..title = '最新播客标题'
      ..author = 'Author'
      ..description = '最新播客描述'
      ..artworkUrl = 'https://example.test/art.jpg'
      ..rssUrl = 'https://example.test/feed.xml'
      ..isExplicit = false
      ..episodeCount = 10
      ..isSubscribed = true
      ..subscribedAt = now
      ..lastUpdated = now;
    podcast.id = await env.isar.writeTxn(
      () => env.isar.podcasts.put(podcast),
    );
    return podcast;
  }

  group('封面图路径持久化', () {
    test('只写入 artworkPath，保留数据库中的其他字段', () async {
      final episode = await seedEpisode();

      await ImageCacheService.persistEpisodeArtworkPath(
        env.isar,
        episode.id,
        'images/new-artwork.jpg',
      );

      final reloaded = (await env.isar.episodes.get(episode.id))!;
      expect(reloaded.artworkPath, 'images/new-artwork.jpg');
      expect(reloaded.title, '最新标题');
      expect(reloaded.description, '最新描述');
      expect(reloaded.isPlayed, isTrue);
      expect(reloaded.isDownloaded, isTrue);
      expect(reloaded.playProgress, 0.5);
    });

    test('episode 已被删除时不写入、不抛异常', () async {
      await expectLater(
        ImageCacheService.persistEpisodeArtworkPath(
          env.isar,
          9999,
          'images/orphan.jpg',
        ),
        completes,
      );
      expect(await env.isar.episodes.get(9999), isNull);
    });

    test('podcast 只写入 artworkPath，保留数据库中的其他字段', () async {
      final podcast = await seedPodcast();

      await ImageCacheService.persistPodcastArtworkPath(
        env.isar,
        podcast.id,
        'images/podcast-new.jpg',
      );

      final reloaded = (await env.isar.podcasts.get(podcast.id))!;
      expect(reloaded.artworkPath, 'images/podcast-new.jpg');
      expect(reloaded.title, '最新播客标题');
      expect(reloaded.description, '最新播客描述');
      expect(reloaded.isSubscribed, isTrue);
      expect(reloaded.episodeCount, 10);
    });
  });
}
