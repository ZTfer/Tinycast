import 'package:flutter_test/flutter_test.dart';

class FakeRemoteSyncDataSource {
  String? userId;

  final List<Map<String, dynamic>> _podcasts = [];
  final List<Map<String, dynamic>> _episodes = [];
  final List<Map<String, dynamic>> _subscriptions = [];
  final List<Map<String, dynamic>> _playbackHistory = [];
  final List<Map<String, dynamic>> _favorites = [];
  final List<Map<String, dynamic>> _queueItems = [];

  int _nextId = 1;

  void _ensureUserId() {
    if (userId == null) {
      throw StateError('User is not authenticated');
    }
  }

  Future<List<Map<String, dynamic>>> upsertPodcasts(
    List<Map<String, dynamic>> podcasts,
  ) async {
    if (podcasts.isEmpty) return [];

    final result = <Map<String, dynamic>>[];
    for (final podcast in podcasts) {
      final itunesId = podcast['itunes_id'];
      final existingIndex = _podcasts
          .indexWhere((p) => p['itunes_id'] == itunesId && itunesId != null);

      if (existingIndex >= 0) {
        _podcasts[existingIndex] = {..._podcasts[existingIndex], ...podcast};
        result.add(Map<String, dynamic>.from(_podcasts[existingIndex]));
      } else {
        final newPodcast = {'id': _nextId++, ...podcast};
        _podcasts.add(newPodcast);
        result.add(Map<String, dynamic>.from(newPodcast));
      }
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchPodcastsUpdatedAfter(
    DateTime? since,
  ) async {
    if (since == null) {
      return _podcasts.map(Map<String, dynamic>.from).toList();
    }
    return _podcasts
        .where((p) {
          final updatedAt = DateTime.tryParse(p['updated_at']?.toString() ?? '');
          return updatedAt != null && updatedAt.isAfter(since);
        })
        .map(Map<String, dynamic>.from)
        .toList();
  }

  Future<List<Map<String, dynamic>>> upsertEpisodes(
    List<Map<String, dynamic>> episodes,
  ) async {
    if (episodes.isEmpty) return [];

    final result = <Map<String, dynamic>>[];
    for (final episode in episodes) {
      final guid = episode['guid'];
      final podcastId = episode['podcast_id'];
      final existingIndex = _episodes.indexWhere(
        (e) =>
            e['guid'] == guid &&
            e['podcast_id'] == podcastId &&
            guid != null,
      );

      if (existingIndex >= 0) {
        _episodes[existingIndex] = {..._episodes[existingIndex], ...episode};
        result.add(Map<String, dynamic>.from(_episodes[existingIndex]));
      } else {
        final newEpisode = {'id': _nextId++, ...episode};
        _episodes.add(newEpisode);
        result.add(Map<String, dynamic>.from(newEpisode));
      }
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> upsertUserPodcastSubscriptions(
    List<Map<String, dynamic>> subscriptions,
  ) async {
    _ensureUserId();
    if (subscriptions.isEmpty) return [];

    final records = subscriptions.map((s) => {...s, 'user_id': userId}).toList();

    final result = <Map<String, dynamic>>[];
    for (final record in records) {
      final podcastId = record['podcast_id'];
      final existingIndex = _subscriptions.indexWhere(
        (s) => s['user_id'] == userId && s['podcast_id'] == podcastId,
      );

      if (existingIndex >= 0) {
        _subscriptions[existingIndex] = {..._subscriptions[existingIndex], ...record};
        result.add(Map<String, dynamic>.from(_subscriptions[existingIndex]));
      } else {
        final newSub = {'id': _nextId++, ...record};
        _subscriptions.add(newSub);
        result.add(Map<String, dynamic>.from(newSub));
      }
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchUserPodcastSubscriptions() async {
    _ensureUserId();
    return _subscriptions
        .where((s) => s['user_id'] == userId)
        .map(Map<String, dynamic>.from)
        .toList();
  }

  Future<void> deleteUserPodcastSubscription(int podcastId) async {
    _ensureUserId();
    _subscriptions.removeWhere(
      (s) => s['user_id'] == userId && s['podcast_id'] == podcastId,
    );
  }

  Future<List<Map<String, dynamic>>> upsertPlaybackHistory(
    List<Map<String, dynamic>> records,
  ) async {
    _ensureUserId();
    if (records.isEmpty) return [];

    final items = records.map((r) => {...r, 'user_id': userId}).toList();

    final result = <Map<String, dynamic>>[];
    for (final item in items) {
      final episodeId = item['episode_id'];
      final existingIndex = _playbackHistory.indexWhere(
        (h) => h['user_id'] == userId && h['episode_id'] == episodeId,
      );

      if (existingIndex >= 0) {
        _playbackHistory[existingIndex] = {..._playbackHistory[existingIndex], ...item};
        result.add(Map<String, dynamic>.from(_playbackHistory[existingIndex]));
      } else {
        final newHistory = {'id': _nextId++, ...item};
        _playbackHistory.add(newHistory);
        result.add(Map<String, dynamic>.from(newHistory));
      }
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchPlaybackHistoryUpdatedAfter(
    DateTime? since,
  ) async {
    _ensureUserId();
    var results = _playbackHistory
        .where((h) => h['user_id'] == userId)
        .map(Map<String, dynamic>.from)
        .toList();

    if (since != null) {
      results = results.where((h) {
        final updateTime = DateTime.tryParse(h['last_update_time']?.toString() ?? '');
        return updateTime != null && updateTime.isAfter(since);
      }).toList();
    }
    return results;
  }

  Future<void> deletePlaybackHistory(int episodeId) async {
    _ensureUserId();
    _playbackHistory.removeWhere(
      (h) => h['user_id'] == userId && h['episode_id'] == episodeId,
    );
  }

  Future<List<Map<String, dynamic>>> upsertFavorites(
    List<Map<String, dynamic>> favorites,
  ) async {
    _ensureUserId();
    if (favorites.isEmpty) return [];

    final items = favorites.map((f) => {...f, 'user_id': userId}).toList();

    final result = <Map<String, dynamic>>[];
    for (final item in items) {
      final episodeId = item['episode_id'];
      final existingIndex = _favorites.indexWhere(
        (f) => f['user_id'] == userId && f['episode_id'] == episodeId,
      );

      if (existingIndex >= 0) {
        _favorites[existingIndex] = {..._favorites[existingIndex], ...item};
        result.add(Map<String, dynamic>.from(_favorites[existingIndex]));
      } else {
        final newFav = {'id': _nextId++, ...item};
        _favorites.add(newFav);
        result.add(Map<String, dynamic>.from(newFav));
      }
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchFavorites() async {
    _ensureUserId();
    return _favorites
        .where((f) => f['user_id'] == userId)
        .map(Map<String, dynamic>.from)
        .toList();
  }

  Future<void> deleteFavorite(int episodeId) async {
    _ensureUserId();
    _favorites.removeWhere(
      (f) => f['user_id'] == userId && f['episode_id'] == episodeId,
    );
  }

  Future<List<Map<String, dynamic>>> upsertQueueItems(
    List<Map<String, dynamic>> items,
  ) async {
    _ensureUserId();
    if (items.isEmpty) return [];

    final records = items.map((i) => {...i, 'user_id': userId}).toList();

    final result = <Map<String, dynamic>>[];
    for (final record in records) {
      final episodeId = record['episode_id'];
      final existingIndex = _queueItems.indexWhere(
        (q) => q['user_id'] == userId && q['episode_id'] == episodeId,
      );

      if (existingIndex >= 0) {
        _queueItems[existingIndex] = {..._queueItems[existingIndex], ...record};
        result.add(Map<String, dynamic>.from(_queueItems[existingIndex]));
      } else {
        final newQueue = {'id': _nextId++, ...record};
        _queueItems.add(newQueue);
        result.add(Map<String, dynamic>.from(newQueue));
      }
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchQueueItems() async {
    _ensureUserId();
    return _queueItems
        .where((q) => q['user_id'] == userId)
        .map(Map<String, dynamic>.from)
        .toList();
  }

  Future<void> deleteQueueItem(int episodeId) async {
    _ensureUserId();
    _queueItems.removeWhere(
      (q) => q['user_id'] == userId && q['episode_id'] == episodeId,
    );
  }

  Future<void> deleteAllQueueItems() async {
    _ensureUserId();
    _queueItems.removeWhere((q) => q['user_id'] == userId);
  }
}

void main() {
  group('RemoteSyncDataSource', () {
    late FakeRemoteSyncDataSource dataSource;

    setUp(() {
      dataSource = FakeRemoteSyncDataSource();
      dataSource.userId = 'test-user-id';
    });

    group('upsertPodcasts', () {
      test('RSD-001: 应该正确插入播客数据', () async {
        final podcasts = [
          {
            'title': 'Test Podcast',
            'author': 'Test Author',
            'itunes_id': '12345',
            'description': 'A test podcast',
            'updated_at': DateTime.now().toIso8601String(),
          },
        ];

        final result = await dataSource.upsertPodcasts(podcasts);

        expect(result.length, equals(1));
        expect(result[0]['title'], equals('Test Podcast'));
        expect(result[0]['author'], equals('Test Author'));
        expect(result[0]['itunes_id'], equals('12345'));
        expect(result[0]['id'], isNotNull);
      });

      test('RSD-002: 空列表时应该返回空列表', () async {
        final result = await dataSource.upsertPodcasts([]);

        expect(result, isEmpty);
      });

      test('RSD-003: itunes_id 冲突时应该更新已有记录', () async {
        final podcasts = [
          {
            'title': 'Original Title',
            'author': 'Author',
            'itunes_id': '12345',
            'updated_at': DateTime.now().toIso8601String(),
          },
        ];

        await dataSource.upsertPodcasts(podcasts);

        final updatedPodcasts = [
          {
            'title': 'Updated Title',
            'author': 'Author',
            'itunes_id': '12345',
            'updated_at': DateTime.now().toIso8601String(),
          },
        ];

        final result = await dataSource.upsertPodcasts(updatedPodcasts);

        expect(result.length, equals(1));
        expect(result[0]['title'], equals('Updated Title'));
      });
    });

    group('fetchPodcastsUpdatedAfter', () {
      test('RSD-004: 无时间戳时应该返回所有播客', () async {
        await dataSource.upsertPodcasts([
          {
            'title': 'Podcast 1',
            'itunes_id': '1',
            'updated_at': DateTime.now().toIso8601String(),
          },
          {
            'title': 'Podcast 2',
            'itunes_id': '2',
            'updated_at': DateTime.now().toIso8601String(),
          },
        ]);

        final result = await dataSource.fetchPodcastsUpdatedAfter(null);

        expect(result.length, equals(2));
      });

      test('RSD-005: 有时间戳时应该只返回更新的播客', () async {
        final oldTime = DateTime(2024, 1, 1);
        final newTime = DateTime(2025, 1, 1);

        await dataSource.upsertPodcasts([
          {
            'title': 'Old Podcast',
            'itunes_id': '1',
            'updated_at': oldTime.toIso8601String(),
          },
        ]);
        await dataSource.upsertPodcasts([
          {
            'title': 'New Podcast',
            'itunes_id': '2',
            'updated_at': newTime.toIso8601String(),
          },
        ]);

        final since = DateTime(2024, 6, 1);
        final result = await dataSource.fetchPodcastsUpdatedAfter(since);

        expect(result.length, equals(1));
        expect(result[0]['title'], equals('New Podcast'));
      });
    });

    group('upsertEpisodes', () {
      test('RSD-006: 应该正确插入节目数据', () async {
        final episodes = [
          {
            'title': 'Episode 1',
            'guid': 'ep-guid-1',
            'podcast_id': 1,
            'audio_url': 'https://example.com/audio.mp3',
            'updated_at': DateTime.now().toIso8601String(),
          },
        ];

        final result = await dataSource.upsertEpisodes(episodes);

        expect(result.length, equals(1));
        expect(result[0]['title'], equals('Episode 1'));
        expect(result[0]['guid'], equals('ep-guid-1'));
        expect(result[0]['id'], isNotNull);
      });

      test('RSD-007: 空列表时应该返回空列表', () async {
        final result = await dataSource.upsertEpisodes([]);

        expect(result, isEmpty);
      });
    });

    group('upsertUserPodcastSubscriptions', () {
      test('RSD-008: 应该自动注入 user_id', () async {
        final subscriptions = [
          {
            'podcast_id': 1,
            'subscribed_at': DateTime.now().toIso8601String(),
          },
        ];

        final result = await dataSource.upsertUserPodcastSubscriptions(subscriptions);

        expect(result.length, equals(1));
        expect(result[0]['user_id'], equals('test-user-id'));
        expect(result[0]['podcast_id'], equals(1));
      });

      test('RSD-009: 未认证时应该抛出 StateError', () {
        dataSource.userId = null;

        expect(
          () => dataSource.upsertUserPodcastSubscriptions([
            {'podcast_id': 1},
          ]),
          throwsA(isA<StateError>()),
        );
      });

      test('RSD-010: 空列表时应该返回空列表', () async {
        final result = await dataSource.upsertUserPodcastSubscriptions([]);

        expect(result, isEmpty);
      });
    });

    group('upsertPlaybackHistory', () {
      test('RSD-011: 应该自动注入 user_id', () async {
        final records = [
          {
            'episode_id': 1,
            'last_played_position_ms': 30000,
            'is_played': false,
            'last_update_time': DateTime.now().toIso8601String(),
          },
        ];

        final result = await dataSource.upsertPlaybackHistory(records);

        expect(result.length, equals(1));
        expect(result[0]['user_id'], equals('test-user-id'));
        expect(result[0]['episode_id'], equals(1));
        expect(result[0]['last_played_position_ms'], equals(30000));
      });

      test('RSD-012: 未认证时应该抛出 StateError', () {
        dataSource.userId = null;

        expect(
          () => dataSource.upsertPlaybackHistory([
            {'episode_id': 1},
          ]),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('upsertFavorites', () {
      test('RSD-013: 应该自动注入 user_id', () async {
        final favorites = [
          {'episode_id': 1, 'episode_guid': 'guid-1'},
        ];

        final result = await dataSource.upsertFavorites(favorites);

        expect(result.length, equals(1));
        expect(result[0]['user_id'], equals('test-user-id'));
        expect(result[0]['episode_id'], equals(1));
      });

      test('RSD-014: 未认证时应该抛出 StateError', () {
        dataSource.userId = null;

        expect(
          () => dataSource.upsertFavorites([
            {'episode_id': 1},
          ]),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('upsertQueueItems', () {
      test('RSD-015: 应该自动注入 user_id', () async {
        final items = [
          {
            'episode_id': 1,
            'position': 0,
            'added_at': DateTime.now().toIso8601String(),
          },
        ];

        final result = await dataSource.upsertQueueItems(items);

        expect(result.length, equals(1));
        expect(result[0]['user_id'], equals('test-user-id'));
        expect(result[0]['episode_id'], equals(1));
        expect(result[0]['position'], equals(0));
      });

      test('RSD-016: 未认证时应该抛出 StateError', () {
        dataSource.userId = null;

        expect(
          () => dataSource.upsertQueueItems([
            {'episode_id': 1},
          ]),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('_ensureUserId', () {
      test('RSD-017: 用户已认证时不应该抛出异常', () {
        dataSource.userId = 'valid-user-id';

        expect(
          () => dataSource.fetchUserPodcastSubscriptions(),
          returnsNormally,
        );
      });

      test('RSD-018: 用户未认证时应该抛出 StateError', () {
        dataSource.userId = null;

        expect(
          () => dataSource.fetchUserPodcastSubscriptions(),
          throwsA(isA<StateError>().having(
            (e) => e.message,
            'message',
            'User is not authenticated',
          )),
        );
      });
    });

    group('delete 操作', () {
      test('应该正确删除用户播客订阅', () async {
        await dataSource.upsertUserPodcastSubscriptions([
          {'podcast_id': 1},
          {'podcast_id': 2},
        ]);

        await dataSource.deleteUserPodcastSubscription(1);

        final remaining = await dataSource.fetchUserPodcastSubscriptions();
        expect(remaining.length, equals(1));
        expect(remaining[0]['podcast_id'], equals(2));
      });

      test('应该正确删除播放历史', () async {
        await dataSource.upsertPlaybackHistory([
          {
            'episode_id': 1,
            'last_update_time': DateTime.now().toIso8601String(),
          },
          {
            'episode_id': 2,
            'last_update_time': DateTime.now().toIso8601String(),
          },
        ]);

        await dataSource.deletePlaybackHistory(1);

        final remaining = await dataSource.fetchPlaybackHistoryUpdatedAfter(null);
        expect(remaining.length, equals(1));
        expect(remaining[0]['episode_id'], equals(2));
      });

      test('应该正确删除收藏', () async {
        await dataSource.upsertFavorites([
          {'episode_id': 1},
          {'episode_id': 2},
        ]);

        await dataSource.deleteFavorite(1);

        final remaining = await dataSource.fetchFavorites();
        expect(remaining.length, equals(1));
        expect(remaining[0]['episode_id'], equals(2));
      });

      test('应该正确删除队列项', () async {
        await dataSource.upsertQueueItems([
          {'episode_id': 1, 'position': 0},
          {'episode_id': 2, 'position': 1},
        ]);

        await dataSource.deleteQueueItem(1);

        final remaining = await dataSource.fetchQueueItems();
        expect(remaining.length, equals(1));
        expect(remaining[0]['episode_id'], equals(2));
      });

      test('应该正确删除所有队列项', () async {
        await dataSource.upsertQueueItems([
          {'episode_id': 1, 'position': 0},
          {'episode_id': 2, 'position': 1},
        ]);

        await dataSource.deleteAllQueueItems();

        final remaining = await dataSource.fetchQueueItems();
        expect(remaining, isEmpty);
      });
    });

    group('fetchPlaybackHistoryUpdatedAfter', () {
      test('无时间戳时应该返回所有播放历史', () async {
        await dataSource.upsertPlaybackHistory([
          {
            'episode_id': 1,
            'last_update_time': DateTime(2024, 1, 1).toIso8601String(),
          },
          {
            'episode_id': 2,
            'last_update_time': DateTime(2025, 1, 1).toIso8601String(),
          },
        ]);

        final result = await dataSource.fetchPlaybackHistoryUpdatedAfter(null);

        expect(result.length, equals(2));
      });

      test('有时间戳时应该只返回更新的播放历史', () async {
        await dataSource.upsertPlaybackHistory([
          {
            'episode_id': 1,
            'last_update_time': DateTime(2024, 1, 1).toIso8601String(),
          },
        ]);
        await dataSource.upsertPlaybackHistory([
          {
            'episode_id': 2,
            'last_update_time': DateTime(2025, 1, 1).toIso8601String(),
          },
        ]);

        final since = DateTime(2024, 6, 1);
        final result = await dataSource.fetchPlaybackHistoryUpdatedAfter(since);

        expect(result.length, equals(1));
        expect(result[0]['episode_id'], equals(2));
      });
    });

    group('集成测试（需要真实 Supabase）', () {
      test('RemoteSyncDataSource 与真实 Supabase 通信', () {
        // 此测试需要真实的 Supabase 环境
        // 在 CI/CD 中通过 integration test 运行
      }, skip: '需要真实 Supabase 环境');
    });
  });
}
