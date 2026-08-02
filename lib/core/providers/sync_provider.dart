import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/providers/auth_provider.dart';
import 'package:tinycast/core/services/sync_service.dart';
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
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
    );
  }
}

class SyncNotifier extends Notifier<SyncState> {
  Timer? _syncTimer;
  Timer? _debounceTimer;
  static const Duration _syncInterval = Duration(minutes: 5);
  static const Duration _debounceDelay = Duration(seconds: 10);

  @override
  SyncState build() {
    ref.listen(authStateProvider, (previous, next) {
      final wasLoggedIn = previous?.value != null;
      final isLoggedIn = next.value != null;

      if (isLoggedIn && !wasLoggedIn) {
        _startPeriodicSync();
        Future.microtask(() => syncNow());
      } else if (!isLoggedIn && wasLoggedIn) {
        _stopPeriodicSync();
      }
    });

    final isLoggedIn = ref.read(authStateProvider).value != null;
    if (isLoggedIn) {
      _startPeriodicSync();
      _loadLastSyncTime();
      Future.microtask(() => syncNow());
    }

    ref.onDispose(() {
      _stopPeriodicSync();
      _debounceTimer?.cancel();
    });

    return const SyncState();
  }

  Future<void> _loadLastSyncTime() async {
    try {
      final syncService = SyncService();
      final lastSyncTime = await syncService.getLastSyncTime();
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

  void requestSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      syncNow();
    });
  }

  Future<void> syncNow() async {
    if (state.status == SyncStatus.syncing) return;

    final syncService = SyncService();
    if (!syncService.canSync) return;

    state = state.copyWith(status: SyncStatus.syncing, errorMessage: null);

    try {
      syncService.onProgressChanged = (progress) {
        state = state.copyWith(progress: progress);
      };

      await syncService.sync();
      final lastSyncTime = await syncService.getLastSyncTime();
      state = state.copyWith(
        status: SyncStatus.idle,
        lastSyncTime: lastSyncTime,
      );

      _invalidateRelatedProviders();
      Logger.info('Sync completed successfully');
    } catch (e, stackTrace) {
      Logger.error('Sync failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
    } finally {
      syncService.onProgressChanged = null;
    }
  }

  void _invalidateRelatedProviders() {
    ref.invalidate(queueNotifierProvider);
    ref.invalidate(favoriteProvider);
    ref.invalidate(favoriteEpisodesNotifierProvider);
    ref.invalidate(unplayedEpisodesNotifierProvider);
    ref.invalidate(subscribedPodcastsProvider);
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
