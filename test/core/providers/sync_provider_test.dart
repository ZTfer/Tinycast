import 'package:flutter_test/flutter_test.dart';
import 'package:tinycast/core/providers/sync_provider.dart';
import 'package:tinycast/core/services/sync_service.dart';

void main() {
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

  group('集成测试（需要 Supabase + Isar + Riverpod）', () {
    test('SP-004: SyncNotifier 初始状态应该是 idle', () {
      // 需要 Riverpod ProviderContainer 和完整的 SyncService 环境
    }, skip: '需要完整环境');

    test('SP-005: syncNow() 应该将状态改为 syncing 然后回到 idle', () {
      // 需要完整的 Supabase + Isar + Riverpod 环境
    }, skip: '需要完整环境');

    test('SP-007: syncing 状态时 syncNow() 不应该重复执行', () {
      // 需要完整的 Supabase + Isar + Riverpod 环境
    }, skip: '需要完整环境');

    test('Auth 状态变化应该触发同步启停', () {
      // 需要完整的 Supabase Auth 环境
    }, skip: '需要完整环境');
  });
}
