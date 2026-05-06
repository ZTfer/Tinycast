import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/domain/usecases/get_episodes_by_podcast_id_usecase.dart';
import 'package:tinycast/domain/usecases/get_subscribed_podcasts_usecase.dart';
import 'package:tinycast/presentation/features/library/library.dart';
import 'package:tinycast/presentation/features/library/library_episode_item/library_episode_item.dart';
import 'package:tinycast/presentation/features/library/library_episode_item/library_episode_item_skeleton.dart';
import 'package:tinycast/presentation/features/library/library_list_item/library_list_item.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';

import 'library_test.mocks.dart';

@GenerateMocks([GetSubscribedPodcastsUseCase, GetEpisodesByPodcastIdUseCase])
void main() {
  group('Library Widget Tests', () {
    late ProviderContainer container;
    late MockGetSubscribedPodcastsUseCase mockGetSubscribedPodcastsUseCase;
    late MockGetEpisodesByPodcastIdUseCase mockGetEpisodesUseCase;

    setUp(() {
      mockGetSubscribedPodcastsUseCase = MockGetSubscribedPodcastsUseCase();
      mockGetEpisodesUseCase = MockGetEpisodesByPodcastIdUseCase();
      container = ProviderContainer(
        overrides: [
          getSubscribedPodcastsUseCaseProvider
              .overrideWithValue(mockGetSubscribedPodcastsUseCase),
          getEpisodesByPodcastIdUseCaseProvider
              .overrideWithValue(mockGetEpisodesUseCase),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    /// 创建测试用的 Podcast 对象
    Podcast createTestPodcast({
      required int id,
      required String title,
      DateTime? lastUpdated,
    }) {
      return Podcast(
        id: id,
        title: title,
        author: 'Test Author',
        description: 'Test Description',
        artworkUrl: 'https://example.com/artwork_$id.jpg',
        rssUrl: 'https://example.com/rss_$id.xml',
        lastUpdated: lastUpdated ?? DateTime.now(),
        createdAt: DateTime.now(),
      );
    }

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

    group('LibraryListItem Widget Tests', () {
      testWidgets('应该正确显示播客信息和剧集列表', (WidgetTester tester) async {
        // Arrange
        final podcast = createTestPodcast(id: 1, title: 'Test Podcast');
        final episodes = [
          createTestEpisode(id: 1, podcastId: 1, title: 'Episode 1'),
          createTestEpisode(id: 2, podcastId: 1, title: 'Episode 2'),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LibraryListItem(
                  podcast: podcast,
                  episodes: episodes,
                  showDivider: false,
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Test Podcast'), findsOneWidget);
        expect(find.text('Episode 1'), findsOneWidget);
        expect(find.text('Episode 2'), findsOneWidget);
      });

      testWidgets('加载状态时应该显示骨架屏', (WidgetTester tester) async {
        // Arrange
        final podcast = createTestPodcast(id: 1, title: 'Test Podcast');

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LibraryListItem(
                  podcast: podcast,
                  episodes: [],
                  isLoading: true,
                  showDivider: false,
                ),
              ),
            ),
          ),
        );

        // Assert - 应该显示3个骨架屏
        expect(find.byType(LibraryEpisodeItemSkeleton), findsNWidgets(3));
        expect(find.byType(LibraryEpisodeItem), findsNothing);
      });

      testWidgets('空剧集列表时应该不显示剧集项', (WidgetTester tester) async {
        // Arrange
        final podcast = createTestPodcast(id: 1, title: 'Test Podcast');

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LibraryListItem(
                  podcast: podcast,
                  episodes: [],
                  isLoading: false,
                  showDivider: false,
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(LibraryEpisodeItem), findsNothing);
        expect(find.byType(LibraryEpisodeItemSkeleton), findsNothing);
      });

      testWidgets('应该只显示最新3集剧集', (WidgetTester tester) async {
        // Arrange
        final podcast = createTestPodcast(id: 1, title: 'Test Podcast');
        final episodes = [
          createTestEpisode(id: 1, podcastId: 1, title: 'Episode 1'),
          createTestEpisode(id: 2, podcastId: 1, title: 'Episode 2'),
          createTestEpisode(id: 3, podcastId: 1, title: 'Episode 3'),
          createTestEpisode(id: 4, podcastId: 1, title: 'Episode 4'),
          createTestEpisode(id: 5, podcastId: 1, title: 'Episode 5'),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LibraryListItem(
                  podcast: podcast,
                  episodes: episodes,
                  showDivider: false,
                ),
              ),
            ),
          ),
        );

        // Assert - 只应该显示前3集
        expect(find.text('Episode 1'), findsOneWidget);
        expect(find.text('Episode 2'), findsOneWidget);
        expect(find.text('Episode 3'), findsOneWidget);
        expect(find.text('Episode 4'), findsNothing);
        expect(find.text('Episode 5'), findsNothing);

        // 验证只显示3个剧集项
        expect(find.byType(LibraryEpisodeItem), findsNWidgets(3));
      });

      testWidgets('点击播客应该触发 onTap 回调', (WidgetTester tester) async {
        // Arrange
        final podcast = createTestPodcast(id: 1, title: 'Test Podcast');
        bool tapped = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LibraryListItem(
                  podcast: podcast,
                  episodes: [],
                  onTap: () {
                    tapped = true;
                  },
                  showDivider: false,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test Podcast'));
        await tester.pump();

        // Assert
        expect(tapped, isTrue);
      });
    });

    group('LibraryEpisodeItemSkeleton Widget Tests', () {
      testWidgets('骨架屏应该正确渲染', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LibraryEpisodeItemSkeleton(),
            ),
          ),
        );

        // Assert - 应该找到骨架屏组件
        expect(find.byType(LibraryEpisodeItemSkeleton), findsOneWidget);

        // 验证动画正在运行
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(LibraryEpisodeItemSkeleton), findsOneWidget);
      });

      testWidgets('骨架屏应该包含标题和播放按钮占位符', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LibraryEpisodeItemSkeleton(),
            ),
          ),
        );

        // Assert - 应该找到 Row 组件（包含标题和播放按钮）
        expect(find.byType(Row), findsOneWidget);

        // 验证有两个 Container（标题和播放按钮）
        final containers = tester.widgetList<Container>(find.byType(Container));
        expect(containers.length, greaterThanOrEqualTo(2));
      });
    });

    group('时间格式化测试', () {
      testWidgets('应该正确显示相对时间 - 天', (WidgetTester tester) async {
        // Arrange
        final podcast = createTestPodcast(
          id: 1,
          title: 'Test Podcast',
          lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LibraryListItem(
                  podcast: podcast,
                  episodes: [],
                  showDivider: false,
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.textContaining('d ago'), findsOneWidget);
      });

      testWidgets('应该正确显示相对时间 - 小时', (WidgetTester tester) async {
        // Arrange
        final podcast = createTestPodcast(
          id: 1,
          title: 'Test Podcast',
          lastUpdated: DateTime.now().subtract(const Duration(hours: 3)),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LibraryListItem(
                  podcast: podcast,
                  episodes: [],
                  showDivider: false,
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.textContaining('h ago'), findsOneWidget);
      });

      testWidgets('应该正确显示相对时间 - 分钟', (WidgetTester tester) async {
        // Arrange
        final podcast = createTestPodcast(
          id: 1,
          title: 'Test Podcast',
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LibraryListItem(
                  podcast: podcast,
                  episodes: [],
                  showDivider: false,
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.textContaining('m ago'), findsOneWidget);
      });

      testWidgets('应该正确显示相对时间 - 刚刚', (WidgetTester tester) async {
        // Arrange
        final podcast = createTestPodcast(
          id: 1,
          title: 'Test Podcast',
          lastUpdated: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LibraryListItem(
                  podcast: podcast,
                  episodes: [],
                  showDivider: false,
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Just now'), findsOneWidget);
      });
    });

    group('Library Widget - Provider 集成测试', () {
      testWidgets('应该正确加载和显示播客列表', (WidgetTester tester) async {
        // Arrange
        final podcasts = [
          createTestPodcast(id: 1, title: 'Podcast 1'),
        ];

        final episodes = [
          createTestEpisode(id: 1, podcastId: 1, title: 'Episode 1'),
        ];

        when(mockGetSubscribedPodcastsUseCase.call())
            .thenAnswer((_) async => podcasts);
        when(mockGetEpisodesUseCase.call(1))
            .thenAnswer((_) async => episodes);

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: Library(),
              ),
            ),
          ),
        );

        // 等待初始帧和异步操作
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Assert - 验证播客标题显示
        expect(find.text('Podcast 1'), findsOneWidget);
        expect(find.text('Episode 1'), findsOneWidget);
      });

      testWidgets('初始加载时应该显示加载指示器', (WidgetTester tester) async {
        // Arrange
        when(mockGetSubscribedPodcastsUseCase.call()).thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 1));
          return [];
        });

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: Library(),
              ),
            ),
          ),
        );

        await tester.pump();

        // Assert - 应该显示加载指示器
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('没有订阅播客时应该显示空状态页面', (WidgetTester tester) async {
        // Arrange
        when(mockGetSubscribedPodcastsUseCase.call())
            .thenAnswer((_) async => []);

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: Library(),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Assert - 应该显示空状态页面
        expect(find.text('还没有订阅任何播客'), findsOneWidget);
      });

      testWidgets('加载播客失败时应该显示错误信息', (WidgetTester tester) async {
        // Arrange
        when(mockGetSubscribedPodcastsUseCase.call())
            .thenThrow(Exception('Network error'));

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: Library(),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Assert - 应该显示错误图标和重试按钮
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('重试'), findsOneWidget);
      });

      testWidgets('剧集加载时应该显示骨架屏', (WidgetTester tester) async {
        // Arrange
        final podcast = createTestPodcast(id: 1, title: 'Podcast 1');

        when(mockGetSubscribedPodcastsUseCase.call())
            .thenAnswer((_) async => [podcast]);
        when(mockGetEpisodesUseCase.call(1)).thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 1));
          return [];
        });

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: Library(),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Assert - 应该显示骨架屏
        expect(find.byType(LibraryEpisodeItemSkeleton), findsWidgets);
      });

      testWidgets('加载剧集失败时应该不影响播客显示', (WidgetTester tester) async {
        // Arrange
        final podcast = createTestPodcast(id: 1, title: 'Podcast 1');

        when(mockGetSubscribedPodcastsUseCase.call())
            .thenAnswer((_) async => [podcast]);
        when(mockGetEpisodesUseCase.call(1))
            .thenThrow(Exception('Failed to load episodes'));

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: Library(),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Assert - 播客应该仍然显示，但没有剧集
        expect(find.text('Podcast 1'), findsOneWidget);
        expect(find.byType(LibraryListItem), findsOneWidget);
        expect(find.byType(LibraryEpisodeItem), findsNothing);
      });
    });
  });
}
