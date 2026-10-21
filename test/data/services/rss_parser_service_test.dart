import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinycast/data/services/rss_parser_service.dart';
import 'package:tinycast/domain/entities/episode.dart';

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._body);

  final String _body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      _body,
      200,
      headers: {
        Headers.contentTypeHeader: ['application/rss+xml'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

String _feedWith({required String pubDate, String lastBuildDate = ''}) {
  return '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Test Podcast</title>
    <description>Desc</description>
    <lastBuildDate>$lastBuildDate</lastBuildDate>
    <item>
      <title>Episode 1</title>
      <guid>ep-1</guid>
      <enclosure url="https://example.com/ep1.mp3" type="audio/mpeg" />
      <pubDate>$pubDate</pubDate>
    </item>
  </channel>
</rss>
''';
}

Future<Map<String, dynamic>> _parse(String xml) {
  final dio = Dio()..httpClientAdapter = _FakeHttpClientAdapter(xml);
  return RssParserService(dioInstance: dio, maxRetryCount: 0).parseRssFeed(
    'https://example.com/feed.xml',
  );
}

Episode _firstEpisode(Map<String, dynamic> result) {
  final episodes = result['episodes'] as List<Episode>;
  expect(episodes, hasLength(1));
  return episodes.first;
}

void main() {
  group('RssParserService 时间解析', () {
    test('RFC 822 带数字时区时按偏移换算为 UTC', () async {
      final episode = _firstEpisode(
        await _parse(_feedWith(pubDate: 'Mon, 06 Sep 2021 04:00:00 +0800')),
      );

      expect(episode.pubDate.toUtc(), DateTime.utc(2021, 9, 5, 20));
    });

    test('RFC 822 带 GMT 时保持 UTC', () async {
      final episode = _firstEpisode(
        await _parse(_feedWith(pubDate: 'Mon, 06 Sep 2021 04:00:00 GMT')),
      );

      expect(episode.pubDate.toUtc(), DateTime.utc(2021, 9, 6, 4));
    });

    test('RFC 822 带美国时区缩写时按对应偏移换算', () async {
      final episode = _firstEpisode(
        await _parse(_feedWith(pubDate: 'Mon, 06 Sep 2021 04:00:00 EST')),
      );

      expect(episode.pubDate.toUtc(), DateTime.utc(2021, 9, 6, 9));
    });

    test('ISO 8601 带偏移时换算为对应 UTC 时刻', () async {
      final episode = _firstEpisode(
        await _parse(
          _feedWith(pubDate: '2021-09-06T04:00:00+08:00'),
        ),
      );

      expect(episode.pubDate.toUtc(), DateTime.utc(2021, 9, 5, 20));
    });

    test('lastBuildDate 同样按 RFC 822 时区解析', () async {
      final result = await _parse(
        _feedWith(
          pubDate: 'Mon, 06 Sep 2021 04:00:00 GMT',
          lastBuildDate: 'Tue, 07 Sep 2021 12:00:00 +0800',
        ),
      );
      final podcast = result['podcast'];

      expect(podcast.lastUpdated.toUtc(), DateTime.utc(2021, 9, 7, 4));
    });
  });
}
