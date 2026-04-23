import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger.dart';
import '../../../data/services/audio_download_service.dart';
import '../../../domain/entities/episode.dart';
import '../../../domain/usecases/get_downloaded_episodes_usecase.dart';
import '../../providers/podcast_provider.dart';

enum DownloadedEpisodesStatus { initial, loading, success, error }

class DownloadedEpisodesState {
  final DownloadedEpisodesStatus status;
  final List<Episode> episodes;
  final String? errorMessage;

  DownloadedEpisodesState({
    this.status = DownloadedEpisodesStatus.initial,
    this.episodes = const [],
    this.errorMessage,
  });

  DownloadedEpisodesState copyWith({
    DownloadedEpisodesStatus? status,
    List<Episode>? episodes,
    String? errorMessage,
  }) {
    return DownloadedEpisodesState(
      status: status ?? this.status,
      episodes: episodes ?? this.episodes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final getDownloadedEpisodesUseCaseProvider = Provider<GetDownloadedEpisodesUseCase>((ref) {
  final repository = ref.watch(podcastRepositoryProvider);
  return GetDownloadedEpisodesUseCase(repository);
});

class DownloadedEpisodesNotifier extends Notifier<DownloadedEpisodesState> {
  StreamSubscription<AudioDownloadEvent>? _downloadSubscription;

  @override
  DownloadedEpisodesState build() {
    Future.microtask(() => loadDownloadedEpisodes());

    _downloadSubscription = AudioDownloadService.instance.globalEventStream.listen((event) {
      if (event.status == DownloadStatus.completed ||
          event.status == DownloadStatus.failed ||
          event.status == DownloadStatus.cancelled) {
        Logger.info('📦 [DOWNLOADED-EPISODES] 下载状态变化: ${event.episodeId} -> ${event.status}, 刷新列表');
        _loadDownloadedEpisodesSilent();
      }
    });

    ref.onDispose(() {
      _downloadSubscription?.cancel();
    });

    return DownloadedEpisodesState();
  }

  GetDownloadedEpisodesUseCase get _getDownloadedEpisodesUseCase =>
      ref.read(getDownloadedEpisodesUseCaseProvider);

  Future<void> loadDownloadedEpisodes() async {
    state = state.copyWith(status: DownloadedEpisodesStatus.loading, errorMessage: null);
    try {
      final episodes = await _getDownloadedEpisodesUseCase();
      state = state.copyWith(status: DownloadedEpisodesStatus.success, episodes: episodes);
    } catch (e) {
      state = state.copyWith(
        status: DownloadedEpisodesStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _loadDownloadedEpisodesSilent() async {
    try {
      final episodes = await _getDownloadedEpisodesUseCase();
      state = state.copyWith(status: DownloadedEpisodesStatus.success, episodes: episodes);
    } catch (e) {
      Logger.error('📦 [DOWNLOADED-EPISODES] 刷新列表失败', error: e);
    }
  }

  Future<void> refresh() async {
    await loadDownloadedEpisodes();
  }

  void reset() {
    state = DownloadedEpisodesState();
  }
}

final downloadedEpisodesNotifierProvider =
    NotifierProvider<DownloadedEpisodesNotifier, DownloadedEpisodesState>(
  DownloadedEpisodesNotifier.new,
);

final downloadedEpisodesProvider = Provider<List<Episode>>((ref) {
  final state = ref.watch(downloadedEpisodesNotifierProvider);
  final sortedEpisodes = [...state.episodes];
  sortedEpisodes.sort((a, b) => b.pubDate.compareTo(a.pubDate));
  return sortedEpisodes;
});

final downloadedEpisodesLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(downloadedEpisodesNotifierProvider);
  return state.status == DownloadedEpisodesStatus.loading;
});
