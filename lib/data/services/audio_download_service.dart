import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:tinycast/data/models/episode_model.dart';
import 'package:tinycast/data/services/file_storage_service.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/core/utils/app_exception.dart';
import 'package:tinycast/data/services/image_cache_service.dart';

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

  /// 暂停请求标记：Dio 的取消回调晚于状态变更，用它区分「暂停」和「取消」。
  bool pauseRequested = false;
  final DateTime createdAt;
  final int priority;

  /// Completes when the task reaches a terminal state (completed, failed,
  /// cancelled or paused), so callers can await the queued transfer.
  final Completer<void> _completion = Completer<void>();
  double lastNotifiedProgress = -1;
  DateTime lastProgressNotifiedAt = DateTime.now();

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

  Future<void> get completion => _completion.future;

  void complete() {
    if (!_completion.isCompleted) _completion.complete();
  }
}

class DownloadQueue {
  final int maxConcurrentDownloads;
  final Queue<DownloadTask> _queue = Queue<DownloadTask>();
  final Map<String, DownloadTask> _activeDownloads = {};

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
  }

  void markAsFailed(String episodeId) {
    _activeDownloads.remove(episodeId);
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
  AudioDownloadService._({
    IsarService? isarService,
    FileStorageService? fileStorageService,
    ImageCacheService? imageCacheService,
    Dio? dio,
  }) : _isarService = isarService ?? IsarService.instance,
       _fileStorageService = fileStorageService ?? FileStorageService.instance,
       _imageCacheService = imageCacheService ?? ImageCacheService.instance,
       _dio = dio ?? _createDio();

  /// 测试注入入口：未注入的依赖仍指向生产单例。
  @visibleForTesting
  AudioDownloadService.forTesting({
    IsarService? isarService,
    FileStorageService? fileStorageService,
    ImageCacheService? imageCacheService,
    Dio? dio,
  }) : this._(
         isarService: isarService,
         fileStorageService: fileStorageService,
         imageCacheService: imageCacheService,
         dio: dio,
       );

  static final AudioDownloadService _instance = AudioDownloadService._();

  static AudioDownloadService get instance => _instance;

  final Map<String, DownloadTask> _downloadTasks = {};
  final Map<String, StreamController<DownloadStatus>> _statusControllers = {};
  final Map<String, StreamController<double>> _progressControllers = {};
  final DownloadQueue _downloadQueue = DownloadQueue(maxConcurrentDownloads: 3);

  // 进度信息保存在内存中的 DownloadTask 对象里
  // 只在下载完成或失败时才写入数据库

  late final StreamController<AudioDownloadEvent> _globalEventController =
      StreamController<AudioDownloadEvent>.broadcast();

  final Dio _dio;
  final FileStorageService _fileStorageService;
  final IsarService _isarService;
  final ImageCacheService _imageCacheService;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 30),
        sendTimeout: const Duration(seconds: 10),
        receiveDataWhenStatusError: true,
        maxRedirects: 5,
      ),
    );

    try {
      (dio.httpClientAdapter as dynamic).onHttpClientCreate =
          (HttpClient client) {
            client.autoUncompress = true;
            return client;
          };
    } catch (e) {
      Logger.warning('Dio HttpClient 配置失败: $e');
    }

    return dio;
  }

  Stream<AudioDownloadEvent> get globalEventStream =>
      _globalEventController.stream;

  void sendGlobalEvent({
    required String episodeId,
    required DownloadStatus status,
  }) {
    _globalEventController.add(
      AudioDownloadEvent(episodeId: episodeId, status: status),
    );
  }

  DownloadQueue get downloadQueue => _downloadQueue;

  Future<void> downloadEpisode(Episode episode) async {
    final episodeId = episode.id.toString();

    Logger.info('⬇️ 开始下载: ${episode.title} ($episodeId)');

    final existingTask = _downloadTasks[episodeId];
    if (existingTask != null) {
      switch (existingTask.status) {
        case DownloadStatus.downloading:
        case DownloadStatus.queued:
          Logger.info('⚠️ 下载已在进行中: $episodeId');
          await existingTask.completion;
          return;
        case DownloadStatus.paused:
          Logger.info('⏸️ 恢复暂停的下载: $episodeId');
          await resumeDownload(episodeId);
          return;
        case DownloadStatus.completed:
          Logger.info('✅ 已完成, 重新发送事件: $episodeId');
          _notifyStatusChange(episodeId, DownloadStatus.completed);
          _downloadTasks.remove(episodeId);
          return;
        case DownloadStatus.idle:
        case DownloadStatus.failed:
        case DownloadStatus.cancelled:
          break;
      }
    }

    try {
      final completedPath = await _findCompletedFile(episode);
      if (completedPath != null) {
        Logger.info('✅ 文件已存在, 标记完成: $episodeId');
        _downloadTasks.remove(episodeId);
        await _markCompletedFromExistingFile(episode, completedPath);
        return;
      }
    } catch (e) {
      Logger.warning('检查已存在文件失败: $e');
    }

    // Direct downloads share the queue so concurrent requests never exceed
    // the configured limit; await the task to preserve the synchronous
    // completion semantics callers rely on.
    final DownloadTask task;
    try {
      task = await _enqueueDownload(episode);
    } catch (e, stackTrace) {
      Logger.error(
        '加入下载队列失败: $episodeId',
        error: e,
        stackTrace: stackTrace,
      );
      return;
    }
    _processQueue();
    await task.completion;
  }

  Future<void> _markCompletedFromExistingFile(
    Episode episode,
    String completedPath,
  ) async {
    await _isarService.updateEpisodeDownloadStatus(
      episodeId: episode.id,
      isDownloaded: true,
      downloadedPath: completedPath,
      downloadProgress: 1.0,
    );
    _notifyStatusChange(episode.id.toString(), DownloadStatus.completed);
    await _downloadEpisodeArtwork(episode);
  }

  Future<void> _finalizeDownload(
    Episode episode,
    DownloadTask task,
  ) async {
    task.status = DownloadStatus.completed;
    task.progress = 1.0;

    final audioDir = await _fileStorageService.getAudioDirectory();
    if (!await audioDir.exists()) {
      throw AppException.storage('Audio directory not found');
    }
    final absoluteFilePath =
        '${audioDir.path}/${task.relativeFilePath.replaceFirst('audio/', '')}';
    final finalFile = File(absoluteFilePath);
    if (await finalFile.exists()) {
      await finalFile.delete();
    }
    await File(task.tempFilePath).rename(absoluteFilePath);

    final savedFile = File(absoluteFilePath);
    if (!await savedFile.exists()) {
      throw AppException.storage('Downloaded file missing: $absoluteFilePath');
    }
    final fileSize = await savedFile.length();
    Logger.info(
      '✅ 下载完成: ${task.episodeId} (${_formatFileSize(fileSize)})',
    );

    await _isarService.updateEpisodeDownloadStatus(
      episodeId: episode.id,
      isDownloaded: true,
      downloadedPath: task.relativeFilePath,
      downloadProgress: 1.0,
    );

    _downloadQueue.markAsCompleted(task.episodeId);
    _notifyStatusChange(task.episodeId, DownloadStatus.completed);
    await _downloadEpisodeArtwork(episode);
  }

  /// 把音频流写入任务对应的临时文件，支持 206 续传。
  Future<void> _transferToFile(DownloadTask task) async {
    final tempFile = File(task.tempFilePath);
    final existingBytes = await tempFile.exists() ? await tempFile.length() : 0;

    final response = await _dio.get<ResponseBody>(
      task.audioUrl,
      options: Options(
        responseType: ResponseType.stream,
        receiveDataWhenStatusError: true,
        headers: existingBytes > 0 ? {'Range': 'bytes=$existingBytes-'} : null,
      ),
      cancelToken: task.cancelToken,
    );

    final body = response.data;
    if (body == null) {
      throw AppException.unknown('Empty response body: ${task.audioUrl}');
    }

    final statusCode = response.statusCode ?? 0;
    final isPartial = statusCode == 206 && existingBytes > 0;
    if (statusCode != 200 && !isPartial) {
      await body.stream.listen(null).cancel();
      throw AppException.unknown(
        'Unexpected HTTP status $statusCode: ${task.audioUrl}',
      );
    }

    final startBytes = isPartial ? existingBytes : 0;
    final totalBytes = _resolveTotalBytes(response.headers, startBytes);

    if (!isPartial && existingBytes > 0) {
      Logger.info('🔄 服务器不支持断点续传, 重新下载: ${task.episodeId}');
    }

    task.downloadedBytes = startBytes;
    task.totalBytes = totalBytes;
    if (totalBytes != null && totalBytes > 0) {
      task.progress = (startBytes / totalBytes).clamp(0.0, 1.0);
    }

    final raf = await tempFile.open(
      mode: isPartial ? FileMode.append : FileMode.write,
    );
    var received = 0;
    var lastLoggedQuarter = -1;
    try {
      await for (final chunk in body.stream) {
        await raf.writeFrom(chunk);
        received += chunk.length;
        final downloadedBytes = startBytes + received;
        task.downloadedBytes = downloadedBytes;

        if (totalBytes != null && totalBytes > 0) {
          final progress = (downloadedBytes / totalBytes).clamp(0.0, 1.0);
          task.progress = progress;
          final quarter = (progress * 4).floor();
          if (quarter != lastLoggedQuarter && progress < 1.0) {
            lastLoggedQuarter = quarter;
            Logger.debug('📊 ${(progress * 100).toInt()}%');
          }
          // Chunks arrive far faster than the UI needs; keep the stream
          // responsive without flooding it with one event per chunk.
          final elapsed = DateTime.now().difference(
            task.lastProgressNotifiedAt,
          );
          if (progress >= 1.0 ||
              progress - task.lastNotifiedProgress >= 0.01 ||
              elapsed >= const Duration(milliseconds: 200)) {
            task.lastNotifiedProgress = progress;
            task.lastProgressNotifiedAt = DateTime.now();
            _notifyProgressChange(task.episodeId, progress);
          }
        }
      }
    } finally {
      await raf.close();
    }

    if (task.cancelToken.isCancelled) {
      throw DioException.requestCancelled(
        requestOptions: response.requestOptions,
        reason: task.cancelToken.cancelError?.message,
      );
    }

    if (totalBytes != null &&
        totalBytes > 0 &&
        startBytes + received < totalBytes) {
      throw AppException.unknown(
        'Incomplete download for ${task.episodeId}: '
        '${startBytes + received}/$totalBytes bytes',
      );
    }
  }

  int? _resolveTotalBytes(Headers headers, int startBytes) {
    final contentEncoding = headers.value(Headers.contentEncodingHeader);
    if (contentEncoding != null &&
        const ['gzip', 'deflate', 'compress'].contains(contentEncoding)) {
      return null;
    }

    final contentRange = headers.value('content-range');
    if (contentRange != null) {
      final total = int.tryParse(contentRange.split('/').last.trim());
      if (total != null && total > 0) return total;
    }

    final contentLength = int.tryParse(
      headers.value(Headers.contentLengthHeader) ?? '',
    );
    if (contentLength != null && contentLength >= 0) {
      return startBytes + contentLength;
    }
    return null;
  }

  Future<String?> _findCompletedFile(Episode episode) async {
    final storedPath = episode.downloadedPath;
    if (storedPath != null &&
        storedPath.isNotEmpty &&
        await _fileStorageService.fileExists(storedPath)) {
      return storedPath;
    }

    final fileName = _fileStorageService.generateAudioFileName(
      episode.id.toString(),
    );
    final audioDir = await _fileStorageService.getAudioDirectory();
    if (await File('${audioDir.path}/$fileName').exists()) {
      return 'audio/$fileName';
    }
    return null;
  }

  Future<void> _downloadEpisodeArtwork(Episode episode) async {
    if (episode.artworkUrl == null) return;
    try {
      final stored = await _isarService.isar.episodes.get(episode.id);
      final target = stored ?? episode;
      if (target.artworkUrl == null) return;
      Logger.info('🖼️ 开始下载 episode 封面图: ${target.title}');
      await _imageCacheService.downloadAndSaveEpisodeArtwork(target);
    } catch (e) {
      Logger.warning('⚠️ 封面图下载失败（不影响音频）: $e');
    }
  }

  void _handleDownloadFailure({
    required String episodeId,
    required DownloadTask? task,
    required Object error,
    required StackTrace stackTrace,
  }) {
    final isCurrent =
        task != null && identical(_downloadTasks[episodeId], task);
    final cancelled =
        task != null &&
        (task.cancelToken.isCancelled ||
            error is DioException && error.type == DioExceptionType.cancel);

    if (isCurrent) {
      if (cancelled) {
        if (task.pauseRequested) {
          if (task.status != DownloadStatus.paused) {
            task.status = DownloadStatus.paused;
            _notifyStatusChange(episodeId, DownloadStatus.paused);
          }
          Logger.info('⏸️ 下载已暂停: $episodeId');
        } else {
          task.status = DownloadStatus.cancelled;
          _notifyStatusChange(episodeId, DownloadStatus.cancelled);
          Logger.info('🚫 下载取消: $episodeId');
        }
      } else {
        task.status = DownloadStatus.failed;
        task.errorMessage = error is DioException
            ? (error.message ?? error.error?.toString() ?? 'Unknown error')
            : error.toString();
        _notifyStatusChange(episodeId, DownloadStatus.failed);
        Logger.error(
          '❌ 下载失败: $episodeId, ${task.errorMessage}',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (task != null) {
      if (cancelled || task.pauseRequested) {
        _downloadQueue.removeActive(episodeId);
      } else {
        _downloadQueue.markAsFailed(episodeId);
      }
      _processQueue();
    }
  }

  /// 终态任务不再保留，避免 `_downloadTasks` 随下载次数无限增长。
  void _pruneTerminalTask(String episodeId, DownloadTask? task) {
    if (task == null || !identical(_downloadTasks[episodeId], task)) return;
    if (task.status == DownloadStatus.completed ||
        task.status == DownloadStatus.failed ||
        task.status == DownloadStatus.cancelled) {
      _downloadTasks.remove(episodeId);
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
      // 先落状态再取消：Dio 的取消回调晚于 cancel()，标记让回调保留 paused。
      task.pauseRequested = true;
      task.status = DownloadStatus.paused;
      _notifyStatusChange(episodeId, DownloadStatus.paused);

      _downloadQueue.removeActive(episodeId);
      task.cancelToken.cancel('Download paused by user');
      _processQueue();

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

    task.pauseRequested = false;
    task.status = DownloadStatus.idle;
    Logger.info(
      '🔄 [RESUME] Status changed to idle synchronously for episode: $episodeId',
    );

    try {
      final episode = await _isarService.isar.episodes.get(
        int.parse(episodeId),
      );

      if (episode == null) {
        task.status = DownloadStatus.paused;
        _notifyStatusChange(episodeId, DownloadStatus.paused);
        throw AppException.unknown('Episode not found: $episodeId');
      }

      await downloadEpisode(episode);
    } catch (e, stackTrace) {
      if (identical(_downloadTasks[episodeId], task) &&
          (task.status == DownloadStatus.idle ||
              task.status == DownloadStatus.paused)) {
        task.status = DownloadStatus.paused;
        _notifyStatusChange(episodeId, DownloadStatus.paused);
      }
      Logger.error(
        'Error resuming download for episode: $episodeId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> downloadEpisodeById(int episodeId) async {
    final episode = await _isarService.isar.episodes.get(episodeId);

    if (episode == null) {
      throw AppException.unknown('Episode not found: $episodeId');
    }

    await downloadEpisode(episode);
  }

  Future<void> cancelDownload(String episodeId) async {
    final task = _downloadTasks[episodeId];
    if (task == null) {
      Logger.warning('No download task found for episode: $episodeId');
      return;
    }

    try {
      // 取消不是暂停：先移除暂停意图，避免取消回调把状态写回 paused。
      task.pauseRequested = false;
      task.status = DownloadStatus.cancelled;
      _downloadQueue.removeQueued(episodeId);
      _downloadQueue.removeActive(episodeId);

      if (!task.cancelToken.isCancelled) {
        task.cancelToken.cancel('Download cancelled by user');
      }

      if (task.tempFilePath.isNotEmpty) {
        final tempFile = File(task.tempFilePath);
        if (await tempFile.exists()) {
          await tempFile.delete();
          Logger.info('Temporary file deleted for episode: $episodeId');
        }
      }

      await _isarService.updateEpisodeDownloadStatus(
        episodeId: int.parse(episodeId),
        isDownloaded: false,
        downloadedPath: null,
        downloadProgress: 0.0,
      );

      _notifyStatusChange(episodeId, DownloadStatus.cancelled);
      _downloadTasks.remove(episodeId);
      task.complete();
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

      final task = _downloadTasks.remove(episodeId);
      if (task != null) {
        task.pauseRequested = false;
        task.status = DownloadStatus.cancelled;
        _downloadQueue.removeQueued(episodeId);
        _downloadQueue.removeActive(episodeId);
        if (!task.cancelToken.isCancelled) {
          task.cancelToken.cancel('Downloaded episode deleted');
        }
        if (task.tempFilePath.isNotEmpty) {
          final tempFile = File(task.tempFilePath);
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
        task.complete();
        _processQueue();
      }

      if (episode.downloadedPath != null) {
        await _fileStorageService.deleteFileSafely(
          episode.downloadedPath!,
          context: 'episode: $episodeId',
        );
      }

      await _isarService.updateEpisodeDownloadStatus(
        episodeId: int.parse(episodeId),
        isDownloaded: false,
        downloadedPath: null,
        downloadProgress: 0.0,
      );

      _disposeControllers(episodeId);

      _globalEventController.add(
        AudioDownloadEvent(
          episodeId: episodeId,
          status: DownloadStatus.cancelled,
        ),
      );

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

  Future<bool> hasDownloadedEpisodesForPodcast(int podcastId) async {
    final count = await _isarService.isar.episodes
        .filter()
        .podcastIdEqualTo(podcastId)
        .isDownloadedEqualTo(true)
        .count();
    return count > 0;
  }

  /// 一次性返回所有存在已下载节目的播客 ID，避免列表页逐条查询。
  Future<Set<int>> getPodcastIdsWithDownloadedEpisodes() async {
    final episodes = await _isarService.isar.episodes
        .filter()
        .isDownloadedEqualTo(true)
        .findAll();
    return episodes.map((episode) => episode.podcastId).toSet();
  }

  Future<void> removeAllDownloadsForPodcast(int podcastId) async {
    final downloadedEpisodes = await _isarService.isar.episodes
        .filter()
        .podcastIdEqualTo(podcastId)
        .isDownloadedEqualTo(true)
        .findAll();

    if (downloadedEpisodes.isEmpty) {
      return;
    }

    int clearedCount = 0;
    for (final episode in downloadedEpisodes) {
      final path = episode.downloadedPath;
      if (path != null && path.isNotEmpty) {
        await _fileStorageService.deleteFileSafely(
          path,
          context: 'podcast: $podcastId episode: ${episode.id}',
        );
        try {
          final fullPath = await _fileStorageService.getFullFilePath(path);
          if (await File(fullPath).exists()) {
            Logger.warning(
              '跳过 DB 清理，文件仍存在: episodeId=${episode.id}, path=$path',
            );
            continue;
          }
        } catch (e) {
          Logger.warning('检查下载文件是否仍存在失败: $path, $e');
        }
      }

      await _isarService.updateEpisodeDownloadStatus(
        episodeId: episode.id,
        isDownloaded: false,
        downloadedPath: null,
        downloadProgress: 0.0,
      );
      clearedCount++;
    }

    Logger.info(
      '已移除播客 $podcastId 的 $clearedCount/${downloadedEpisodes.length} 个下载',
    );
  }

  Future<List<int>> getEpisodeIdsByPodcast(int podcastId) async {
    final episodes = await _isarService.isar.episodes
        .filter()
        .podcastIdEqualTo(podcastId)
        .findAll();
    return episodes.map((e) => e.id).toList();
  }

  Future<void> unfollowPodcast(int podcastId) async {
    final episodes = await _isarService.isar.episodes
        .filter()
        .podcastIdEqualTo(podcastId)
        .findAll();

    final episodeIds = episodes.map((episode) => episode.id.toString()).toSet();
    final taskEpisodeIds = _downloadTasks.keys
        .where(episodeIds.contains)
        .toList();

    for (final episodeId in taskEpisodeIds) {
      final task = _downloadTasks.remove(episodeId);
      if (task == null) continue;

      _downloadQueue.removeQueued(episodeId);
      _downloadQueue.removeActive(episodeId);
      task.pauseRequested = false;
      task.status = DownloadStatus.cancelled;
      if (!task.cancelToken.isCancelled) {
        task.cancelToken.cancel('Podcast unfollowed');
      }

      if (task.tempFilePath.isNotEmpty) {
        final tempFile = File(task.tempFilePath);
        if (await tempFile.exists()) {
          try {
            await tempFile.delete();
          } catch (e) {
            Logger.warning('删除临时下载文件失败: ${tempFile.path}, $e');
          }
        }
      }

      _notifyStatusChange(episodeId, DownloadStatus.cancelled);
      task.complete();
      _disposeControllers(episodeId);
    }

    try {
      final tempDir = await _fileStorageService.getTemporaryDirectory();
      for (final episode in episodes) {
        final tempFile = File(
          '${tempDir.path}/${_fileStorageService.generateAudioFileName(episode.id.toString())}',
        );
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    } catch (e) {
      Logger.warning('清理播客 $podcastId 的临时下载文件失败: $e');
    }

    final pathsToDelete = <String>[];
    for (final episode in episodes) {
      if (episode.downloadedPath != null) {
        pathsToDelete.add(episode.downloadedPath!);
      }
      if (episode.artworkPath != null) {
        pathsToDelete.add(episode.artworkPath!);
      }
    }

    if (pathsToDelete.isNotEmpty) {
      final deletedCount = await _fileStorageService.deleteFilesSafely(
        pathsToDelete,
        context: 'unfollow podcast: $podcastId',
      );
      Logger.info('成功删除 $deletedCount/${pathsToDelete.length} 个文件');
    }

    if (taskEpisodeIds.isNotEmpty) {
      _processQueue();
    }

    Logger.info('已清理播客 $podcastId 的所有文件');
  }

  void _notifyStatusChange(String episodeId, DownloadStatus status) {
    final controller = _statusControllers[episodeId];
    if (controller != null && !controller.isClosed) {
      controller.add(status);
    }

    if (!_globalEventController.isClosed) {
      _globalEventController.add(
        AudioDownloadEvent(episodeId: episodeId, status: status),
      );
    }
  }

  void _notifyProgressChange(String episodeId, double progress) {
    final controller = _progressControllers[episodeId];
    if (controller != null && !controller.isClosed) {
      controller.add(progress);
    }

    if (!_globalEventController.isClosed) {
      _globalEventController.add(
        AudioDownloadEvent(
          episodeId: episodeId,
          status: DownloadStatus.downloading,
          progress: progress,
        ),
      );
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
    Logger.info(
      '📦 [DEBUG] ====== Starting podcast download: $podcastId ======',
    );
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
        Logger.debug(
          '📦 [DEBUG] Episode ${i + 1}/${episodes.length}: ID=${ep.id}, Title="${ep.title}"',
        );
      }

      await downloadEpisodesBatch(episodes);
    } catch (e, stackTrace) {
      Logger.error(
        '❌ [DEBUG] Failed to download podcast episodes: $podcastId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<DownloadTask> _enqueueDownload(Episode episode) async {
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

      Logger.debug(
        '✅ [DEBUG] Task enqueued, queue size: ${_downloadQueue.queueLength}',
      );

      // 优化：入队时不写数据库，只更新内存状态
      // 避免在订阅后立即占用写锁，导致 Library 页面查询被阻塞
      _notifyStatusChange(episodeId, DownloadStatus.queued);
      Logger.info('✅ [DEBUG] Episode added to queue successfully: $episodeId');
      return downloadTask;
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
    Logger.debug(
      '   - Active downloads: ${_downloadQueue.activeDownloadsCount}',
    );
    Logger.debug(
      '   - Max concurrent: ${_downloadQueue.maxConcurrentDownloads}',
    );

    int processedCount = 0;

    while (_downloadQueue.canStartNewDownload) {
      final task = _downloadQueue.dequeue();
      if (task == null) {
        Logger.warning('🔄 [DEBUG] No more tasks in queue');
        break;
      }

      processedCount++;
      Logger.info(
        '🔄 [DEBUG] Dequeued task #$processedCount: ${task.episodeId} (status: ${task.status})',
      );

      _startDownloadFromQueue(task);
    }

    if (processedCount == 0) {
      Logger.warning('🔄 [DEBUG] No tasks were processed from queue!');
      if (_downloadQueue.queueLength > 0) {
        Logger.error(
          '🔄 [DEBUG] ERROR: Queue has ${_downloadQueue.queueLength} items but cannot start new downloads',
        );
        Logger.error(
          '🔄 [DEBUG] This might mean max concurrent downloads reached or queue logic issue',
        );
      }
    } else {
      Logger.info(
        '✅ [DEBUG] Successfully started $processedCount download(s) from queue',
      );
    }
  }

  Future<void> _startDownloadFromQueue(DownloadTask downloadTask) async {
    final episodeId = downloadTask.episodeId;

    Logger.info(
      '⬇️ [DEBUG] ====== Starting queued download for episode: $episodeId ======',
    );

    try {
      final episode = await _isarService.isar.episodes.get(
        int.parse(episodeId),
      );

      if (episode == null) {
        throw AppException.unknown('Episode not found: $episodeId');
      }

      if (!identical(_downloadTasks[episodeId], downloadTask) ||
          downloadTask.cancelToken.isCancelled) {
        Logger.info(
          '🛑 [DEBUG] Download task was cancelled before start: $episodeId',
        );
        _downloadQueue.removeActive(episodeId);
        _processQueue();
        return;
      }

      downloadTask.pauseRequested = false;
      downloadTask.status = DownloadStatus.downloading;
      _notifyStatusChange(episodeId, DownloadStatus.downloading);

      final completedPath = await _findCompletedFile(episode);
      if (completedPath != null) {
        downloadTask.status = DownloadStatus.completed;
        downloadTask.progress = 1.0;
        await _isarService.updateEpisodeDownloadStatus(
          episodeId: episode.id,
          isDownloaded: true,
          downloadedPath: completedPath,
          downloadProgress: 1.0,
        );
        _downloadQueue.markAsCompleted(episodeId);
        _notifyStatusChange(episodeId, DownloadStatus.completed);
        _processQueue();
        return;
      }

      await _transferToFile(downloadTask);
      await _finalizeDownload(episode, downloadTask);
      _processQueue();

      Logger.info('下载完成: $episodeId');
    } catch (e, stackTrace) {
      _handleDownloadFailure(
        episodeId: episodeId,
        task: downloadTask,
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      downloadTask.complete();
      _pruneTerminalTask(episodeId, downloadTask);
    }
  }

  Future<void> cancelQueuedDownload(String episodeId) async {
    final task = _downloadTasks.remove(episodeId);
    _downloadQueue.removeQueued(episodeId);
    _disposeControllers(episodeId);
    task?.complete();

    await _isarService.updateEpisodeDownloadStatus(
      episodeId: int.parse(episodeId),
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
    // cancelDownload 会从 _downloadTasks 移除条目，先复制 key 再遍历。
    final episodeIds = _downloadTasks.keys.toList();
    for (final episodeId in episodeIds) {
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
