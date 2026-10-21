import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/data/services/audio_download_service.dart';

class DownloadState {
  final Map<String, DownloadStatus> episodeStatuses;
  final Map<String, double> episodeProgress;
  final int activeDownloads;
  final int queuedDownloads;
  final DateTime? lastUpdateTime;

  const DownloadState({
    this.episodeStatuses = const {},
    this.episodeProgress = const {},
    this.activeDownloads = 0,
    this.queuedDownloads = 0,
    this.lastUpdateTime,
  });

  DownloadState copyWith({
    Map<String, DownloadStatus>? episodeStatuses,
    Map<String, double>? episodeProgress,
    int? activeDownloads,
    int? queuedDownloads,
    DateTime? lastUpdateTime,
  }) {
    return DownloadState(
      episodeStatuses: episodeStatuses ?? this.episodeStatuses,
      episodeProgress: episodeProgress ?? this.episodeProgress,
      activeDownloads: activeDownloads ?? this.activeDownloads,
      queuedDownloads: queuedDownloads ?? this.queuedDownloads,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
    );
  }

  bool isAnyDownloading() {
    return episodeStatuses.values.any(
      (status) => status == DownloadStatus.downloading || status == DownloadStatus.queued,
    );
  }

  List<String> getCompletedEpisodes() {
    return episodeStatuses.entries
        .where((entry) => entry.value == DownloadStatus.completed)
        .map((entry) => entry.key)
        .toList();
  }
}

class DownloadNotifier extends Notifier<DownloadState> {
  late final StreamSubscription<AudioDownloadEvent> _globalSubscription;

  @override
  DownloadState build() {
    final audioDownloadService = AudioDownloadService.instance;

    _globalSubscription = audioDownloadService.globalEventStream.listen(
      (event) {
        Logger.debug('🔄 [DownloadProvider] Received event: ${event.episodeId} -> ${event.status}');

        final newStatuses = Map<String, DownloadStatus>.from(state.episodeStatuses);
        newStatuses[event.episodeId] = event.status;

        Map<String, double>? newProgress;
        if (event.progress != null) {
          newProgress = Map<String, double>.from(state.episodeProgress);
          newProgress[event.episodeId] = event.progress!;
        }

        state = state.copyWith(
          episodeStatuses: newStatuses,
          episodeProgress: newProgress ?? state.episodeProgress,
          activeDownloads: audioDownloadService.downloadQueue.activeDownloadsCount,
          queuedDownloads: audioDownloadService.downloadQueue.queueLength,
          lastUpdateTime: DateTime.now(),
        );

        if (event.status == DownloadStatus.completed ||
            event.status == DownloadStatus.failed) {
          Logger.info('✅ [DownloadProvider] Episode ${event.episodeId} download ${event.status}, UI will auto-refresh');
        }
      },
      onError: (error) {
        Logger.error('[DownloadProvider] Error in global event stream: $error');
      },
    );

    ref.onDispose(() {
      _globalSubscription.cancel();
    });

    return const DownloadState();
  }

  void manualRefresh() {
    final audioDownloadService = AudioDownloadService.instance;
    state = state.copyWith(
      activeDownloads: audioDownloadService.downloadQueue.activeDownloadsCount,
      queuedDownloads: audioDownloadService.downloadQueue.queueLength,
      lastUpdateTime: DateTime.now(),
    );
  }

  void clearEpisode(String episodeId) {
    final newStatuses = Map<String, DownloadStatus>.from(state.episodeStatuses);
    final newProgress = Map<String, double>.from(state.episodeProgress);

    newStatuses.remove(episodeId);
    newProgress.remove(episodeId);

    state = state.copyWith(
      episodeStatuses: newStatuses,
      episodeProgress: newProgress,
      lastUpdateTime: DateTime.now(),
    );
  }

  void clearAll() {
    state = DownloadState(lastUpdateTime: DateTime.now());
  }

  DownloadStatus? getEpisodeStatus(String episodeId) {
    return state.episodeStatuses[episodeId];
  }

  double? getEpisodeProgress(String episodeId) {
    return state.episodeProgress[episodeId];
  }
}

final downloadNotifierProvider =
    NotifierProvider<DownloadNotifier, DownloadState>(
  DownloadNotifier.new,
);

final downloadActiveCountProvider = Provider<int>((ref) {
  final downloadState = ref.watch(downloadNotifierProvider);
  return downloadState.activeDownloads;
});

final downloadQueuedCountProvider = Provider<int>((ref) {
  final downloadState = ref.watch(downloadNotifierProvider);
  return downloadState.queuedDownloads;
});

final isDownloadingProvider = Provider<bool>((ref) {
  final downloadState = ref.watch(downloadNotifierProvider);
  return downloadState.isAnyDownloading();
});

final completedDownloadsProvider = Provider<List<String>>((ref) {
  final downloadState = ref.watch(downloadNotifierProvider);
  return downloadState.getCompletedEpisodes();
});
