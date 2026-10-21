import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/providers/auth_provider.dart';
import 'package:tinycast/core/services/local_account_data_service.dart';
import 'package:tinycast/core/services/sync_service.dart';
import 'package:tinycast/core/services/sync_tombstone_store.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/presentation/providers/queue_provider.dart';
import 'package:tinycast/presentation/providers/favorite_provider.dart';
import 'package:tinycast/presentation/providers/favorite_episodes_provider.dart';
import 'package:tinycast/presentation/providers/unplayed_episodes_provider.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/presentation/providers/play_history_provider.dart';

class SyncState {
  final SyncStatus status;
  final DateTime? lastSyncTime;
  final SyncProgress? progress;
  final String? errorMessage;

  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncTime,
    this.progress,
    this.errorMessage,
  });

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncTime,
    SyncProgress? progress,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      progress: progress ?? this.progress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Factory for the [SyncService] consumed by [SyncNotifier].
///
/// Production uses the default construction; tests override this provider
/// to inject a fake service instead of reaching into global singletons.
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});

final localAccountDataServiceProvider = Provider<LocalAccountDataService>((
  ref,
) {
  return LocalAccountDataService();
});

class SyncNotifier extends Notifier<SyncState> {
  Timer? _syncTimer;
  Timer? _debounceTimer;
  Future<void>? _runningSync;
  static const Duration _syncInterval = Duration(minutes: 5);
  static const Duration _debounceDelay = Duration(seconds: 10);

  @override
  SyncState build() {
    ref.listen(authStateProvider, (previous, next) {
      final previousUserId = previous?.value?.id;
      final currentUser = next.value;
      final wasLoggedIn = previous?.value != null;
      final isLoggedIn = currentUser != null;

      if (isLoggedIn) {
        if (!wasLoggedIn) {
          _startPeriodicSync();
        }
        if (!wasLoggedIn || currentUser.id != previousUserId) {
          Future.microtask(() => _prepareAccount(currentUser.id));
        }
      } else if (!isLoggedIn && wasLoggedIn) {
        _stopPeriodicSync();
        // Clear user-scoped sync state so the next account cannot inherit
        // pending deletes or last-pushed snapshots from this session.
        Future.microtask(() => _clearSyncStateForUser(previousUserId));
      }
    });

    final currentUser = ref.read(authStateProvider).value;
    if (currentUser != null) {
      _startPeriodicSync();
      _loadLastSyncTime();
      Future.microtask(() => _prepareAccount(currentUser.id));
    }

    ref.onDispose(() {
      // Riverpod 3 forbids modifying provider state inside life-cycle
      // callbacks, so only the timers are cancelled here.
      _syncTimer?.cancel();
      _syncTimer = null;
      _debounceTimer?.cancel();
    });

    return const SyncState();
  }

  /// 在同步前确认本地数据属于当前账号；账号切换时先清空旧账号数据。
  Future<void> _prepareAccount(String userId) async {
    // 等待上一轮同步结束，避免清理数据与上传同时进行。
    final running = _runningSync;
    if (running != null) {
      try {
        await running;
      } catch (_) {
        // 上一轮同步的失败不影响账号预处理。
      }
    }
    if (!ref.mounted) return;

    try {
      final switched = await ref
          .read(localAccountDataServiceProvider)
          .prepareForUser(userId);
      if (!ref.mounted) return;
      if (switched) {
        Logger.info('[SYNC] 账号已切换，旧账号本地数据已清理');
        _invalidateRelatedProviders();
        state = const SyncState();
      }
    } catch (e, stackTrace) {
      if (!ref.mounted) return;
      Logger.error(
        'Failed to prepare local data for account',
        error: e,
        stackTrace: stackTrace,
      );
    }

    await _loadLastSyncTime();
    if (!ref.mounted) return;
    await syncNow();
  }

  Future<void> _loadLastSyncTime() async {
    if (!ref.mounted) return;
    try {
      final syncService = ref.read(syncServiceProvider);
      final lastSyncTime = await syncService.getLastSyncTime();
      if (!ref.mounted) return;
      if (lastSyncTime != null) {
        state = state.copyWith(lastSyncTime: lastSyncTime);
      }
    } catch (e) {
      Logger.error('Failed to load last sync time', error: e);
    }
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      syncNow();
    });
    Logger.info('Periodic sync started (every ${_syncInterval.inMinutes} minutes)');
  }

  void _stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    state = state.copyWith(status: SyncStatus.idle);
    Logger.info('Periodic sync stopped');
  }

  Future<void> _clearSyncStateForUser(String? userId) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        await SyncTombstoneStore.instance.clearForUser(userId);
        await SyncService.clearLastSyncTimeForUser(userId);
      }
      await SyncTombstoneStore.instance.clearLegacyUnscopedKeys();
      await SyncService.clearLegacyLastSyncTime();
      // 清理链跨越多个 await：期间 provider 可能已被销毁（例如登出后
      // 立即退出应用）。写 state 前确认 Ref 仍存活。
      if (!ref.mounted) return;
      // copyWith 的 null 合并语义无法把 lastSyncTime 置回 null，
      // 直接重置整个状态，避免下一账号继承上一账号的同步状态。
      state = const SyncState();
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to clear sync state on sign-out',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void requestSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      syncNow();
    });
  }

  Future<void> syncNow() async {
    if (!ref.mounted) return;
    if (state.status == SyncStatus.syncing) return;

    final syncService = ref.read(syncServiceProvider);
    if (!syncService.canSync) return;

    state = state.copyWith(status: SyncStatus.syncing, clearError: true);

    final future = _performSync(syncService);
    _runningSync = future;
    try {
      await future;
    } finally {
      if (identical(_runningSync, future)) {
        _runningSync = null;
      }
    }
  }

  Future<void> _performSync(SyncService syncService) async {
    try {
      syncService.onProgressChanged = (progress) {
        if (!ref.mounted) return;
        state = state.copyWith(progress: progress);
      };

      final result = await syncService.sync();
      if (!ref.mounted) return;

      switch (result.status) {
        case SyncResultStatus.success:
          final lastSyncTime = await syncService.getLastSyncTime();
          if (!ref.mounted) return;
          state = state.copyWith(
            status: SyncStatus.idle,
            lastSyncTime: lastSyncTime,
          );
          _invalidateRelatedProviders();
          Logger.info('Sync completed successfully');
        case SyncResultStatus.partial:
          // Some steps merged data locally but the cursor did not advance;
          // reflect the partial result instead of claiming success.
          state = state.copyWith(
            status: SyncStatus.error,
            errorMessage: '同步部分失败：${result.failedSteps.join(', ')}',
          );
          _invalidateRelatedProviders();
          Logger.warning(
            'Sync finished partially: ${result.failedSteps.join(', ')}',
          );
        case SyncResultStatus.pullFailed:
        case SyncResultStatus.failed:
          state = state.copyWith(
            status: SyncStatus.error,
            errorMessage: result.error?.toString() ?? '同步失败',
          );
          Logger.error('Sync failed: ${result.error}');
        case SyncResultStatus.skipped:
          state = state.copyWith(status: SyncStatus.idle);
          Logger.warning('Sync skipped: not authenticated');
      }
    } catch (e, stackTrace) {
      Logger.error('Sync failed', error: e, stackTrace: stackTrace);
      if (!ref.mounted) return;
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
    } finally {
      syncService.onProgressChanged = null;
    }
  }

  void _invalidateRelatedProviders() {
    if (!ref.mounted) return;
    ref.invalidate(queueNotifierProvider);
    ref.invalidate(favoriteProvider);
    ref.invalidate(favoriteEpisodesNotifierProvider);
    ref.invalidate(unplayedEpisodesNotifierProvider);
    ref.invalidate(subscribedPodcastsProvider);
    ref.invalidate(podcastProvider);
    ref.invalidate(latestPlayingHistoryProvider);
  }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);

final syncStatusProvider = Provider<SyncStatus>((ref) {
  return ref.watch(syncProvider).status;
});

final lastSyncTimeProvider = Provider<DateTime?>((ref) {
  return ref.watch(syncProvider).lastSyncTime;
});

final syncProgressProvider = Provider<SyncProgress?>((ref) {
  return ref.watch(syncProvider).progress;
});
