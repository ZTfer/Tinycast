import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/usecases/get_unplayed_episodes_usecase.dart';
import 'package:tinycast/presentation/features/library/unplayed_episodes_provider.dart';

import 'unplayed_episodes_provider_test.mocks.dart';

@GenerateMocks([GetUnplayedEpisodesUseCase])
void main() {
  group('UnplayedEpisodesNotifier', () {
    late ProviderContainer container;
    late MockGetUnplayedEpisodesUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockGetUnplayedEpisodesUseCase();
      container = ProviderContainer(
        overrides: [
          getUnplayedEpisodesUseCaseProvider.overrideWithValue(mockUseCase),
        ],
      );
    });

    tearDown(() {
      container.dispose();
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

    group('loadUnplayedEpisodes', () {
      test('应该加载数据并更新状态为 success', () async {
        final episodes = [
          createTestEpisode(id: 1, podcastId: 1, title: 'Episode 1'),
          createTestEpisode(id: 2, podcastId: 1, title: 'Episode 2'),
        ];

        when(mockUseCase.call()).thenAnswer((_) async => episodes);

        final notifier = container.read(unplayedEpisodesNotifierProvider.notifier);

        expect(container.read(unplayedEpisodesNotifierProvider).status,
            equals(UnplayedEpisodesStatus.initial));

        await notifier.loadUnplayedEpisodes();

        final state = container.read(unplayedEpisodesNotifierProvider);
        expect(state.status, equals(UnplayedEpisodesStatus.success));
        expect(state.episodes.length, equals(2));
        expect(state.episodes[0].title, equals('Episode 1'));
        expect(state.episodes[1].title, equals('Episode 2'));
        expect(state.errorMessage, isNull);

        verify(mockUseCase.call()).called(1);
      });

      test('加载过程中状态应该变为 loading', () async {
        final episodes = [
          createTestEpisode(id: 1, podcastId: 1, title: 'Episode 1'),
        ];

        when(mockUseCase.call()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return episodes;
        });

        final notifier = container.read(unplayedEpisodesNotifierProvider.notifier);
        final future = notifier.loadUnplayedEpisodes();

        await Future.delayed(const Duration(milliseconds: 10));
        final loadingState = container.read(unplayedEpisodesNotifierProvider);
        expect(loadingState.status, equals(UnplayedEpisodesStatus.loading));

        await future;

        final successState = container.read(unplayedEpisodesNotifierProvider);
        expect(successState.status, equals(UnplayedEpisodesStatus.success));
      });

      test('当加载失败时，状态应该变为 error', () async {
        when(mockUseCase.call()).thenThrow(Exception('Network error'));

        final notifier = container.read(unplayedEpisodesNotifierProvider.notifier);
        await notifier.loadUnplayedEpisodes();

        final state = container.read(unplayedEpisodesNotifierProvider);
        expect(state.status, equals(UnplayedEpisodesStatus.error));
        expect(state.errorMessage, isNotNull);
        expect(state.errorMessage, contains('Network error'));
        expect(state.episodes, isEmpty);
      });

      test('加载空列表时应该正常处理', () async {
        when(mockUseCase.call()).thenAnswer((_) async => []);

        final notifier = container.read(unplayedEpisodesNotifierProvider.notifier);
        await notifier.loadUnplayedEpisodes();

        final state = container.read(unplayedEpisodesNotifierProvider);
        expect(state.status, equals(UnplayedEpisodesStatus.success));
        expect(state.episodes, isEmpty);
      });
    });

    group('refresh', () {
      test('refresh 应该调用 loadUnplayedEpisodes', () async {
        final episodes = [
          createTestEpisode(id: 1, podcastId: 1, title: 'Episode 1'),
        ];

        when(mockUseCase.call()).thenAnswer((_) async => episodes);

        final notifier = container.read(unplayedEpisodesNotifierProvider.notifier);
        await notifier.refresh();

        final state = container.read(unplayedEpisodesNotifierProvider);
        expect(state.status, equals(UnplayedEpisodesStatus.success));
        expect(state.episodes.length, equals(1));

        verify(mockUseCase.call()).called(1);
      });

      test('多次 refresh 应该每次都重新加载数据', () async {
        final episodes1 = [
          createTestEpisode(id: 1, podcastId: 1, title: 'Episode 1'),
        ];
        final episodes2 = [
          createTestEpisode(id: 1, podcastId: 1, title: 'Episode 1'),
          createTestEpisode(id: 2, podcastId: 1, title: 'Episode 2'),
        ];

        int callCount = 0;
        when(mockUseCase.call()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? episodes1 : episodes2;
        });

        final notifier = container.read(unplayedEpisodesNotifierProvider.notifier);

        await notifier.refresh();
        expect(container.read(unplayedEpisodesNotifierProvider).episodes.length,
            equals(1));

        await notifier.refresh();
        expect(container.read(unplayedEpisodesNotifierProvider).episodes.length,
            equals(2));

        verify(mockUseCase.call()).called(2);
      });
    });

    group('状态变化', () {
      test('初始状态应该是 initial', () {
        final state = container.read(unplayedEpisodesNotifierProvider);
        expect(state.status, equals(UnplayedEpisodesStatus.initial));
        expect(state.episodes, isEmpty);
        expect(state.errorMessage, isNull);
      });

      test('加载成功后状态应该从 loading 变为 success', () async {
        final episodes = [
          createTestEpisode(id: 1, podcastId: 1, title: 'Episode 1'),
        ];

        when(mockUseCase.call()).thenAnswer((_) async => episodes);

        final notifier = container.read(unplayedEpisodesNotifierProvider.notifier);

        final stateChanges = <UnplayedEpisodesStatus>[];
        final subscription = container.listen<UnplayedEpisodesState>(
          unplayedEpisodesNotifierProvider,
          (previous, next) {
            stateChanges.add(next.status);
          },
        );

        await notifier.loadUnplayedEpisodes();

        expect(stateChanges, contains(UnplayedEpisodesStatus.loading));
        expect(stateChanges, contains(UnplayedEpisodesStatus.success));

        subscription.close();
      });

      test('加载失败后状态应该从 loading 变为 error', () async {
        when(mockUseCase.call()).thenThrow(Exception('Error'));

        final notifier = container.read(unplayedEpisodesNotifierProvider.notifier);

        final stateChanges = <UnplayedEpisodesStatus>[];
        final subscription = container.listen<UnplayedEpisodesState>(
          unplayedEpisodesNotifierProvider,
          (previous, next) {
            stateChanges.add(next.status);
          },
        );

        await notifier.loadUnplayedEpisodes();

        expect(stateChanges, contains(UnplayedEpisodesStatus.loading));
        expect(stateChanges, contains(UnplayedEpisodesStatus.error));

        subscription.close();
      });

      test('reset 应该重置状态为 initial', () async {
        final episodes = [
          createTestEpisode(id: 1, podcastId: 1, title: 'Episode 1'),
        ];

        when(mockUseCase.call()).thenAnswer((_) async => episodes);

        final notifier = container.read(unplayedEpisodesNotifierProvider.notifier);
        await notifier.loadUnplayedEpisodes();

        expect(container.read(unplayedEpisodesNotifierProvider).status,
            equals(UnplayedEpisodesStatus.success));

        notifier.reset();

        final state = container.read(unplayedEpisodesNotifierProvider);
        expect(state.status, equals(UnplayedEpisodesStatus.initial));
        expect(state.episodes, isEmpty);
        expect(state.errorMessage, isNull);
      });
    });

    group('unplayedEpisodesProvider', () {
      test('应该返回当前状态中的 episodes 列表', () async {
        final episodes = [
          createTestEpisode(id: 1, podcastId: 1, title: 'Episode 1'),
          createTestEpisode(id: 2, podcastId: 1, title: 'Episode 2'),
        ];

        when(mockUseCase.call()).thenAnswer((_) async => episodes);

        final notifier = container.read(unplayedEpisodesNotifierProvider.notifier);
        await notifier.loadUnplayedEpisodes();

        final result = container.read(unplayedEpisodesProvider);
        expect(result.length, equals(2));
        expect(result[0].title, equals('Episode 1'));
        expect(result[1].title, equals('Episode 2'));
      });
    });

    group('unplayedEpisodesLoadingProvider', () {
      test('加载时应该返回 true', () async {
        when(mockUseCase.call()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return <Episode>[];
        });

        final notifier = container.read(unplayedEpisodesNotifierProvider.notifier);
        final future = notifier.loadUnplayedEpisodes();

        await Future.delayed(const Duration(milliseconds: 10));
        expect(container.read(unplayedEpisodesLoadingProvider), isTrue);

        await future;
      });

      test('加载完成后应该返回 false', () async {
        when(mockUseCase.call()).thenAnswer((_) async => <Episode>[]);

        final notifier = container.read(unplayedEpisodesNotifierProvider.notifier);
        await notifier.loadUnplayedEpisodes();

        expect(container.read(unplayedEpisodesLoadingProvider), isFalse);
      });
    });
  });
}
