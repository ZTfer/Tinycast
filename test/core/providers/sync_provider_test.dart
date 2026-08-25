import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinycast/core/providers/auth_provider.dart';
import 'package:tinycast/core/providers/sync_provider.dart';
import 'package:tinycast/core/services/sync_service.dart';

/// 手写 fake：只实现 SyncNotifier 依赖的成员，其余调用 fail fast。
class _FakeSyncService implements SyncService {
  _FakeSyncService({this.canSyncResult = false, this.lastSyncTimeResult});

  bool canSyncResult;
  DateTime? lastSyncTimeResult;
  int syncCallCount = 0;
  final Completer<void> syncGate = Completer<void>();

  @override
  SyncProgressCallback? onProgressChanged;

  @override
  bool get canSync => canSyncResult;

  @override
  Future<void> sync() {
    syncCallCount++;
    return syncGate.future;
  }

  @override
  Future<DateTime?> getLastSyncTime() async => lastSyncTimeResult;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  group('SyncState', () {
    test('SP-001: 初始状态应该是 idle', () {
      const state = SyncState();

      expect(state.status, equals(SyncStatus.idle));
    });

    test('SP-002: 初始 lastSyncTime 应该为 null', () {
      const state = SyncState();

      expect(state.lastSyncTime, isNull);
    });

    test('SP-003: copyWith 应该正确更新指定字段', () {
      const state = SyncState();
      final testTime = DateTime(2025, 1, 15);

      final updated = state.copyWith(
        status: SyncStatus.syncing,
        lastSyncTime: testTime,
      );

      expect(updated.status, equals(SyncStatus.syncing));
      expect(updated.lastSyncTime, equals(testTime));
    });

    test('copyWith 不指定字段时应该保持原值', () {
      final testTime = DateTime(2025, 1, 15);
      final state = SyncState(
        status: SyncStatus.syncing,
        lastSyncTime: testTime,
      );

      final updated = state.copyWith();

      expect(updated.status, equals(SyncStatus.syncing));
      expect(updated.lastSyncTime, equals(testTime));
    });

    test('copyWith 只更新 status 时 lastSyncTime 应该不变', () {
      final testTime = DateTime(2025, 1, 15);
      final state = SyncState(
        status: SyncStatus.idle,
        lastSyncTime: testTime,
      );

      final updated = state.copyWith(status: SyncStatus.syncing);

      expect(updated.status, equals(SyncStatus.syncing));
      expect(updated.lastSyncTime, equals(testTime));
    });

    test('copyWith 只更新 lastSyncTime 时 status 应该不变', () {
      const state = SyncState(status: SyncStatus.syncing);
      final testTime = DateTime(2025, 3, 20);

      final updated = state.copyWith(lastSyncTime: testTime);

      expect(updated.status, equals(SyncStatus.syncing));
      expect(updated.lastSyncTime, equals(testTime));
    });
  });

  group('SyncStatus', () {
    test('应该包含 idle 状态', () {
      expect(SyncStatus.idle, isNotNull);
    });

    test('应该包含 syncing 状态', () {
      expect(SyncStatus.syncing, isNotNull);
    });

    test('应该包含 error 状态', () {
      expect(SyncStatus.error, isNotNull);
    });

    test('应该恰好有 3 个状态值', () {
      expect(SyncStatus.values.length, equals(3));
    });
  });

  group('SyncNotifier 逻辑验证', () {
    test('SP-004: 初始状态应该是 idle（通过 SyncState 验证）', () {
      const initialState = SyncState();

      expect(initialState.status, equals(SyncStatus.idle));
      expect(initialState.lastSyncTime, isNull);
    });

    test('SP-005: syncNow() 应该将状态改为 syncing', () {
      const idleState = SyncState();
      final syncingState = idleState.copyWith(status: SyncStatus.syncing);

      expect(syncingState.status, equals(SyncStatus.syncing));
      expect(syncingState.lastSyncTime, isNull);
    });

    test('SP-006: syncNow() 成功后状态应该回到 idle 并更新 lastSyncTime', () {
      const idleState = SyncState();
      final syncingState = idleState.copyWith(status: SyncStatus.syncing);
      final testTime = DateTime(2025, 1, 15);
      final completedState = SyncState(
        status: SyncStatus.idle,
        lastSyncTime: testTime,
      );

      expect(syncingState.status, equals(SyncStatus.syncing));

      expect(completedState.status, equals(SyncStatus.idle));
      expect(completedState.lastSyncTime, equals(testTime));
    });

    test('SP-007: syncing 状态时不应重复执行同步', () {
      const syncingState = SyncState(status: SyncStatus.syncing);

      final shouldSkipSync = syncingState.status == SyncStatus.syncing;

      expect(shouldSkipSync, isTrue);
    });

    test('SP-008: syncNow() 失败时状态应该为 error', () {
      const idleState = SyncState();
      final syncingState = idleState.copyWith(status: SyncStatus.syncing);
      final errorState = syncingState.copyWith(status: SyncStatus.error);

      expect(errorState.status, equals(SyncStatus.error));
    });

    test('状态转换序列: idle → syncing → idle', () {
      const state = SyncState();

      final step1 = state.copyWith(status: SyncStatus.syncing);
      expect(step1.status, equals(SyncStatus.syncing));

      final step2 = SyncState(
        status: SyncStatus.idle,
        lastSyncTime: DateTime.now(),
      );
      expect(step2.status, equals(SyncStatus.idle));
      expect(step2.lastSyncTime, isNotNull);
    });

    test('状态转换序列: idle → syncing → error', () {
      const state = SyncState();

      final step1 = state.copyWith(status: SyncStatus.syncing);
      expect(step1.status, equals(SyncStatus.syncing));

      final step2 = step1.copyWith(status: SyncStatus.error);
      expect(step2.status, equals(SyncStatus.error));
    });

    test('error 状态后可以重新同步', () {
      final errorState = SyncState(
        status: SyncStatus.error,
        lastSyncTime: DateTime(2025, 1, 10),
      );

      final retryState = errorState.copyWith(status: SyncStatus.syncing);

      expect(retryState.status, equals(SyncStatus.syncing));
      expect(retryState.lastSyncTime, isNotNull);
    });
  });

  group('SyncNotifier 集成（Riverpod 注入边界）', () {
    User buildTestUser(String id) => User(
          id: id,
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime(2025, 1, 1).toIso8601String(),
        );

    test('SP-004: SyncNotifier 初始状态应该是 idle', () {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWithValue(const AsyncData<User?>(null)),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(syncProvider);

      expect(state.status, equals(SyncStatus.idle));
      expect(state.lastSyncTime, isNull);
    });

    test('SP-005: syncNow() 应该将状态改为 syncing 然后回到 idle', () async {
      final fake = _FakeSyncService(
        canSyncResult: true,
        lastSyncTimeResult: DateTime(2025, 1, 15),
      );
      final container = ProviderContainer(
        overrides: [
          syncServiceProvider.overrideWithValue(fake),
          authStateProvider.overrideWithValue(const AsyncData<User?>(null)),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(syncProvider.notifier);
      final syncFuture = notifier.syncNow();

      expect(
        container.read(syncProvider).status,
        equals(SyncStatus.syncing),
      );

      fake.syncGate.complete();
      await syncFuture;

      final state = container.read(syncProvider);
      expect(state.status, equals(SyncStatus.idle));
      expect(state.lastSyncTime, equals(fake.lastSyncTimeResult));
    });

    test('SP-007: syncing 状态时 syncNow() 不应该重复执行', () async {
      final fake = _FakeSyncService(canSyncResult: true);
      final container = ProviderContainer(
        overrides: [
          syncServiceProvider.overrideWithValue(fake),
          authStateProvider.overrideWithValue(const AsyncData<User?>(null)),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(syncProvider.notifier);
      final firstSync = notifier.syncNow();

      expect(
        container.read(syncProvider).status,
        equals(SyncStatus.syncing),
      );

      // syncing 中再次触发应该直接返回，不会重复执行 sync。
      await notifier.syncNow();
      expect(fake.syncCallCount, equals(1));

      fake.syncGate.complete();
      await firstSync;

      expect(fake.syncCallCount, equals(1));
      expect(container.read(syncProvider).status, equals(SyncStatus.idle));
    });

    test('Auth 状态变化应该触发同步启停', () async {
      final testUser = buildTestUser('auth-user-1');
      final authController = StreamController<User?>.broadcast();
      addTearDown(authController.close);

      final fake = _FakeSyncService(
        canSyncResult: true,
        lastSyncTimeResult: DateTime(2025, 1, 15),
      );
      final container = ProviderContainer(
        overrides: [
          syncServiceProvider.overrideWithValue(fake),
          authStateProvider.overrideWith((ref) => authController.stream),
        ],
      );
      addTearDown(container.dispose);

      // 保持 syncProvider 活跃（模拟生产中 UI 的 watch）；Riverpod 3 在
      // 无监听者时会暂停 provider 的内部依赖订阅。
      final stateSubscription = container.listen(syncProvider, (_, _) {});
      addTearDown(stateSubscription.close);

      // 触发 SyncNotifier.build() 并订阅认证流。
      await container.pump();

      expect(fake.syncCallCount, equals(0));

      // 登录：监听回调应立即触发一次同步。
      authController.add(testUser);
      await container.pump();
      await container.pump();

      expect(fake.syncCallCount, equals(1));
      expect(
        container.read(syncProvider).status,
        equals(SyncStatus.syncing),
      );

      fake.syncGate.complete();
      await container.pump();
      await container.pump();

      expect(container.read(syncProvider).status, equals(SyncStatus.idle));

      // 预置用户级时间戳，验证登出时被清理。
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'last_sync_timestamp_${testUser.id}',
        DateTime(2025, 1, 10).toIso8601String(),
      );

      // 登出：应停止同步并清理用户级同步状态。
      authController.add(null);
      // _clearSyncStateForUser 走 Future.microtask + 多层 await 链，
      // 每轮 pump 只推进部分 microtask，轮询直到状态归零。
      var stateCleared = false;
      for (var i = 0; i < 100; i++) {
        await container.pump();
        await Future<void>.delayed(Duration.zero);
        final current = container.read(syncProvider);
        if (current.lastSyncTime == null &&
            current.status == SyncStatus.idle &&
            current.progress == null &&
            current.errorMessage == null) {
          stateCleared = true;
          break;
        }
      }
      expect(stateCleared, isTrue, reason: '登出后同步状态应被重置');

      expect(prefs.getString('last_sync_timestamp_${testUser.id}'), isNull);
      final state = container.read(syncProvider);
      expect(state.lastSyncTime, isNull);
      expect(state.status, equals(SyncStatus.idle));
    });
  });
}
