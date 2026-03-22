import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/repositories/podcast_repository.dart';
import 'package:tinycast/domain/usecases/get_unplayed_episodes_usecase.dart';

import 'get_unplayed_episodes_usecase_test.mocks.dart';

@GenerateMocks([PodcastRepository])
void main() {
  group('GetUnplayedEpisodesUseCase', () {
    late GetUnplayedEpisodesUseCase useCase;
    late MockPodcastRepository mockRepository;

    setUp(() {
      mockRepository = MockPodcastRepository();
      useCase = GetUnplayedEpisodesUseCase(mockRepository);
    });

    Episode createTestEpisode({
      required int id,
      required int podcastId,
      required String title,
    }) {
      return Episode(
        id: id,
        podcastId: podcastId,
        title: title,
        description: 'Test description for $title',
        pubDate: DateTime.now().subtract(Duration(days: id)),
        audioUrl: 'https://example.com/audio_$id.mp3',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    test('应该调用 repository.getUnplayedEpisodes()', () async {
      final episodes = [
        createTestEpisode(id: 1, podcastId: 1, title: 'Episode 1'),
        createTestEpisode(id: 2, podcastId: 1, title: 'Episode 2'),
      ];

      when(mockRepository.getUnplayedEpisodes())
          .thenAnswer((_) async => episodes);

      await useCase();

      verify(mockRepository.getUnplayedEpisodes()).called(1);
    });

    test('应该返回正确的节目列表', () async {
      final episodes = [
        createTestEpisode(id: 1, podcastId: 1, title: 'Episode 1'),
        createTestEpisode(id: 2, podcastId: 2, title: 'Episode 2'),
        createTestEpisode(id: 3, podcastId: 1, title: 'Episode 3'),
      ];

      when(mockRepository.getUnplayedEpisodes())
          .thenAnswer((_) async => episodes);

      final result = await useCase();

      expect(result.length, equals(3));
      expect(result[0].title, equals('Episode 1'));
      expect(result[1].title, equals('Episode 2'));
      expect(result[2].title, equals('Episode 3'));
    });

    test('当 repository 返回空列表时，应该返回空列表', () async {
      when(mockRepository.getUnplayedEpisodes())
          .thenAnswer((_) async => []);

      final result = await useCase();

      expect(result, isEmpty);
      expect(result.length, equals(0));
    });

    test('当 repository 抛出异常时，应该抛出包装后的异常', () async {
      when(mockRepository.getUnplayedEpisodes())
          .thenThrow(Exception('Database error'));

      expect(
        () => useCase(),
        throwsA(isA<Exception>()),
      );
    });

    test('返回的节目应该包含正确的属性', () async {
      final episodes = [
        Episode(
          id: 1,
          podcastId: 10,
          title: 'Test Episode',
          description: 'Test Description',
          pubDate: DateTime(2024, 1, 15),
          audioUrl: 'https://example.com/audio.mp3',
          audioType: 'audio/mpeg',
          duration: 3600,
          artworkUrl: 'https://example.com/artwork.jpg',
          isExplicit: false,
          isPlayed: false,
          isDownloaded: false,
          downloadProgress: 0.0,
          playProgress: 0.0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 15),
        ),
      ];

      when(mockRepository.getUnplayedEpisodes())
          .thenAnswer((_) async => episodes);

      final result = await useCase();

      expect(result.length, equals(1));
      expect(result[0].id, equals(1));
      expect(result[0].podcastId, equals(10));
      expect(result[0].title, equals('Test Episode'));
      expect(result[0].description, equals('Test Description'));
      expect(result[0].duration, equals(3600));
      expect(result[0].isPlayed, isFalse);
    });
  });
}
