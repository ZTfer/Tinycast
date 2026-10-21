import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:tinycast/core/utils/app_exception.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/models/episode_model.dart';
import 'package:tinycast/data/models/podcast_model.dart';
import 'package:tinycast/data/services/file_storage_service.dart';

class ImageCacheService {
  ImageCacheService._();

  static final ImageCacheService _instance = ImageCacheService._();

  static ImageCacheService get instance => _instance;

  final FileStorageService _fileStorageService = FileStorageService.instance;
  final Dio _dio = Dio();
  final IsarService _isarService = IsarService.instance;

  /// 只更新数据库中的 artworkPath 字段。
  ///
  /// 调用方可能持有过期的实体快照，直接 `put(episode)` 会用旧字段覆盖
  /// 数据库中较新的标题、播放进度等数据，因此这里始终先读取最新记录。
  @visibleForTesting
  static Future<void> persistEpisodeArtworkPath(
    Isar isar,
    int episodeId,
    String artworkPath,
  ) async {
    await isar.writeTxn(() async {
      final stored = await isar.episodes.get(episodeId);
      if (stored == null) return;
      stored.artworkPath = artworkPath;
      await isar.episodes.put(stored);
    });
  }

  @visibleForTesting
  static Future<void> persistPodcastArtworkPath(
    Isar isar,
    int podcastId,
    String artworkPath,
  ) async {
    await isar.writeTxn(() async {
      final stored = await isar.podcasts.get(podcastId);
      if (stored == null) return;
      stored.artworkPath = artworkPath;
      await isar.podcasts.put(stored);
    });
  }

  Future<File?> downloadAndSaveEpisodeArtwork(Episode episode) {
    return _downloadAndSaveArtwork(
      entityType: 'episode',
      entityId: episode.id,
      title: episode.title,
      artworkUrl: episode.artworkUrl,
      currentArtworkPath: episode.artworkPath,
      persistPath: (artworkPath) => persistEpisodeArtworkPath(
        _isarService.isar,
        episode.id,
        artworkPath,
      ),
      applyPath: (artworkPath) => episode.artworkPath = artworkPath,
    );
  }

  Future<File?> downloadAndSavePodcastArtwork(Podcast podcast) {
    return _downloadAndSaveArtwork(
      entityType: 'podcast',
      entityId: podcast.id,
      title: podcast.title,
      artworkUrl: podcast.artworkUrl,
      currentArtworkPath: podcast.artworkPath,
      persistPath: (artworkPath) => persistPodcastArtworkPath(
        _isarService.isar,
        podcast.id,
        artworkPath,
      ),
      applyPath: (artworkPath) => podcast.artworkPath = artworkPath,
    );
  }

  Future<File?> downloadAndSaveEpisodeArtworkFor({
    required int episodeId,
    required String title,
    required String? artworkUrl,
    required String? currentArtworkPath,
  }) {
    return _downloadAndSaveArtwork(
      entityType: 'episode',
      entityId: episodeId,
      title: title,
      artworkUrl: artworkUrl,
      currentArtworkPath: currentArtworkPath,
      persistPath: (artworkPath) => persistEpisodeArtworkPath(
        _isarService.isar,
        episodeId,
        artworkPath,
      ),
      applyPath: (_) {},
    );
  }

  Future<File?> downloadAndSavePodcastArtworkFor({
    required int podcastId,
    required String title,
    required String artworkUrl,
    required String? currentArtworkPath,
  }) {
    return _downloadAndSaveArtwork(
      entityType: 'podcast',
      entityId: podcastId,
      title: title,
      artworkUrl: artworkUrl,
      currentArtworkPath: currentArtworkPath,
      persistPath: (artworkPath) => persistPodcastArtworkPath(
        _isarService.isar,
        podcastId,
        artworkPath,
      ),
      applyPath: (_) {},
    );
  }

  Future<File?> _downloadAndSaveArtwork({
    required String entityType,
    required int entityId,
    required String title,
    required String? artworkUrl,
    required String? currentArtworkPath,
    required Future<void> Function(String artworkPath) persistPath,
    required void Function(String artworkPath) applyPath,
  }) async {
    try {
      Logger.info(
        '🎬 [ImageCache] 开始 $entityType 封面图下载: id=$entityId, title=$title',
      );

      if (artworkUrl == null || artworkUrl.isEmpty) {
        Logger.warning('⚠️ [ImageCache] artworkUrl 为空，跳过下载');
        return null;
      }

      if (currentArtworkPath != null && currentArtworkPath.isNotEmpty) {
        final existingFile = File(
          await _fileStorageService.getFullFilePath(currentArtworkPath),
        );
        if (await existingFile.exists()) {
          Logger.info('✅ [ImageCache] 本地封面已存在，跳过下载: ${existingFile.path}');
          return existingFile;
        }
        Logger.warning('⚠️ [ImageCache] artworkPath 存在但文件不存在，需要重新下载');
      }

      Logger.info('⬇️ [ImageCache] 开始下载: $artworkUrl');
      final startTime = DateTime.now();
      final response = await _dio.get(
        artworkUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      Logger.info(
        '⬇️ [ImageCache] 下载完成，耗时 '
        '${DateTime.now().difference(startTime).inMilliseconds}ms, '
        '状态码 ${response.statusCode}',
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw AppException.network(
          'Failed to download $entityType artwork: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final imagesDir = await _fileStorageService.getImagesDirectory();
      final fileName = _fileStorageService.generateArtworkFileName();
      final targetFile = File('${imagesDir.path}/$fileName');
      await targetFile.writeAsBytes(response.data);

      Logger.info(
        '✅ [ImageCache] 封面已保存: ${targetFile.path} '
        '(${await targetFile.length()} bytes)',
      );

      final artworkPath = 'images/$fileName';
      try {
        await persistPath(artworkPath);
        applyPath(artworkPath);
        Logger.info('✅ [ImageCache] artworkPath 已更新: $artworkPath');
      } catch (dbError) {
        Logger.error('❌ [ImageCache] 数据库更新失败（但文件已保存）: $dbError');
      }

      return targetFile;
    } on DioException catch (e, stackTrace) {
      Logger.error(
        '❌ [ImageCache] 网络请求异常: $artworkUrl',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.network(
        'Failed to download $entityType artwork: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      Logger.error(
        '❌ [ImageCache] 保存封面失败: $artworkUrl',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.storage(
        'Failed to save $entityType artwork',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> clearCache() async {
    try {
      final imagesDir = await _fileStorageService.getImagesDirectory();
      if (!await imagesDir.exists()) {
        Logger.info('Images directory does not exist, nothing to clear');
        return;
      }

      final files = imagesDir.listSync();
      int deletedCount = 0;

      for (var file in files) {
        if (file is File) {
          await file.delete();
          deletedCount++;
        }
      }

      Logger.info('Image cache cleared: $deletedCount files deleted');
    } catch (e, stackTrace) {
      Logger.error(
        'Error clearing image cache',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.storage(
        'Failed to clear image cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<int> getCacheSize() async {
    try {
      final imagesDir = await _fileStorageService.getImagesDirectory();
      if (!await imagesDir.exists()) {
        return 0;
      }

      final files = imagesDir.listSync();
      int totalSize = 0;

      for (var file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }

      Logger.debug('Image cache size: $totalSize bytes');
      return totalSize;
    } catch (e, stackTrace) {
      Logger.error(
        'Error getting cache size',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.storage(
        'Failed to get cache size',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

}
