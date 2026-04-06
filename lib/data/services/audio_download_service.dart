import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:isar_community/isar.dart';
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

class AudioDownloadEvent {
  final String episodeId;
  final DownloadStatus status;
  final double? progress;
  final DateTime timestamp;

  AudioDownloadEvent({
    required this.episodeId,
    required this.status,
    this.progress,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AudioDownloadService {
  AudioDownloadService._();

  static final AudioDownloadService _instance = AudioDownloadService._();

  static AudioDownloadService get instance => _instance;

  final Map<String, DownloadTask> _downloadTasks = {};
  final Map<String, StreamController<DownloadStatus>> _statusControllers = {};
  final Map<String, StreamController<double>> _progressControllers = {};
  final DownloadQueue _downloadQueue = DownloadQueue(maxConcurrentDownloads: 3);

  late final StreamController<AudioDownloadEvent> _globalEventController =
      StreamController<AudioDownloadEvent>.broadcast();

  final Dio _dio = Dio();
  final FileStorageService _fileStorageService = FileStorageService.instance;
  final IsarService _isarService = IsarService.instance;

  Stream<AudioDownloadEvent> get globalEventStream =>
      _globalEventController.stream;

  DownloadQueue get downloadQueue => _downloadQueue;

  Future<void> downloadEpisode(Episode episode) async {
    final episodeId = episode.id.toString();
    
    Logger.debug('⬇️ [DEBUG] ====== Starting download for episode: $episodeId ======');
    Logger.debug('⬇️ [DEBUG] Episode title: ${episode.title}');
    Logger.debug('⬇️ [DEBUG] Audio URL: ${episode.audioUrl}');
    Logger.debug('⬇️ [DEBUG] Podcast ID: ${episode.podcastId}');

    if (_downloadTasks.containsKey(episodeId)) {
      final existingTask = _downloadTasks[episodeId]!;
      if (existingTask.status == DownloadStatus.downloading) {
        Logger.warning('⚠️ [DEBUG] Download already in progress for episode: $episodeId');
        return;
      }
      if (existingTask.status == DownloadStatus.paused) {
        Logger.info('⏸️ [DEBUG] Resuming paused download for episode: $episodeId');
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

      Logger.debug('📁 [DEBUG] File paths:');
      Logger.debug('   - Audio directory: ${audioDir.path}');
      Logger.debug('   - Temp directory: ${tempDir.path}');
      Logger.debug('   - File name: $fileName');
      Logger.debug('   - Relative path: $relativeFilePath');
      Logger.debug('   - Absolute path: $absoluteFilePath');
      Logger.debug('   - Temp path: $tempFilePath');

      // 检查音频目录是否存在
      if (!await audioDir.exists()) {
        Logger.error('❌ [DEBUG] Audio directory does not exist!');
        throw AppException.storage('Audio directory not found');
      }
      
      Logger.debug('✅ [DEBUG] Audio directory exists and is ready');

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
      
      Logger.info('📥 [DEBUG] Download task created, updating database...');

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
        Logger.info('🔄 [DEBUG] Found existing temp file, size: ${_formatFileSize(downloadedBytes)}');
      } else {
        Logger.debug('🆕 [DEBUG] No existing temp file, starting fresh download');
      }

      final options = Options(
        receiveDataWhenStatusError: true,
        headers: downloadedBytes > 0
            ? {'Range': 'bytes=$downloadedBytes-'}
            : null,
      );
      
      if (downloadedBytes > 0) {
        Logger.debug('🔄 [DEBUG] Using Range header for resume: bytes=$downloadedBytes-');
      }

      Logger.info('🌐 [DEBUG] Starting HTTP download from: ${episode.audioUrl}');
      DateTime startTime = DateTime.now();

      await _dio.download(
        episode.audioUrl,
        tempFilePath,
        cancelToken: cancelToken,
        options: options,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final totalProgress = downloadedBytes + received;
            final progress = totalProgress / total;
            
            // 每10%记录一次进度
            if ((progress * 100).toInt() % 10 == 0 && (progress * 100).toInt() != 0) {
              Logger.debug('📊 [DEBUG] Progress: ${(progress * 100).toStringAsFixed(1)}% (${_formatFileSize(totalProgress)} / ${_formatFileSize(total)})');
            }
            
            downloadTask.progress = progress;
            downloadTask.downloadedBytes = totalProgress;
            downloadTask.totalBytes = total;

            _notifyProgressChange(episodeId, progress);
            _updateEpisodeDownloadProgress(episodeId, progress);
          } else {
            Logger.debug('📊 [DEBUG] Received: ${_formatFileSize(received)}, Total: unknown');
          }
        },
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      Logger.info('✅ [DEBUG] Download completed successfully!');
      Logger.info('⏱️ [DEBUG] Download duration: ${duration.inSeconds}s');

      downloadTask.status = DownloadStatus.completed;
      downloadTask.progress = 1.0;

      final finalFile = File(absoluteFilePath);
      if (await finalFile.exists()) {
        await finalFile.delete();
        Logger.debug('🗑️ [DEBUG] Deleted existing file at: $absoluteFilePath');
      }

      await File(tempFilePath).rename(absoluteFilePath);

      // 验证文件是否成功保存
      final savedFile = File(absoluteFilePath);
      if (await savedFile.exists()) {
        final fileSize = await savedFile.length();
        Logger.info('💾 [DEBUG] File saved successfully:');
        Logger.info('   - Path: $absoluteFilePath');
        Logger.info('   - Size: ${_formatFileSize(fileSize)}');
        Logger.info('   - Relative path: $relativeFilePath');
      } else {
        Logger.error('❌ [DEBUG] ERROR: File was not saved to destination!');
      }

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

    if (!_globalEventController.isClosed) {
      _globalEventController.add(AudioDownloadEvent(
        episodeId: episodeId,
        status: status,
      ));
    }
  }

  void _notifyProgressChange(String episodeId, double progress) {
    final controller = _progressControllers[episodeId];
    if (controller != null && !controller.isClosed) {
      controller.add(progress);
    }

    if (!_globalEventController.isClosed) {
      _globalEventController.add(AudioDownloadEvent(
        episodeId: episodeId,
        status: DownloadStatus.downloading,
        progress: progress,
      ));
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
    Logger.info('📦 [DEBUG] ====== Starting podcast download: $podcastId ======');
    if (limit != null) {
      Logger.info('📦 [DEBUG] Download limit: $limit episodes');
    }

    try {
      final query = _isarService.isar.episodes
          .filter()
          .podcastIdEqualTo(podcastId)
          .sortByPubDateDesc();

      final List<Episode> episodes;
      if (limit != null) {
        episodes = await query.limit(limit).findAll();
      } else {
        episodes = await query.findAll();
      }

      Logger.info('📦 [DEBUG] Episodes to download: ${episodes.length}');

      // 列出要下载的节目信息
      for (var i = 0; i < episodes.length; i++) {
        final ep = episodes[i];
        Logger.debug('📦 [DEBUG] Episode ${i + 1}/${episodes.length}: ID=${ep.id}, Title="${ep.title}"');
      }

      await downloadEpisodesBatch(episodes);
    } catch (e, stackTrace) {
      Logger.error('❌ [DEBUG] Failed to download podcast episodes: $podcastId', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _enqueueDownload(Episode episode) async {
    final episodeId = episode.id.toString();
    
    Logger.info('📥 [DEBUG] Enqueuing download for episode: $episodeId');
    Logger.debug('   - Title: ${episode.title}');
    Logger.debug('   - Audio URL: ${episode.audioUrl}');

    try {
      final tempDir = await _fileStorageService.getTemporaryDirectory();

      final fileName = _fileStorageService.generateAudioFileName(episodeId);
      final relativeFilePath = 'audio/$fileName';
      final tempFilePath = '${tempDir.path}/$fileName';

      Logger.debug('   - File name: $fileName');
      Logger.debug('   - Relative path: $relativeFilePath');
      Logger.debug('   - Temp path: $tempFilePath');

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

      Logger.debug('✅ [DEBUG] Task enqueued, queue size: ${_downloadQueue.queueLength}');

      await _updateEpisodeDownloadStatus(
        episodeId: episodeId,
        isDownloaded: false,
        downloadedPath: null,
        downloadProgress: 0.0,
      );

      _notifyStatusChange(episodeId, DownloadStatus.queued);
      Logger.info('✅ [DEBUG] Episode added to queue successfully: $episodeId');
    } catch (e, stackTrace) {
      Logger.error('加入下载队列失败: $episodeId', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  void _processQueue() {
    Logger.info('🔄 [DEBUG] ====== Processing download queue ======');
    Logger.debug('🔄 [DEBUG] Queue status:');
    Logger.debug('   - Can start new: ${_downloadQueue.canStartNewDownload}');
    Logger.debug('   - Queue length: ${_downloadQueue.queueLength}');
    Logger.debug('   - Active downloads: ${_downloadQueue.activeDownloadsCount}');
    Logger.debug('   - Max concurrent: ${_downloadQueue.maxConcurrentDownloads}');
    
    int processedCount = 0;
    
    while (_downloadQueue.canStartNewDownload) {
      final task = _downloadQueue.dequeue();
      if (task == null) {
        Logger.warning('🔄 [DEBUG] No more tasks in queue');
        break;
      }
      
      processedCount++;
      Logger.info('🔄 [DEBUG] Dequeued task #$processedCount: ${task.episodeId} (status: ${task.status})');
      
      _startDownloadFromQueue(task);
    }
    
    if (processedCount == 0) {
      Logger.warning('🔄 [DEBUG] No tasks were processed from queue!');
      if (_downloadQueue.queueLength > 0) {
        Logger.error('🔄 [DEBUG] ERROR: Queue has ${_downloadQueue.queueLength} items but cannot start new downloads');
        Logger.error('🔄 [DEBUG] This might mean max concurrent downloads reached or queue logic issue');
      }
    } else {
      Logger.info('✅ [DEBUG] Successfully started $processedCount download(s) from queue');
    }
  }

  Future<void> _startDownloadFromQueue(DownloadTask downloadTask) async {
    final episodeId = downloadTask.episodeId;
    
    Logger.info('⬇️ [DEBUG] ====== Starting queued download for episode: $episodeId ======');

    try {
      Logger.debug('⬇️ [DEBUG] Fetching episode from database...');
      final episode = await _isarService.isar.episodes.get(
        int.parse(episodeId),
      );
      
      if (episode == null) {
        Logger.error('❌ [DEBUG] ERROR: Episode not found in database! ID: $episodeId');
        throw AppException.unknown('Episode not found: $episodeId');
      }
      
      Logger.debug('✅ [DEBUG] Episode found: ${episode.title}');

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
    await _globalEventController.close();
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}
