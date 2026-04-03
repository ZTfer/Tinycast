import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tinycast/data/models/episode_model.dart';
import 'package:tinycast/data/services/file_storage_service.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/core/utils/app_exception.dart';

enum DownloadStatus {
  idle,
  queued,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

class DownloadTask {
  final String episodeId;
  final String audioUrl;
  final String relativeFilePath;
  final String tempFilePath;
  CancelToken cancelToken;
  DownloadStatus status;
  double progress;
  int? totalBytes;
  int? downloadedBytes;
  String? errorMessage;
  final DateTime createdAt;
  final int priority;

  DownloadTask({
    required this.episodeId,
    required this.audioUrl,
    required this.relativeFilePath,
    required this.tempFilePath,
    required this.cancelToken,
    this.status = DownloadStatus.idle,
    this.progress = 0.0,
    this.totalBytes,
    this.downloadedBytes,
    this.errorMessage,
    DateTime? createdAt,
    this.priority = 0,
  }) : createdAt = createdAt ?? DateTime.now();
}

class DownloadQueue {
  final int maxConcurrentDownloads;
  final Queue<DownloadTask> _queue = Queue<DownloadTask>();
  final Map<String, DownloadTask> _activeDownloads = {};
  final List<String> _completedIds = [];
  final List<String> _failedIds = [];

  DownloadQueue({this.maxConcurrentDownloads = 3});

  bool get canStartNewDownload =>
      _activeDownloads.length < maxConcurrentDownloads;

  bool get isEmpty => _queue.isEmpty && _activeDownloads.isEmpty;

  int get queueLength => _queue.length;

  int get activeDownloadsCount => _activeDownloads.length;

  void enqueue(DownloadTask task) {
    task.status = DownloadStatus.queued;
    _queue.add(task);
  }

  DownloadTask? dequeue() {
    if (_queue.isEmpty || !canStartNewDownload) return null;
    final task = _queue.removeFirst();
    _activeDownloads[task.episodeId] = task;
    return task;
  }

  void markAsCompleted(String episodeId) {
    _activeDownloads.remove(episodeId);
    _completedIds.add(episodeId);
  }

  void markAsFailed(String episodeId) {
    _activeDownloads.remove(episodeId);
    _failedIds.add(episodeId);
  }

  void removeActive(String episodeId) {
    _activeDownloads.remove(episodeId);
  }

  DownloadTask? getActive(String episodeId) => _activeDownloads[episodeId];

  List<DownloadTask> get allQueued => _queue.toList();

  List<DownloadTask> get allActive => _activeDownloads.values.toList();

  void clear() {
    _queue.clear();
    _activeDownloads.clear();
    _completedIds.clear();
    _failedIds.clear();
  }

  void removeQueued(String episodeId) {
    _queue.removeWhere((task) => task.episodeId == episodeId);
  }
}

class AudioDownloadService {
  AudioDownloadService._();

  static final AudioDownloadService _instance = AudioDownloadService._();

  static AudioDownloadService get instance => _instance;

  final Map<String, DownloadTask> _downloadTasks = {};
  final Map<String, StreamController<DownloadStatus>> _statusControllers = {};
  final Map<String, StreamController<double>> _progressControllers = {};
  final DownloadQueue _downloadQueue = DownloadQueue(maxConcurrentDownloads: 3);

  final Dio _dio = Dio();
  final FileStorageService _fileStorageService = FileStorageService.instance;
  final IsarService _isarService = IsarService.instance;

  DownloadQueue get downloadQueue => _downloadQueue;

  Future<void> downloadEpisode(Episode episode) async {
    final episodeId = episode.id.toString();

    if (_downloadTasks.containsKey(episodeId)) {
      final existingTask = _downloadTasks[episodeId]!;
      if (existingTask.status == DownloadStatus.downloading) {
        Logger.info('Download already in progress for episode: $episodeId');
        return;
      }
      if (existingTask.status == DownloadStatus.paused) {
        await resumeDownload(episodeId);
        return;
      }
    }

    try {
      final audioDir = await _fileStorageService.getAudioDirectory();
      final tempDir = await _fileStorageService.getTemporaryDirectory();

      final fileName = _fileStorageService.generateAudioFileName(episodeId);
      final relativeFilePath = 'audio/$fileName';
      final absoluteFilePath = '${audioDir.path}/$fileName';
      final tempFilePath = '${tempDir.path}/$fileName';

      final cancelToken = CancelToken();
      final downloadTask = DownloadTask(
        episodeId: episodeId,
        audioUrl: episode.audioUrl,
        relativeFilePath: relativeFilePath,
        tempFilePath: tempFilePath,
        cancelToken: cancelToken,
        status: DownloadStatus.downloading,
        progress: 0.0,
      );

      _downloadTasks[episodeId] = downloadTask;

      await _updateEpisodeDownloadStatus(
        episodeId: episodeId,
        isDownloaded: false,
        downloadedPath: null,
        downloadProgress: 0.0,
      );

      _notifyStatusChange(episodeId, DownloadStatus.downloading);

      final file = File(tempFilePath);
      final exists = await file.exists();
      int downloadedBytes = 0;

      if (exists) {
        downloadedBytes = await file.length();
        downloadTask.downloadedBytes = downloadedBytes;
      }

      final options = Options(
        receiveDataWhenStatusError: true,
        headers: downloadedBytes > 0
            ? {'Range': 'bytes=$downloadedBytes-'}
            : null,
      );

      await _dio.download(
        episode.audioUrl,
        tempFilePath,
        cancelToken: cancelToken,
        options: options,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final totalProgress = downloadedBytes + received;
            final progress = totalProgress / total;
            downloadTask.progress = progress;
            downloadTask.downloadedBytes = totalProgress;
            downloadTask.totalBytes = total;

            _notifyProgressChange(episodeId, progress);
            _updateEpisodeDownloadProgress(episodeId, progress);
          }
        },
      );

      downloadTask.status = DownloadStatus.completed;
      downloadTask.progress = 1.0;

      final finalFile = File(absoluteFilePath);
      if (await finalFile.exists()) {
        await finalFile.delete();
      }

      await File(tempFilePath).rename(absoluteFilePath);

      await _updateEpisodeDownloadStatus(
        episodeId: episodeId,
        isDownloaded: true,
        downloadedPath: relativeFilePath,
        downloadProgress: 1.0,
      );

      _notifyStatusChange(episodeId, DownloadStatus.completed);

      Logger.info('Download completed for episode: $episodeId');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        _downloadTasks[episodeId]?.status = DownloadStatus.cancelled;
        _notifyStatusChange(episodeId, DownloadStatus.cancelled);
        Logger.info('Download cancelled for episode: $episodeId');
      } else {
        _downloadTasks[episodeId]?.status = DownloadStatus.failed;
        _downloadTasks[episodeId]?.errorMessage = e.message;
        _notifyStatusChange(episodeId, DownloadStatus.failed);
        Logger.error('Download failed for episode: $episodeId', error: e);
      }
    } catch (e, stackTrace) {
      _downloadTasks[episodeId]?.status = DownloadStatus.failed;
      _downloadTasks[episodeId]?.errorMessage = e.toString();
      _notifyStatusChange(episodeId, DownloadStatus.failed);
      Logger.error(
        'Download error for episode: $episodeId',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> pauseDownload(String episodeId) async {
    final task = _downloadTasks[episodeId];
    if (task == null) {
      Logger.warning('No download task found for episode: $episodeId');
      return;
    }

    if (task.status != DownloadStatus.downloading) {
      Logger.warning('Download is not in progress for episode: $episodeId');
      return;
    }

    try {
      task.cancelToken.cancel('Download paused by user');
      task.status = DownloadStatus.paused;

      _notifyStatusChange(episodeId, DownloadStatus.paused);
      Logger.info('Download paused for episode: $episodeId');
    } catch (e, stackTrace) {
      Logger.error(
        'Error pausing download for episode: $episodeId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> resumeDownload(String episodeId) async {
    final task = _downloadTasks[episodeId];
    if (task == null) {
      Logger.warning('No download task found for episode: $episodeId');
      return;
    }

    if (task.status != DownloadStatus.paused) {
      Logger.warning('Download is not paused for episode: $episodeId');
      return;
    }

    try {
      final episode = await _isarService.isar.episodes.get(
        int.parse(episodeId),
      );

      if (episode == null) {
        throw AppException.unknown('Episode not found: $episodeId');
      }

      await downloadEpisode(episode);
    } catch (e, stackTrace) {
      Logger.error(
        'Error resuming download for episode: $episodeId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> cancelDownload(String episodeId) async {
    final task = _downloadTasks[episodeId];
    if (task == null) {
      Logger.warning('No download task found for episode: $episodeId');
      return;
    }

    try {
      if (task.status == DownloadStatus.downloading) {
        task.cancelToken.cancel('Download cancelled by user');
      }

      final tempFile = File(task.tempFilePath);
      if (await tempFile.exists()) {
        await tempFile.delete();
        Logger.info('Temporary file deleted for episode: $episodeId');
      }

      task.status = DownloadStatus.cancelled;

      await _updateEpisodeDownloadStatus(
        episodeId: episodeId,
        isDownloaded: false,
        downloadedPath: null,
        downloadProgress: 0.0,
      );

      _notifyStatusChange(episodeId, DownloadStatus.cancelled);
      Logger.info('Download cancelled for episode: $episodeId');
    } catch (e, stackTrace) {
      Logger.error(
        'Error cancelling download for episode: $episodeId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<double> getDownloadProgress(String episodeId) async {
    final task = _downloadTasks[episodeId];
    if (task != null) {
      return task.progress;
    }

    final episode = await _isarService.isar.episodes.get(int.parse(episodeId));

    if (episode != null) {
      return episode.downloadProgress;
    }

    return 0.0;
  }

  Future<bool> isEpisodeDownloaded(String episodeId) async {
    final episode = await _isarService.isar.episodes.get(int.parse(episodeId));

    if (episode == null) {
      return false;
    }

    if (!episode.isDownloaded || episode.downloadedPath == null) {
      return false;
    }

    final fileExists = await _fileStorageService.fileExists(
      episode.downloadedPath!,
    );

    return fileExists;
  }

  Stream<DownloadStatus> getDownloadStatusStream(String episodeId) {
    if (!_statusControllers.containsKey(episodeId)) {
      _statusControllers[episodeId] =
          StreamController<DownloadStatus>.broadcast();
    }
    return _statusControllers[episodeId]!.stream;
  }

  Stream<double> getDownloadProgressStream(String episodeId) {
    if (!_progressControllers.containsKey(episodeId)) {
      _progressControllers[episodeId] = StreamController<double>.broadcast();
    }
    return _progressControllers[episodeId]!.stream;
  }

  DownloadStatus? getDownloadStatus(String episodeId) {
    return _downloadTasks[episodeId]?.status;
  }

  Future<void> deleteDownloadedEpisode(String episodeId) async {
    try {
      final episode = await _isarService.isar.episodes.get(
        int.parse(episodeId),
      );

      if (episode == null) {
        throw AppException.unknown('Episode not found: $episodeId');
      }

      if (episode.downloadedPath != null) {
        final file = File(episode.downloadedPath!);
        if (await file.exists()) {
          await file.delete();
          Logger.info('Downloaded file deleted for episode: $episodeId');
        }
      }

      await _updateEpisodeDownloadStatus(
        episodeId: episodeId,
        isDownloaded: false,
        downloadedPath: null,
        downloadProgress: 0.0,
      );

      _downloadTasks.remove(episodeId);
      _disposeControllers(episodeId);

      Logger.info('Downloaded episode deleted: $episodeId');
    } catch (e, stackTrace) {
      Logger.error(
        'Error deleting downloaded episode: $episodeId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _updateEpisodeDownloadStatus({
    required String episodeId,
    required bool isDownloaded,
    required String? downloadedPath,
    required double downloadProgress,
  }) async {
    try {
      await _isarService.isar.writeTxn(() async {
        final episode = await _isarService.isar.episodes.get(
          int.parse(episodeId),
        );

        if (episode != null) {
          episode.isDownloaded = isDownloaded;
          episode.downloadedPath = downloadedPath;
          episode.downloadProgress = downloadProgress;
          episode.updatedAt = DateTime.now();
          await _isarService.isar.episodes.put(episode);
        }
      });
    } catch (e, stackTrace) {
      Logger.error(
        'Error updating episode download status: $episodeId',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _updateEpisodeDownloadProgress(
    String episodeId,
    double progress,
  ) async {
    try {
      await _isarService.isar.writeTxn(() async {
        final episode = await _isarService.isar.episodes.get(
          int.parse(episodeId),
        );

        if (episode != null) {
          episode.downloadProgress = progress;
          episode.updatedAt = DateTime.now();
          await _isarService.isar.episodes.put(episode);
        }
      });
    } catch (e, stackTrace) {
      Logger.error(
        'Error updating episode download progress: $episodeId',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _notifyStatusChange(String episodeId, DownloadStatus status) {
    final controller = _statusControllers[episodeId];
    if (controller != null && !controller.isClosed) {
      controller.add(status);
    }
  }

  void _notifyProgressChange(String episodeId, double progress) {
    final controller = _progressControllers[episodeId];
    if (controller != null && !controller.isClosed) {
      controller.add(progress);
    }
  }

  void _disposeControllers(String episodeId) {
    _statusControllers[episodeId]?.close();
    _progressControllers[episodeId]?.close();
    _statusControllers.remove(episodeId);
    _progressControllers.remove(episodeId);
  }

  Future<void> downloadEpisodesBatch(List<Episode> episodes) async {
    Logger.info('开始批量下载 ${episodes.length} 个节目');

    for (final episode in episodes) {
      final episodeId = episode.id.toString();

      if (_downloadTasks.containsKey(episodeId)) {
        final existingTask = _downloadTasks[episodeId]!;
        if (existingTask.status == DownloadStatus.downloading ||
            existingTask.status == DownloadStatus.queued) {
          Logger.info('节目已在下载队列中: $episodeId');
          continue;
        }
      }

      await _enqueueDownload(episode);
    }

    _processQueue();
  }

  Future<void> downloadPodcastEpisodes(int podcastId, {int? limit}) async {
    Logger.info('开始下载播客 $podcastId 的所有节目');

    try {
      final episodes = await _isarService.isar.episodes
          .filter()
          .podcastIdEqualTo(podcastId)
          .sortByPubDateDesc()
          .findAll();

      final episodesToDownload = limit != null
          ? episodes.take(limit).toList()
          : episodes;

      Logger.info('找到 ${episodesToDownload.length} 个节目待下载');

      await downloadEpisodesBatch(episodesToDownload);
    } catch (e, stackTrace) {
      Logger.error('下载播客节目失败: $podcastId', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _enqueueDownload(Episode episode) async {
    final episodeId = episode.id.toString();

    try {
      final tempDir = await _fileStorageService.getTemporaryDirectory();

      final fileName = _fileStorageService.generateAudioFileName(episodeId);
      final relativeFilePath = 'audio/$fileName';
      final tempFilePath = '${tempDir.path}/$fileName';

      final cancelToken = CancelToken();
      final downloadTask = DownloadTask(
        episodeId: episodeId,
        audioUrl: episode.audioUrl,
        relativeFilePath: relativeFilePath,
        tempFilePath: tempFilePath,
        cancelToken: cancelToken,
        status: DownloadStatus.queued,
        progress: 0.0,
      );

      _downloadTasks[episodeId] = downloadTask;
      _downloadQueue.enqueue(downloadTask);

      await _updateEpisodeDownloadStatus(
        episodeId: episodeId,
        isDownloaded: false,
        downloadedPath: null,
        downloadProgress: 0.0,
      );

      _notifyStatusChange(episodeId, DownloadStatus.queued);
      Logger.info('节目已加入下载队列: $episodeId');
    } catch (e, stackTrace) {
      Logger.error('加入下载队列失败: $episodeId', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  void _processQueue() {
    while (_downloadQueue.canStartNewDownload) {
      final task = _downloadQueue.dequeue();
      if (task == null) break;

      _startDownloadFromQueue(task);
    }
  }

  Future<void> _startDownloadFromQueue(DownloadTask downloadTask) async {
    final episodeId = downloadTask.episodeId;

    try {
      final episode = await _isarService.isar.episodes.get(
        int.parse(episodeId),
      );
      if (episode == null) {
        throw AppException.unknown('Episode not found: $episodeId');
      }

      downloadTask.status = DownloadStatus.downloading;
      _notifyStatusChange(episodeId, DownloadStatus.downloading);

      final audioDir = await _fileStorageService.getAudioDirectory();
      final absoluteFilePath =
          '${audioDir.path}/${downloadTask.relativeFilePath.replaceFirst('audio/', '')}';

      final file = File(downloadTask.tempFilePath);
      final exists = await file.exists();
      int downloadedBytes = 0;

      if (exists) {
        downloadedBytes = await file.length();
        downloadTask.downloadedBytes = downloadedBytes;
      }

      final options = Options(
        receiveDataWhenStatusError: true,
        headers: downloadedBytes > 0
            ? {'Range': 'bytes=$downloadedBytes-'}
            : null,
      );

      await _dio.download(
        downloadTask.audioUrl,
        downloadTask.tempFilePath,
        cancelToken: downloadTask.cancelToken,
        options: options,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final totalProgress = downloadedBytes + received;
            final progress = totalProgress / total;
            downloadTask.progress = progress;
            downloadTask.downloadedBytes = totalProgress;
            downloadTask.totalBytes = total;

            _notifyProgressChange(episodeId, progress);
            _updateEpisodeDownloadProgress(episodeId, progress);
          }
        },
      );

      downloadTask.status = DownloadStatus.completed;
      downloadTask.progress = 1.0;

      final finalFile = File(absoluteFilePath);
      if (await finalFile.exists()) {
        await finalFile.delete();
      }

      await File(downloadTask.tempFilePath).rename(absoluteFilePath);

      await _updateEpisodeDownloadStatus(
        episodeId: episodeId,
        isDownloaded: true,
        downloadedPath: downloadTask.relativeFilePath,
        downloadProgress: 1.0,
      );

      _downloadQueue.markAsCompleted(episodeId);
      _notifyStatusChange(episodeId, DownloadStatus.completed);

      Logger.info('下载完成: $episodeId');

      _processQueue();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        _downloadTasks[episodeId]?.status = DownloadStatus.cancelled;
        _downloadQueue.removeActive(episodeId);
        _notifyStatusChange(episodeId, DownloadStatus.cancelled);
        Logger.info('下载已取消: $episodeId');
      } else {
        _downloadTasks[episodeId]?.status = DownloadStatus.failed;
        _downloadTasks[episodeId]?.errorMessage = e.message;
        _downloadQueue.markAsFailed(episodeId);
        _notifyStatusChange(episodeId, DownloadStatus.failed);
        Logger.error('下载失败: $episodeId', error: e);
      }
      _processQueue();
    } catch (e, stackTrace) {
      _downloadTasks[episodeId]?.status = DownloadStatus.failed;
      _downloadTasks[episodeId]?.errorMessage = e.toString();
      _downloadQueue.markAsFailed(episodeId);
      _notifyStatusChange(episodeId, DownloadStatus.failed);
      Logger.error('下载错误: $episodeId', error: e, stackTrace: stackTrace);
      _processQueue();
    }
  }

  Future<void> cancelQueuedDownload(String episodeId) async {
    _downloadQueue.removeQueued(episodeId);
    _downloadTasks.remove(episodeId);
    _disposeControllers(episodeId);

    await _updateEpisodeDownloadStatus(
      episodeId: episodeId,
      isDownloaded: false,
      downloadedPath: null,
      downloadProgress: 0.0,
    );

    Logger.info('已取消排队中的下载: $episodeId');
  }

  List<String> getQueuedDownloads() {
    return _downloadQueue.allQueued.map((task) => task.episodeId).toList();
  }

  int getQueueLength() {
    return _downloadQueue.queueLength;
  }

  int getActiveDownloadsCount() {
    return _downloadQueue.activeDownloadsCount;
  }

  Future<void> dispose() async {
    for (final episodeId in _downloadTasks.keys) {
      await cancelDownload(episodeId);
      _disposeControllers(episodeId);
    }
    _downloadTasks.clear();
    _downloadQueue.clear();
  }

  List<String> getActiveDownloads() {
    return _downloadTasks.entries
        .where((entry) => entry.value.status == DownloadStatus.downloading)
        .map((entry) => entry.key)
        .toList();
  }

  List<String> getPausedDownloads() {
    return _downloadTasks.entries
        .where((entry) => entry.value.status == DownloadStatus.paused)
        .map((entry) => entry.key)
        .toList();
  }
}
