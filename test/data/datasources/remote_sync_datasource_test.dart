import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinycast/data/datasources/remote_sync_datasource.dart';

void main() {
  late List<http.Request> requests;
  late SupabaseClient client;

  setUp(() {
    requests = [];
  });

  tearDown(() async {
    await client.dispose();
  });

  RemoteSyncDataSource createDataSource({
    required http.Client httpClient,
    String? userId = 'test-user-id',
  }) {
    client = SupabaseClient(
      'https://project.supabase.co',
      'anon-key',
      httpClient: httpClient,
    );
    return RemoteSyncDataSource(
      clientResolver: () => client,
      userIdResolver: () => userId,
    );
  }

  http.Response jsonResponse(
    http.Request request,
    Object body, {
    int statusCode = 200,
  }) {
    return http.Response(
      jsonEncode(body),
      statusCode,
      request: request,
      headers: {'content-type': 'application/json'},
    );
  }

  http.Response emptyResponse(http.Request request) {
    return http.Response('', 204, request: request);
  }

  group('upsertPodcasts', () {
    test('按 itunes_id 冲突合并并返回服务端记录', () async {
      final dataSource = createDataSource(
        httpClient: MockClient((request) async {
          requests.add(request);
          return jsonResponse(request, [
            {'id': 1, 'title': 'Test Podcast'},
          ]);
        }),
      );

      final result = await dataSource.upsertPodcasts([
        {'title': 'Test Podcast', 'itunes_id': '123'},
      ]);

      expect(result, hasLength(1));
      expect(result.single['id'], 1);
      expect(requests, hasLength(1));
      expect(requests.single.method, 'POST');
      expect(requests.single.url.path, '/rest/v1/podcasts');
      expect(
        requests.single.url.queryParameters['on_conflict'],
        'itunes_id',
      );
      expect(
        jsonDecode(requests.single.body),
        [
          {'title': 'Test Podcast', 'itunes_id': '123'},
        ],
      );
    });

    test('空列表不发起网络请求', () async {
      final dataSource = createDataSource(
        httpClient: MockClient((request) async {
          requests.add(request);
          return jsonResponse(request, []);
        }),
      );

      expect(await dataSource.upsertPodcasts([]), isEmpty);
      expect(requests, isEmpty);
    });
  });

  group('upsertEpisodes', () {
    test('超过分块大小时拆成多次请求', () async {
      final dataSource = createDataSource(
        httpClient: MockClient((request) async {
          requests.add(request);
          return jsonResponse(request, jsonDecode(request.body));
        }),
      );

      final episodes = List.generate(
        syncUpsertChunkSize + 1,
        (index) => {'guid': 'guid-$index', 'podcast_id': 1},
      );

      final result = await dataSource.upsertEpisodes(episodes);

      expect(result, hasLength(syncUpsertChunkSize + 1));
      expect(requests, hasLength(2));
      expect(jsonDecode(requests[0].body), hasLength(syncUpsertChunkSize));
      expect(jsonDecode(requests[1].body), hasLength(1));
      expect(
        requests.first.url.queryParameters['on_conflict'],
        'guid,podcast_id',
      );
    });
  });

  group('fetchPodcastsUpdatedAfter', () {
    test('按 id 分页拉取直到不足一页，并携带 since 过滤', () async {
      final dataSource = createDataSource(
        httpClient: MockClient((request) async {
          requests.add(request);
          final offset = int.parse(
            request.url.queryParameters['offset'] ?? '0',
          );
          final rows = offset == 0
              ? List.generate(syncPageSize, (i) => {'id': i})
              : [
                  {'id': syncPageSize},
                ];
          return jsonResponse(request, rows);
        }),
      );

      final since = DateTime.utc(2024, 6, 1);
      final result = await dataSource.fetchPodcastsUpdatedAfter(since);

      expect(result, hasLength(syncPageSize + 1));
      expect(requests, hasLength(2));
      expect(
        requests.first.url.queryParameters['updated_at'],
        'gt.${since.toIso8601String()}',
      );
      expect(
        requests.first.url.queryParameters['order'],
        'id.asc.nullslast',
      );
      expect(requests.first.url.queryParameters['offset'], '0');
      expect(requests.first.url.queryParameters['limit'], '$syncPageSize');
      expect(requests[1].url.queryParameters['offset'], '$syncPageSize');
    });
  });

  group('用户维度同步', () {
    test('upsert 自动注入 user_id', () async {
      final dataSource = createDataSource(
        httpClient: MockClient((request) async {
          requests.add(request);
          return jsonResponse(request, jsonDecode(request.body));
        }),
      );

      final result = await dataSource.upsertUserPodcastSubscriptions([
        {'podcast_id': 1},
      ]);

      expect(result.single['user_id'], 'test-user-id');
      expect(
        requests.single.url.queryParameters['on_conflict'],
        'user_id,podcast_id',
      );
    });

    test('fetch 只请求当前用户的数据', () async {
      final dataSource = createDataSource(
        httpClient: MockClient((request) async {
          requests.add(request);
          return jsonResponse(request, []);
        }),
      );

      await dataSource.fetchFavorites();

      expect(requests.single.url.path, '/rest/v1/favorites');
      expect(
        requests.single.url.queryParameters['user_id'],
        'eq.test-user-id',
      );
    });

    test('未认证时抛出 StateError 且不发起请求', () async {
      final dataSource = createDataSource(
        userId: null,
        httpClient: MockClient((request) async {
          requests.add(request);
          return jsonResponse(request, []);
        }),
      );

      expect(
        () => dataSource.fetchQueueItems(),
        throwsA(isA<StateError>()),
      );
      expect(
        () => dataSource.upsertFavorites([
          {'episode_id': 1},
        ]),
        throwsA(isA<StateError>()),
      );
      expect(requests, isEmpty);
    });
  });

  group('delete 操作', () {
    test('删除订阅时带上用户与播客过滤条件', () async {
      final dataSource = createDataSource(
        httpClient: MockClient((request) async {
          requests.add(request);
          return emptyResponse(request);
        }),
      );

      await dataSource.deleteUserPodcastSubscription(7);

      expect(requests.single.method, 'DELETE');
      expect(
        requests.single.url.path,
        '/rest/v1/user_podcast_subscriptions',
      );
      expect(
        requests.single.url.queryParameters['user_id'],
        'eq.test-user-id',
      );
      expect(requests.single.url.queryParameters['podcast_id'], 'eq.7');
    });

    test('清空队列时只按用户过滤', () async {
      final dataSource = createDataSource(
        httpClient: MockClient((request) async {
          requests.add(request);
          return emptyResponse(request);
        }),
      );

      await dataSource.deleteAllQueueItems();

      expect(requests.single.url.path, '/rest/v1/queue_items');
      expect(
        requests.single.url.queryParameters['user_id'],
        'eq.test-user-id',
      );
      expect(requests.single.url.queryParameters.containsKey('episode_id'),
          isFalse);
    });
  });

  test('服务端错误以 PostgrestException 抛出', () async {
    final dataSource = createDataSource(
      httpClient: MockClient((request) async {
        requests.add(request);
        return jsonResponse(
          request,
          {'message': 'boom', 'code': 'PGRST000'},
          statusCode: 400,
        );
      }),
    );

    await expectLater(
      dataSource.fetchFavorites(),
      throwsA(isA<PostgrestException>()),
    );
  });
}
