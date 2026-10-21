import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/domain/usecases/get_episodes_by_podcast_id_usecase.dart';
import 'package:tinycast/domain/usecases/get_latest_episodes_by_podcast_id_usecase.dart';
import 'package:tinycast/domain/usecases/get_podcast_by_id_usecase.dart';
import 'package:tinycast/domain/usecases/unsubscribe_podcast_usecase.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';

import 'podcast_provider_test.mocks.dart';

Podcast createTestPodcast({int id = 1, String title = 'Test Podcast'}) {
  return Podcast(
    id: id,
    title: title,
    author: 'Test Author',
    description: 'Test Description',
    artworkUrl: 'https://example.com/artwork_$id.jpg',
    rssUrl: 'https://example.com/rss_$id.xml',
    lastUpdated: DateTime.now(),
    createdAt: DateTime.now(),
  );
}

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

// 使用 mockito 生成 Mock 类
@GenerateMocks([
  GetLatestEpisodesByPodcastIdUseCase,
  GetPodcastByIdUseCase,
  GetEpisodesByPodcastIdUseCase,
  UnsubscribePodcastUseCase,
])
void main() {
  group('PodcastState.copyWith', () {
    test('显式传入 null 应清空可选字段', () {
      final state = PodcastState(
        status: PodcastStatus.success,
        podcast: createTestPodcast(),
        episodes: [createTestEpisode(id: 1, podcastId: 1, title: 'Ep 1')],
        errorMessage: 'old error',
      );

      final cleared = state.copyWith(
        podcast: null,
        episodes: null,
        errorMessage: null,
      );

      expect(cleared.podcast, isNull);
      expect(cleared.episodes, isNull);
      expect(cleared.errorMessage, isNull);
      expect(cleared.status, PodcastStatus.success);
    });

    test('省略参数时应保留可选字段', () {
      final podcast = createTestPodcast();
      final episodes = [createTestEpisode(id: 1, podcastId: 1, title: 'Ep 1')];
      final state = PodcastState(
        status: PodcastStatus.success,
        podcast: podcast,
        episodes: episodes,
        errorMessage: 'old error',
      );

      final loading = state.copyWith(status: PodcastStatus.loading);

      expect(loading.podcast, same(podcast));
      expect(loading.episodes, same(episodes));
      expect(loading.errorMessage, 'old error');
    });
  });

  group('PodcastNotifier.unsubscribe', () {
    late ProviderContainer container;
    late MockGetPodcastByIdUseCase mockGetPodcastByIdUseCase;
    late MockGetEpisodesByPodcastIdUseCase mockGetEpisodesByPodcastIdUseCase;
    late MockUnsubscribePodcastUseCase mockUnsubscribePodcastUseCase;

    setUp(() {
      mockGetPodcastByIdUseCase = MockGetPodcastByIdUseCase();
      mockGetEpisodesByPodcastIdUseCase = MockGetEpisodesByPodcastIdUseCase();
      mockUnsubscribePodcastUseCase = MockUnsubscribePodcastUseCase();
      container = ProviderContainer(
        overrides: [
          getPodcastByIdUseCaseProvider.overrideWithValue(
            mockGetPodcastByIdUseCase,
          ),
          getEpisodesByPodcastIdUseCaseProvider.overrideWithValue(
            mockGetEpisodesByPodcastIdUseCase,
          ),
          unsubscribePodcastUseCaseProvider.overrideWithValue(
            mockUnsubscribePodcastUseCase,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    Future<void> seedPodcastAndEpisodes() async {
      when(mockGetPodcastByIdUseCase.call(1)).thenAnswer(
        (_) async => createTestPodcast(),
      );
      when(mockGetEpisodesByPodcastIdUseCase.call(1)).thenAnswer(
        (_) async => [createTestEpisode(id: 1, podcastId: 1, title: 'Ep 1')],
      );

      final notifier = container.read(podcastProvider.notifier);
      await notifier.loadPodcastById(1);
      await notifier.loadEpisodesByPodcastId(1);
    }

    test('退订成功后应清空当前播客与剧集', () async {
      when(mockUnsubscribePodcastUseCase.call(1)).thenAnswer((_) async {});
      await seedPodcastAndEpisodes();

      await container.read(podcastProvider.notifier).unsubscribe(1);

      final state = container.read(podcastProvider);
      expect(state.status, PodcastStatus.success);
      expect(state.podcast, isNull);
      expect(state.episodes, isNull);
      expect(state.errorMessage, isNull);
      verify(mockUnsubscribePodcastUseCase.call(1)).called(1);
    });

    test('退订失败时应保留数据、记录错误并向上抛出', () async {
      when(mockUnsubscribePodcastUseCase.call(1)).thenThrow(
        Exception('db error'),
      );
      await seedPodcastAndEpisodes();

      final future = container
          .read(podcastProvider.notifier)
          .unsubscribe(1);

      await expectLater(future, throwsA(isA<Exception>()));

      final state = container.read(podcastProvider);
      expect(state.status, PodcastStatus.error);
      expect(state.errorMessage, contains('db error'));
      expect(state.podcast, isNotNull);
      expect(state.episodes, isNotNull);
    });
  });

  group('latestEpisodesProvider', () {
    late ProviderContainer container;
    late MockGetLatestEpisodesByPodcastIdUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockGetLatestEpisodesByPodcastIdUseCase();
      container = ProviderContainer(
        overrides: [
          getLatestEpisodesByPodcastIdUseCaseProvider.overrideWithValue(mockUseCase),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    /// 创建测试用的 Episode 对象
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

    test('应该返回最新的3集剧集', () async {
      // Arrange
      final podcastId = 1;
      final episodes = [
        createTestEpisode(id: 1, podcastId: podcastId, title: 'Episode 1'),
        createTestEpisode(id: 2, podcastId: podcastId, title: 'Episode 2'),
        createTestEpisode(id: 3, podcastId: podcastId, title: 'Episode 3'),
        createTestEpisode(id: 4, podcastId: podcastId, title: 'Episode 4'),
        createTestEpisode(id: 5, podcastId: podcastId, title: 'Episode 5'),
      ];

      when(mockUseCase.call(podcastId, limit: 3))
          .thenAnswer((_) async => episodes.take(3).toList());

      // Act
      final result = await container.read(
        latestEpisodesProvider(podcastId).future,
      );

      // Assert
      expect(result.length, equals(3));
      expect(result[0].title, equals('Episode 1'));
      expect(result[1].title, equals('Episode 2'));
      expect(result[2].title, equals('Episode 3'));

      verify(mockUseCase.call(podcastId, limit: 3)).called(1);
    });

    test('当剧集少于3集时，应该返回所有剧集', () async {
      // Arrange
      final podcastId = 2;
      final episodes = [
        createTestEpisode(id: 1, podcastId: podcastId, title: 'Episode 1'),
        createTestEpisode(id: 2, podcastId: podcastId, title: 'Episode 2'),
      ];

      when(mockUseCase.call(podcastId, limit: 3)).thenAnswer((_) async => episodes);

      // Act
      final result = await container.read(
        latestEpisodesProvider(podcastId).future,
      );

      // Assert
      expect(result.length, equals(2));
      expect(result[0].title, equals('Episode 1'));
      expect(result[1].title, equals('Episode 2'));

      verify(mockUseCase.call(podcastId, limit: 3)).called(1);
    });

    test('当没有剧集时，应该返回空列表', () async {
      // Arrange
      final podcastId = 3;
      when(mockUseCase.call(podcastId, limit: 3)).thenAnswer((_) async => []);

      // Act
      final result = await container.read(
        latestEpisodesProvider(podcastId).future,
      );

      // Assert
      expect(result.length, equals(0));
      expect(result, isEmpty);

      verify(mockUseCase.call(podcastId, limit: 3)).called(1);
    });

    test('应该正确处理加载状态', () async {
      // Arrange
      final podcastId = 5;
      final episodes = [
        createTestEpisode(id: 1, podcastId: podcastId, title: 'Episode 1'),
      ];

      when(mockUseCase.call(podcastId, limit: 3)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return episodes;
      });

      // autoDispose provider 需要保持监听才能保留异步结果
      final subscription = container.listen(
        latestEpisodesProvider(podcastId),
        (_, _) {},
      );
      addTearDown(subscription.close);

      // Act - 初始状态应该是 loading
      final asyncValue = container.read(latestEpisodesProvider(podcastId));

      // Assert - 检查是否处于加载状态
      expect(asyncValue.isLoading, isTrue);

      // 等待异步操作完成
      await container.read(latestEpisodesProvider(podcastId).future);

      // 最终状态应该包含数据
      final finalAsyncValue = container.read(latestEpisodesProvider(podcastId));
      expect(finalAsyncValue.hasValue, isTrue);
      expect(finalAsyncValue.value?.length, equals(1));
    });

    test('应该为不同的 podcastId 返回不同的剧集', () async {
      // Arrange
      final podcastId1 = 10;
      final podcastId2 = 20;

      final episodes1 = [
        createTestEpisode(id: 1, podcastId: podcastId1, title: 'Podcast1-Ep1'),
        createTestEpisode(id: 2, podcastId: podcastId1, title: 'Podcast1-Ep2'),
      ];

      final episodes2 = [
        createTestEpisode(id: 3, podcastId: podcastId2, title: 'Podcast2-Ep1'),
        createTestEpisode(id: 4, podcastId: podcastId2, title: 'Podcast2-Ep2'),
        createTestEpisode(id: 5, podcastId: podcastId2, title: 'Podcast2-Ep3'),
      ];

      when(mockUseCase.call(podcastId1, limit: 3)).thenAnswer((_) async => episodes1);
      when(mockUseCase.call(podcastId2, limit: 3)).thenAnswer((_) async => episodes2);

      // Act
      final result1 = await container.read(
        latestEpisodesProvider(podcastId1).future,
      );
      final result2 = await container.read(
        latestEpisodesProvider(podcastId2).future,
      );

      // Assert
      expect(result1.length, equals(2));
      expect(result1[0].podcastId, equals(podcastId1));
      expect(result1[0].title, equals('Podcast1-Ep1'));

      expect(result2.length, equals(3));
      expect(result2[0].podcastId, equals(podcastId2));
      expect(result2[0].title, equals('Podcast2-Ep1'));

      verify(mockUseCase.call(podcastId1, limit: 3)).called(1);
      verify(mockUseCase.call(podcastId2, limit: 3)).called(1);
    });

    test('应该正确处理错误状态', () async {
      // Arrange
      final podcastId = 6;
      final errorMessage = 'Network error';

      when(mockUseCase.call(podcastId, limit: 3)).thenThrow(Exception(errorMessage));

      // autoDispose provider 需要保持监听才能保留异步结果
      final subscription = container.listen(
        latestEpisodesProvider(podcastId),
        (_, _) {},
      );
      addTearDown(subscription.close);

      // Act - 读取 provider，这会触发异步操作
      final asyncValue = container.read(latestEpisodesProvider(podcastId));

      // 初始状态应该是 loading
      expect(asyncValue.isLoading, isTrue);

      // 等待足够的时间让错误发生
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert - 检查错误状态
      final errorAsyncValue = container.read(latestEpisodesProvider(podcastId));
      expect(errorAsyncValue.hasError, isTrue);
      expect(errorAsyncValue.error, isA<Exception>());
    });
  });
}
