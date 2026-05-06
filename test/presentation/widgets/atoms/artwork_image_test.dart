import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/widgets/atoms/artwork_image/artwork_image.dart';

class _TestAssetBundle extends AssetBundle {
  _TestAssetBundle();

  static const String _svgContent =
      '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">'
      '<rect width="100" height="100" fill="gray"/></svg>';

  @override
  Future<ByteData> load(String key) async {
    if (key.endsWith('.svg')) {
      final bytes = utf8.encode(_svgContent);
      return ByteData.view(Uint8List.fromList(bytes).buffer);
    }
    return ByteData(0);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key.endsWith('.svg')) {
      return _svgContent;
    }
    return '';
  }

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String) parser,
  ) async {
    final string = await loadString(key);
    return parser(string);
  }

  @override
  void evict(String key) {}
}

void main() {
  group('ArtworkImage', () {
    final testAssetBundle = _TestAssetBundle();

    Widget buildSubject({
      String? artworkPath,
      String? artworkUrl,
      Episode? episode,
      Podcast? podcast,
      double? width,
      double? height,
      BoxFit fit = BoxFit.cover,
      double borderRadius = 0,
      Widget? placeholder,
      Widget? errorWidget,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DefaultAssetBundle(
            bundle: testAssetBundle,
            child: ArtworkImage(
              artworkPath: artworkPath,
              artworkUrl: artworkUrl,
              episode: episode,
              podcast: podcast,
              width: width,
              height: height,
              fit: fit,
              borderRadius: borderRadius,
              placeholder: placeholder,
              errorWidget: errorWidget,
            ),
          ),
        ),
      );
    }

    Episode createTestEpisode({
      int id = 1,
      int podcastId = 1,
      String title = 'Test Episode',
      String? artworkUrl,
      String? artworkPath,
    }) {
      return Episode(
        id: id,
        podcastId: podcastId,
        title: title,
        description: 'Test description',
        pubDate: DateTime(2024, 1, 1),
        audioUrl: 'https://example.com/audio.mp3',
        artworkUrl: artworkUrl,
        artworkPath: artworkPath,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
    }

    Podcast createTestPodcast({
      int id = 1,
      String title = 'Test Podcast',
      String artworkUrl = 'https://example.com/artwork.jpg',
      String? artworkPath,
    }) {
      return Podcast(
        id: id,
        title: title,
        author: 'Test Author',
        description: 'Test description',
        artworkUrl: artworkUrl,
        rssUrl: 'https://example.com/rss.xml',
        artworkPath: artworkPath,
        lastUpdated: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
      );
    }

    group('constructors', () {
      testWidgets('default constructor sets artworkPath and artworkUrl',
          (tester) async {
        await tester.pumpWidget(buildSubject(
          artworkUrl: 'https://example.com/image.jpg',
          artworkPath: '/path/to/art.png',
          placeholder: SizedBox(key: Key('placeholder')),
          errorWidget: SizedBox(key: Key('error')),
        ));
        await tester.pumpAndSettle();

        final widget = tester.widget<ArtworkImage>(find.byType(ArtworkImage));
        expect(widget.artworkUrl, 'https://example.com/image.jpg');
        expect(widget.artworkPath, '/path/to/art.png');
      });

      testWidgets(
          'fromEpisode constructor extracts artworkPath and artworkUrl from episode',
          (tester) async {
        final episode = createTestEpisode(
          artworkUrl: 'https://example.com/episode-art.jpg',
          artworkPath: '/path/to/episode-art.png',
        );

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: DefaultAssetBundle(
              bundle: testAssetBundle,
              child: ArtworkImage.fromEpisode(
                episode,
                placeholder: SizedBox(key: Key('placeholder')),
                errorWidget: SizedBox(key: Key('error')),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        final widget = tester.widget<ArtworkImage>(find.byType(ArtworkImage));
        expect(widget.artworkUrl, 'https://example.com/episode-art.jpg');
        expect(widget.artworkPath, '/path/to/episode-art.png');
        expect(widget.episode, episode);
      });

      testWidgets(
          'fromPodcast constructor extracts artworkPath and artworkUrl from podcast',
          (tester) async {
        final podcast = createTestPodcast(
          artworkPath: '/path/to/podcast-art.png',
        );

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: DefaultAssetBundle(
              bundle: testAssetBundle,
              child: ArtworkImage.fromPodcast(
                podcast,
                placeholder: SizedBox(key: Key('placeholder')),
                errorWidget: SizedBox(key: Key('error')),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        final widget = tester.widget<ArtworkImage>(find.byType(ArtworkImage));
        expect(widget.artworkUrl, 'https://example.com/artwork.jpg');
        expect(widget.artworkPath, '/path/to/podcast-art.png');
        expect(widget.podcast, podcast);
      });

      testWidgets('fromEpisode with null artworkUrl sets artworkUrl to null',
          (tester) async {
        final episode = createTestEpisode();

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: DefaultAssetBundle(
              bundle: testAssetBundle,
              child: ArtworkImage.fromEpisode(
                episode,
                errorWidget: SizedBox(key: Key('error')),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        final widget = tester.widget<ArtworkImage>(find.byType(ArtworkImage));
        expect(widget.artworkUrl, isNull);
        expect(widget.artworkPath, isNull);
      });

      testWidgets(
          'fromPodcast constructor sets podcast field and extracts artworkUrl',
          (tester) async {
        final podcast = createTestPodcast(
          artworkUrl: 'https://example.com/podcast-art.jpg',
        );

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: DefaultAssetBundle(
              bundle: testAssetBundle,
              child: ArtworkImage.fromPodcast(
                podcast,
                placeholder: SizedBox(key: Key('placeholder')),
                errorWidget: SizedBox(key: Key('error')),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        final widget = tester.widget<ArtworkImage>(find.byType(ArtworkImage));
        expect(widget.podcast, podcast);
        expect(widget.artworkUrl, 'https://example.com/podcast-art.jpg');
      });
    });

    group('rendering - CachedNetworkImage', () {
      testWidgets('shows CachedNetworkImage when artworkUrl is provided',
          (tester) async {
        await tester.pumpWidget(buildSubject(
          artworkUrl: 'https://example.com/image.jpg',
          placeholder: SizedBox(key: Key('placeholder')),
          errorWidget: SizedBox(key: Key('error')),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(CachedNetworkImage), findsOneWidget);
        final cni =
            tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
        expect(cni.imageUrl, 'https://example.com/image.jpg');
      });

      testWidgets('does not show CachedNetworkImage when artworkUrl is null',
          (tester) async {
        await tester.pumpWidget(buildSubject(
          placeholder: SizedBox(key: Key('placeholder')),
          errorWidget: SizedBox(key: Key('error')),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(CachedNetworkImage), findsNothing);
      });

      testWidgets('does not show CachedNetworkImage when artworkUrl is empty',
          (tester) async {
        await tester.pumpWidget(buildSubject(
          artworkUrl: '',
          placeholder: SizedBox(key: Key('placeholder')),
          errorWidget: SizedBox(key: Key('error')),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(CachedNetworkImage), findsNothing);
      });

      testWidgets('passes width, height, and fit to CachedNetworkImage',
          (tester) async {
        await tester.pumpWidget(buildSubject(
          artworkUrl: 'https://example.com/image.jpg',
          width: 200,
          height: 150,
          fit: BoxFit.contain,
          placeholder: SizedBox(key: Key('placeholder')),
          errorWidget: SizedBox(key: Key('error')),
        ));
        await tester.pumpAndSettle();

        final cni =
            tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
        expect(cni.width, 200);
        expect(cni.height, 150);
        expect(cni.fit, BoxFit.contain);
      });

      testWidgets(
          'fromEpisode shows CachedNetworkImage when episode has artworkUrl',
          (tester) async {
        final episode = createTestEpisode(
          artworkUrl: 'https://example.com/episode-art.jpg',
        );

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: DefaultAssetBundle(
              bundle: testAssetBundle,
              child: ArtworkImage.fromEpisode(
                episode,
                placeholder: SizedBox(key: Key('placeholder')),
                errorWidget: SizedBox(key: Key('error')),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(CachedNetworkImage), findsOneWidget);
        final cni =
            tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
        expect(cni.imageUrl, 'https://example.com/episode-art.jpg');
      });

      testWidgets(
          'fromPodcast shows CachedNetworkImage when podcast has artworkUrl',
          (tester) async {
        final podcast = createTestPodcast();

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: DefaultAssetBundle(
              bundle: testAssetBundle,
              child: ArtworkImage.fromPodcast(
                podcast,
                placeholder: SizedBox(key: Key('placeholder')),
                errorWidget: SizedBox(key: Key('error')),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(CachedNetworkImage), findsOneWidget);
        final cni =
            tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
        expect(cni.imageUrl, 'https://example.com/artwork.jpg');
      });
    });

    group('rendering - SvgPicture placeholder', () {
      testWidgets(
          'shows SvgPicture as default placeholder when no custom placeholder',
          (tester) async {
        await tester.pumpWidget(buildSubject(
          artworkUrl: 'https://example.com/image.jpg',
        ));
        await tester.pumpAndSettle();

        expect(find.byType(CachedNetworkImage), findsOneWidget);
        expect(find.byType(SvgPicture), findsWidgets);
      });

      testWidgets(
          'shows SvgPicture as default errorWidget when no custom errorWidget and no artworkUrl',
          (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byType(SvgPicture), findsOneWidget);
        expect(find.byType(CachedNetworkImage), findsNothing);
      });

      testWidgets(
          'fromEpisode shows SvgPicture when episode has no artworkUrl',
          (tester) async {
        final episode = createTestEpisode();

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: DefaultAssetBundle(
              bundle: testAssetBundle,
              child: ArtworkImage.fromEpisode(episode),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(SvgPicture), findsOneWidget);
        expect(find.byType(CachedNetworkImage), findsNothing);
      });
    });

    group('rendering - custom placeholder and errorWidget', () {
      testWidgets('shows custom placeholder when provided', (tester) async {
        await tester.pumpWidget(buildSubject(
          artworkUrl: 'https://example.com/image.jpg',
          placeholder:
              Container(key: Key('custom-placeholder'), color: Colors.red),
          errorWidget: SizedBox(key: Key('error')),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(CachedNetworkImage), findsOneWidget);
        expect(find.byKey(Key('custom-placeholder')), findsOneWidget);
      });

      testWidgets('shows custom errorWidget when no artworkUrl',
          (tester) async {
        await tester.pumpWidget(buildSubject(
          errorWidget:
              Container(key: Key('custom-error'), color: Colors.blue),
        ));
        await tester.pumpAndSettle();

        expect(find.byKey(Key('custom-error')), findsOneWidget);
        expect(find.byType(CachedNetworkImage), findsNothing);
      });

      testWidgets(
          'custom errorWidget is used by CachedNetworkImage when image load fails',
          (tester) async {
        await tester.pumpWidget(buildSubject(
          artworkUrl: 'https://example.com/image.jpg',
          placeholder: SizedBox(key: Key('placeholder')),
          errorWidget: Text('Custom Error'),
        ));
        await tester.pumpAndSettle();

        final cni =
            tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
        expect(cni.errorWidget, isNotNull);
      });

      testWidgets(
          'custom placeholder is used by CachedNetworkImage while loading',
          (tester) async {
        await tester.pumpWidget(buildSubject(
          artworkUrl: 'https://example.com/image.jpg',
          placeholder: Text('Loading...'),
          errorWidget: SizedBox(key: Key('error')),
        ));
        await tester.pumpAndSettle();

        final cni =
            tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
        expect(cni.placeholder, isNotNull);
      });
    });

    group('borderRadius', () {
      testWidgets('wraps with ClipRRect when borderRadius > 0',
          (tester) async {
        await tester.pumpWidget(buildSubject(
          artworkUrl: 'https://example.com/image.jpg',
          borderRadius: 8.0,
          placeholder: SizedBox(key: Key('placeholder')),
          errorWidget: SizedBox(key: Key('error')),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ClipRRect), findsOneWidget);
        final clipRRect =
            tester.widget<ClipRRect>(find.byType(ClipRRect));
        expect(clipRRect.borderRadius, BorderRadius.circular(8.0));
      });

      testWidgets('does not wrap with ClipRRect when borderRadius is 0',
          (tester) async {
        await tester.pumpWidget(buildSubject(
          artworkUrl: 'https://example.com/image.jpg',
          borderRadius: 0,
          placeholder: SizedBox(key: Key('placeholder')),
          errorWidget: SizedBox(key: Key('error')),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ClipRRect), findsNothing);
      });

      testWidgets('uses correct borderRadius value', (tester) async {
        await tester.pumpWidget(buildSubject(
          artworkUrl: 'https://example.com/image.jpg',
          borderRadius: 16.0,
          placeholder: SizedBox(key: Key('placeholder')),
          errorWidget: SizedBox(key: Key('error')),
        ));
        await tester.pumpAndSettle();

        final clipRRect =
            tester.widget<ClipRRect>(find.byType(ClipRRect));
        expect(clipRRect.borderRadius, BorderRadius.circular(16.0));
      });

      testWidgets(
          'wraps errorWidget with ClipRRect when borderRadius > 0 and no artworkUrl',
          (tester) async {
        await tester.pumpWidget(buildSubject(
          borderRadius: 12.0,
          errorWidget: Container(key: Key('error')),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ClipRRect), findsOneWidget);
        final clipRRect =
            tester.widget<ClipRRect>(find.byType(ClipRRect));
        expect(clipRRect.borderRadius, BorderRadius.circular(12.0));
      });

      testWidgets(
          'wraps SvgPicture placeholder with ClipRRect when borderRadius > 0',
          (tester) async {
        await tester.pumpWidget(buildSubject(
          borderRadius: 10.0,
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ClipRRect), findsOneWidget);
        expect(find.byType(SvgPicture), findsOneWidget);
      });
    });

    group('buildPlaceholder', () {
      test('returns SvgPicture widget when borderRadius is 0', () {
        final placeholder = ArtworkImage.buildPlaceholder(
          width: 100,
          height: 100,
        );

        expect(placeholder, isA<SvgPicture>());
      });

      test('returns ClipRRect wrapping SvgPicture when borderRadius > 0', () {
        final placeholder = ArtworkImage.buildPlaceholder(
          width: 100,
          height: 100,
          borderRadius: 8.0,
        );

        expect(placeholder, isA<ClipRRect>());
        final clipRRect = placeholder as ClipRRect;
        expect(clipRRect.child, isA<SvgPicture>());
        expect(clipRRect.borderRadius, BorderRadius.circular(8.0));
      });

      test('does not wrap with ClipRRect when borderRadius is 0', () {
        final placeholder = ArtworkImage.buildPlaceholder(
          width: 100,
          height: 100,
          borderRadius: 0,
        );

        expect(placeholder, isA<SvgPicture>());
        expect(placeholder, isNot(isA<ClipRRect>()));
      });

      test('passes width and height to SvgPicture', () {
        final placeholder = ArtworkImage.buildPlaceholder(
          width: 200,
          height: 150,
        ) as SvgPicture;

        expect(placeholder.width, 200);
        expect(placeholder.height, 150);
      });

      test('uses default fit of BoxFit.cover', () {
        final placeholder = ArtworkImage.buildPlaceholder(
          width: 100,
          height: 100,
        ) as SvgPicture;

        expect(placeholder.fit, BoxFit.cover);
      });

      test('uses provided fit parameter', () {
        final placeholder = ArtworkImage.buildPlaceholder(
          width: 100,
          height: 100,
          fit: BoxFit.contain,
        ) as SvgPicture;

        expect(placeholder.fit, BoxFit.contain);
      });

      test('ClipRRect child has correct SvgPicture when borderRadius > 0', () {
        final placeholder = ArtworkImage.buildPlaceholder(
          width: 200,
          height: 150,
          fit: BoxFit.fill,
          borderRadius: 12.0,
        ) as ClipRRect;

        final svgPicture = placeholder.child as SvgPicture;
        expect(svgPicture.width, 200);
        expect(svgPicture.height, 150);
        expect(svgPicture.fit, BoxFit.fill);
      });
    });

    group('didUpdateWidget', () {
      testWidgets('updates CachedNetworkImage when artworkUrl changes',
          (tester) async {
        String artworkUrl = 'https://example.com/image1.jpg';
        StateSetter? capturedSetState;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: DefaultAssetBundle(
              bundle: testAssetBundle,
              child: StatefulBuilder(
                builder: (context, setState) {
                  capturedSetState = setState;
                  return ArtworkImage(
                    artworkUrl: artworkUrl,
                    placeholder: SizedBox(key: Key('placeholder')),
                    errorWidget: SizedBox(key: Key('error')),
                  );
                },
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        var cni =
            tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
        expect(cni.imageUrl, 'https://example.com/image1.jpg');

        capturedSetState!(() {
          artworkUrl = 'https://example.com/image2.jpg';
        });
        await tester.pumpAndSettle();

        cni =
            tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
        expect(cni.imageUrl, 'https://example.com/image2.jpg');
      });

      testWidgets(
          'switches from CachedNetworkImage to errorWidget when artworkUrl is removed',
          (tester) async {
        String? artworkUrl = 'https://example.com/image.jpg';
        StateSetter? capturedSetState;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: DefaultAssetBundle(
              bundle: testAssetBundle,
              child: StatefulBuilder(
                builder: (context, setState) {
                  capturedSetState = setState;
                  return ArtworkImage(
                    artworkUrl: artworkUrl,
                    placeholder: SizedBox(key: Key('placeholder')),
                    errorWidget: Container(key: Key('custom-error')),
                  );
                },
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(CachedNetworkImage), findsOneWidget);

        capturedSetState!(() {
          artworkUrl = null;
        });
        await tester.pumpAndSettle();

        expect(find.byType(CachedNetworkImage), findsNothing);
        expect(find.byKey(Key('custom-error')), findsOneWidget);
      });

      testWidgets(
          'switches from errorWidget to CachedNetworkImage when artworkUrl is added',
          (tester) async {
        String? artworkUrl;
        StateSetter? capturedSetState;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: DefaultAssetBundle(
              bundle: testAssetBundle,
              child: StatefulBuilder(
                builder: (context, setState) {
                  capturedSetState = setState;
                  return ArtworkImage(
                    artworkUrl: artworkUrl,
                    placeholder: SizedBox(key: Key('placeholder')),
                    errorWidget: Container(key: Key('custom-error')),
                  );
                },
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(CachedNetworkImage), findsNothing);
        expect(find.byKey(Key('custom-error')), findsOneWidget);

        capturedSetState!(() {
          artworkUrl = 'https://example.com/new-image.jpg';
        });
        await tester.pumpAndSettle();

        expect(find.byType(CachedNetworkImage), findsOneWidget);
        final cni =
            tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
        expect(cni.imageUrl, 'https://example.com/new-image.jpg');
      });

      testWidgets('does not reset state when other props change',
          (tester) async {
        double borderRadius = 0;
        const artworkUrl = 'https://example.com/image.jpg';
        StateSetter? capturedSetState;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: DefaultAssetBundle(
              bundle: testAssetBundle,
              child: StatefulBuilder(
                builder: (context, setState) {
                  capturedSetState = setState;
                  return ArtworkImage(
                    artworkUrl: artworkUrl,
                    borderRadius: borderRadius,
                    placeholder: SizedBox(key: Key('placeholder')),
                    errorWidget: SizedBox(key: Key('error')),
                  );
                },
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(CachedNetworkImage), findsOneWidget);
        expect(find.byType(ClipRRect), findsNothing);

        capturedSetState!(() {
          borderRadius = 8.0;
        });
        await tester.pumpAndSettle();

        expect(find.byType(CachedNetworkImage), findsOneWidget);
        expect(find.byType(ClipRRect), findsOneWidget);
      });

      testWidgets('rebuilds without crashing when artworkPath changes',
          (tester) async {
        String? artworkPath = '/old/path.png';
        const artworkUrl = 'https://example.com/image.jpg';
        StateSetter? capturedSetState;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: DefaultAssetBundle(
              bundle: testAssetBundle,
              child: StatefulBuilder(
                builder: (context, setState) {
                  capturedSetState = setState;
                  return ArtworkImage(
                    artworkPath: artworkPath,
                    artworkUrl: artworkUrl,
                    placeholder: SizedBox(key: Key('placeholder')),
                    errorWidget: SizedBox(key: Key('error')),
                  );
                },
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(CachedNetworkImage), findsOneWidget);

        capturedSetState!(() {
          artworkPath = '/new/path.png';
        });
        await tester.pumpAndSettle();

        expect(find.byType(CachedNetworkImage), findsOneWidget);
      });
    });
  });
}
