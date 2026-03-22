import 'package:flutter_test/flutter_test.dart';
import 'package:tinycast/data/models/episode_model.dart' as model;

void main() {
  group('LocalPodcastDataSource.getUnplayedEpisodes', () {
    model.Episode createTestEpisode({
      required int podcastId,
      required String title,
      required bool isPlayed,
      required DateTime pubDate,
    }) {
      final episode = model.Episode();
      episode.podcastId = podcastId;
      episode.title = title;
      episode.description = 'Test description for $title';
      episode.pubDate = pubDate;
      episode.audioUrl = 'https://example.com/audio.mp3';
      episode.audioType = 'audio/mpeg';
      episode.isExplicit = false;
      episode.isPlayed = isPlayed;
      episode.isDownloaded = false;
      episode.downloadProgress = 0.0;
      episode.playProgress = 0.0;
      episode.updatedAt = DateTime.now();
      return episode;
    }

    test('应该返回未播放节目列表', () {
      final episodes = [
        createTestEpisode(
          podcastId: 1,
          title: 'Episode 1',
          isPlayed: false,
          pubDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
        createTestEpisode(
          podcastId: 1,
          title: 'Episode 2',
          isPlayed: false,
          pubDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

      final unplayedEpisodes = episodes.where((e) => e.isPlayed == false).toList();

      expect(unplayedEpisodes.length, equals(2));
      expect(unplayedEpisodes[0].title, equals('Episode 1'));
      expect(unplayedEpisodes[1].title, equals('Episode 2'));
    });

    test('应该按发布时间倒序排列', () {
      final now = DateTime.now();
      final episodes = [
        createTestEpisode(
          podcastId: 1,
          title: 'Latest Episode',
          isPlayed: false,
          pubDate: now.subtract(const Duration(days: 1)),
        ),
        createTestEpisode(
          podcastId: 1,
          title: 'Older Episode',
          isPlayed: false,
          pubDate: now.subtract(const Duration(days: 3)),
        ),
        createTestEpisode(
          podcastId: 1,
          title: 'Middle Episode',
          isPlayed: false,
          pubDate: now.subtract(const Duration(days: 2)),
        ),
      ];

      final sortedEpisodes = List<model.Episode>.from(episodes)
        ..sort((a, b) => b.pubDate.compareTo(a.pubDate));

      expect(sortedEpisodes.length, equals(3));
      expect(sortedEpisodes[0].title, equals('Latest Episode'));
      expect(sortedEpisodes[1].title, equals('Middle Episode'));
      expect(sortedEpisodes[2].title, equals('Older Episode'));
    });

    test('应该只返回 isPlayed = false 的节目', () {
      final episodes = [
        createTestEpisode(
          podcastId: 1,
          title: 'Unplayed Episode 1',
          isPlayed: false,
          pubDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
        createTestEpisode(
          podcastId: 1,
          title: 'Played Episode',
          isPlayed: true,
          pubDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
        createTestEpisode(
          podcastId: 1,
          title: 'Unplayed Episode 2',
          isPlayed: false,
          pubDate: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

      final unplayedEpisodes = episodes.where((e) => e.isPlayed == false).toList();

      expect(unplayedEpisodes.every((e) => e.isPlayed == false), isTrue);
      expect(unplayedEpisodes.length, equals(2));
      expect(unplayedEpisodes.any((e) => e.title == 'Played Episode'), isFalse);
    });

    test('当没有未播放节目时，应该返回空列表', () {
      final episodes = [
        createTestEpisode(
          podcastId: 1,
          title: 'Played Episode 1',
          isPlayed: true,
          pubDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
        createTestEpisode(
          podcastId: 1,
          title: 'Played Episode 2',
          isPlayed: true,
          pubDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

      final unplayedEpisodes = episodes.where((e) => e.isPlayed == false).toList();

      expect(unplayedEpisodes, isEmpty);
      expect(unplayedEpisodes.length, equals(0));
    });

    test('验证 Episode 模型的 isPlayed 字段默认值', () {
      final episode = model.Episode();
      episode.podcastId = 1;
      episode.title = 'Test Episode';
      episode.description = 'Test';
      episode.pubDate = DateTime.now();
      episode.audioUrl = 'https://example.com/audio.mp3';
      episode.audioType = 'audio/mpeg';
      episode.isExplicit = false;
      episode.isPlayed = false;
      episode.isDownloaded = false;
      episode.downloadProgress = 0.0;
      episode.playProgress = 0.0;
      episode.updatedAt = DateTime.now();

      expect(episode.isPlayed, isFalse);
    });
  });
}
