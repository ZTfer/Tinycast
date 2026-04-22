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

  // 进度信息保存在内存中的 DownloadTask 对象里
  // 只在下载完成或失败时才写入数据库

  /// 正在下载中的 episode ID 集合（防止并发重复下载）
  final Set<String> _activeDownloads = {};

  late final StreamController<AudioDownloadEvent> _globalEventController =
      StreamController<AudioDownloadEvent>.broadcast();

  late final Dio _dio = _createDio();
  final FileStorageService _fileStorageService = FileStorageService.instance;
  final IsarService _isarService = IsarService.instance;
  final ImageCacheService _imageCacheService = ImageCacheService.instance;

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

  DownloadQueue get downloadQueue => _downloadQueue;

  Future<void> downloadEpisode(Episode episode) async {
    final episodeId = episode.id.toString();

    Logger.info('⬇️ 开始下载: ${episode.title} ($episodeId)');

    // 防护：检查目标文件是否已存在
    try {
      final audioDir = await _fileStorageService.getAudioDirectory();
      final fileName = _fileStorageService.generateAudioFileName(episodeId);
      final destinationFile = File('${audioDir.path}/$fileName');
      if (await destinationFile.exists()) {
        Logger.info('✅ 文件已存在, 标记完成: $episodeId');
        _downloadTasks[episodeId] = DownloadTask(
          episodeId: episodeId,
          audioUrl: episode.audioUrl,
          relativeFilePath: 'audio/$fileName',
          tempFilePath: '',
          cancelToken: CancelToken(),
          status: DownloadStatus.completed,
          progress: 1.0,
        );
        await _updateEpisodeDownloadStatus(
          episodeId: episodeId,
          isDownloaded: true,
          downloadedPath: 'audio/$fileName',
          downloadProgress: 1.0,
        );
        _notifyStatusChange(episodeId, DownloadStatus.completed);

        try {
          final episode = await _isarService.isar.episodes.get(
            int.parse(episodeId),
          );
          if (episode != null && episode.artworkUrl != null) {
            Logger.info('🖼️ 开始下载 episode 封面图: ${episode.title}');
            await _imageCacheService.downloadAndSaveEpisodeArtwork(episode);
          }
        } catch (e) {
          Logger.warning('⚠️ 封面图下载失败（不影响音频）: $e');
        }
        return;
      }
    } catch (e) {
      Logger.warning('检查已存在文件失败: $e');
    }

    // 防护：检查现有任务状态
    if (_downloadTasks.containsKey(episodeId)) {
      final existingTask = _downloadTasks[episodeId]!;
      if (existingTask.status == DownloadStatus.downloading ||
          existingTask.status == DownloadStatus.queued) {
        Logger.info('⚠️ 下载已在进行中: $episodeId');
        return;
      }
      if (existingTask.status == DownloadStatus.paused) {
        Logger.info('⏸️ 恢复暂停的下载: $episodeId');
        await resumeDownload(episodeId);
        return;
      }
      if (existingTask.status == DownloadStatus.completed) {
        Logger.info('✅ 已完成, 重新发送事件: $episodeId');
        _notifyStatusChange(episodeId, DownloadStatus.completed);
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

      if (!await audioDir.exists()) {
        throw AppException.storage('Audio directory not found');
      }

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
      int downloadedBytes = 0;

      if (await file.exists()) {
        downloadedBytes = await file.length();
        downloadTask.downloadedBytes = downloadedBytes;
        Logger.info('🔄 发现临时文件, 断点续传: ${_formatFileSize(downloadedBytes)}');
      }

      final options = Options(
        receiveDataWhenStatusError: true,
        headers: downloadedBytes > 0
            ? {'Range': 'bytes=$downloadedBytes-'}
            : null,
      );

      Logger.info('🌐 开始下载: ${episode.audioUrl}');

      DateTime startTime = DateTime.now();

      try {
        await _dio.download(
          episode.audioUrl,
          tempFilePath,
          cancelToken: cancelToken,
          options: options,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final totalProgress = downloadedBytes + received;
              final progress = totalProgress / total;

              if ((progress * 100).toInt() % 25 == 0 &&
                  progress > 0 &&
                  progress < 1.0) {
                Logger.debug('📊 ${(progress * 100).toInt()}%');
              }

              downloadTask.progress = progress;
              downloadTask.downloadedBytes = totalProgress;
              downloadTask.totalBytes = total;

              _notifyProgressChange(episodeId, progress);
            }
          },
        );
      } on DioException catch (e) {
        Logger.error(
          '🔴 下载失败 $episodeId: type=${e.type.name}, msg=${e.message ?? e.error}',
        );
        rethrow;
      }

      final duration = DateTime.now().difference(startTime);

      downloadTask.status = DownloadStatus.completed;
      downloadTask.progress = 1.0;

      final finalFile = File(absoluteFilePath);
      if (await finalFile.exists()) {
        await finalFile.delete();
      }

      await File(tempFilePath).rename(absoluteFilePath);

      final savedFile = File(absoluteFilePath);
      if (await savedFile.exists()) {
        final fileSize = await savedFile.length();
        Logger.info(
          '✅ 下载完成: $episodeId (${_formatFileSize(fileSize)}, ${duration.inSeconds}s)',
        );
      } else {
        Logger.error('❌ 文件保存失败: $absoluteFilePath');
      }

      await _updateEpisodeDownloadStatus(
        episodeId: episodeId,
        isDownloaded: true,
        downloadedPath: relativeFilePath,
        downloadProgress: 1.0,
      );

      _notifyStatusChange(episodeId, DownloadStatus.completed);

      try {
        final episode = await _isarService.isar.episodes.get(
          int.parse(episodeId),
        );
        if (episode != null && episode.artworkUrl != null) {
          Logger.info('🖼️ 开始下载 episode 封面图: ${episode.title}');
          await _imageCacheService.downloadAndSaveEpisodeArtwork(episode);
        }
      } catch (e) {
        Logger.warning('⚠️ 封面图下载失败（不影响音频）: $e');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        _downloadTasks[episodeId]?.status = DownloadStatus.cancelled;
        _notifyStatusChange(episodeId, DownloadStatus.cancelled);
        Logger.info('🚫 下载取消: $episodeId');
      } else {
        _downloadTasks[episodeId]?.status = DownloadStatus.failed;
        _downloadTasks[episodeId]?.errorMessage =
            e.message ?? e.error?.toString() ?? 'Unknown error';
        _notifyStatusChange(episodeId, DownloadStatus.failed);
        Logger.error('❌ 下载失败: $episodeId, ${e.message ?? e.error}');
      }
    } catch (e, stackTrace) {
      _downloadTasks[episodeId]?.status = DownloadStatus.failed;
      _downloadTasks[episodeId]?.errorMessage = e.toString();
      _notifyStatusChange(episodeId, DownloadStatus.failed);
      Logger.error('💥 下载异常: $episodeId, $e', error: e, stackTrace: stackTrace);
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
      if (task.status != DownloadStatus.downloading &&
          task.status != DownloadStatus.completed &&
          task.status != DownloadStatus.queued) {
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
    final idStr = episodeId.toString();

    if (_activeDownloads.contains(idStr)) {
      return;
    }
    _activeDownloads.add(idStr);

    try {
      if (_downloadTasks.containsKey(idStr)) {
        final existingTask = _downloadTasks[idStr]!;
        if (existingTask.status == DownloadStatus.downloading ||
            existingTask.status == DownloadStatus.queued) {
          return;
        }
        if (existingTask.status == DownloadStatus.completed) {
          _notifyStatusChange(idStr, DownloadStatus.completed);
          return;
        }
      }

      final episode = await _isarService.isar.episodes.get(episodeId);

      if (episode == null) {
        throw AppException.unknown('Episode not found: $episodeId');
      }

      // 文件已存在则直接完成
      final audioDir = await _fileStorageService.getAudioDirectory();
      final fileName = _fileStorageService.generateAudioFileName(idStr);
      final destinationFile = File('${audioDir.path}/$fileName');
      if (await destinationFile.exists()) {
        Logger.info('✅ 文件已存在, 标记完成: $idStr');
        _notifyStatusChange(idStr, DownloadStatus.completed);
        return;
      }

      await downloadEpisode(episode);
    } catch (e, stackTrace) {
      Logger.error(
        'Error downloading episode by ID: $episodeId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _activeDownloads.remove(idStr);
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
        await _fileStorageService.deleteFileSafely(
          episode.downloadedPath!,
          context: 'episode: $episodeId',
        );
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

  Future<bool> hasDownloadedEpisodesForPodcast(int podcastId) async {
    final count = await _isarService.isar.episodes
        .filter()
        .podcastIdEqualTo(podcastId)
        .isDownloadedEqualTo(true)
        .count();
    return count > 0;
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

    // 先收集要删除的文件路径
    final pathsToDelete = downloadedEpisodes
        .map((e) => e.downloadedPath)
        .whereType<String>()
        .toList();

    // 先删除文件
    int deletedCount = 0;
    if (pathsToDelete.isNotEmpty) {
      deletedCount = await _fileStorageService.deleteFilesSafely(
        pathsToDelete,
        context: 'podcast: $podcastId',
      );
      Logger.info('成功删除 $deletedCount/${pathsToDelete.length} 个文件');
    }

    // 文件删除成功后，更新数据库状态
    if (deletedCount > 0) {
      for (final episode in downloadedEpisodes) {
        await _updateEpisodeDownloadStatus(
          episodeId: episode.id.toString(),
          isDownloaded: false,
          downloadedPath: null,
          downloadProgress: 0.0,
        );
      }
    }

    Logger.info('已移除播客 $podcastId 的 ${downloadedEpisodes.length} 个下载');
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

    Logger.info('已清理播客 $podcastId 的所有文件');
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

      Logger.debug(
        '✅ [DEBUG] Task enqueued, queue size: ${_downloadQueue.queueLength}',
      );

      // 优化：入队时不写数据库，只更新内存状态
      // 避免在订阅后立即占用写锁，导致 Library 页面查询被阻塞
      // await _updateEpisodeDownloadStatus(
      //   episodeId: episodeId,
      //   isDownloaded: false,
      //   downloadedPath: null,
      //   downloadProgress: 0.0,
      // );

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
      Logger.debug('⬇️ [DEBUG] Fetching episode from database...');
      final episode = await _isarService.isar.episodes.get(
        int.parse(episodeId),
      );

      if (episode == null) {
        Logger.error(
          '❌ [DEBUG] ERROR: Episode not found in database! ID: $episodeId',
        );
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
