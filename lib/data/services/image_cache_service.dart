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

  Future<File?> getCachedImage(String url) async {
    try {
      final imagesDir = await _fileStorageService.getImagesDirectory();
      final fileName = _fileStorageService.generateImageFileName(url);
      final cachedFile = File('${imagesDir.path}/$fileName');

      if (await cachedFile.exists()) {
        Logger.info('Image cache hit: $url');
        return cachedFile;
      }

      Logger.debug('Image cache miss: $url');
      return null;
    } catch (e, stackTrace) {
      Logger.error(
        'Error getting cached image: $url',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<File> cacheImage(String url, File imageFile) async {
    try {
      final imagesDir = await _fileStorageService.getImagesDirectory();
      final fileName = _fileStorageService.generateImageFileName(url);
      final targetFile = File('${imagesDir.path}/$fileName');

      await imageFile.copy(targetFile.path);
      Logger.info('Image cached successfully: $url -> ${targetFile.path}');
      return targetFile;
    } catch (e, stackTrace) {
      Logger.error(
        'Error caching image: $url',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.storage(
        'Failed to cache image: $url',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<File> downloadAndCacheImage(String url) async {
    try {
      final cachedImage = await getCachedImage(url);
      if (cachedImage != null) {
        return cachedImage;
      }

      Logger.info('Downloading image: $url');
      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final imagesDir = await _fileStorageService.getImagesDirectory();
        final fileName = _fileStorageService.generateImageFileName(url);
        final targetFile = File('${imagesDir.path}/$fileName');

        await targetFile.writeAsBytes(response.data);
        Logger.info('Image downloaded and cached: $url -> ${targetFile.path}');
        return targetFile;
      } else {
        throw AppException.network(
          'Failed to download image: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e, stackTrace) {
      Logger.error(
        'Error downloading image: $url',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.network(
        'Failed to download image: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Error downloading and caching image: $url',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.unknown(
        'Failed to download and cache image: $url',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

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

  Future<File?> downloadAndSaveEpisodeArtwork(Episode episode) async {
    try {
      Logger.info('🎬 [ImageCache] ===== 开始 Episode 封面图下载流程 =====');
      Logger.info('   📋 Episode ID: ${episode.id}');
      Logger.info('   📝 标题: ${episode.title}');
      Logger.info('   🔗 artworkUrl: ${episode.artworkUrl}');
      Logger.info('   📁 当前 artworkPath: ${episode.artworkPath ?? "无"}');

      if (episode.artworkUrl == null || episode.artworkUrl!.isEmpty) {
        Logger.warning('⚠️ [ImageCache] artworkUrl 为空，跳过下载');
        return null;
      }

      if (episode.artworkPath != null && episode.artworkPath!.isNotEmpty) {
        Logger.info('🔍 [ImageCache] 检查本地文件是否存在: ${episode.artworkPath}');
        final existingFile = File(await _fileStorageService.getFullFilePath(episode.artworkPath!));
        if (await existingFile.exists()) {
          Logger.info('✅ [ImageCache] 本地文件已存在，跳过下载: ${existingFile.path}');
          Logger.info('   📊 文件大小: ${await existingFile.length()} bytes');
          return existingFile;
        } else {
          Logger.warning('⚠️ [ImageCache] artworkPath 存在但文件不存在，需要重新下载');
        }
      }

      Logger.info('⬇️ [ImageCache] 开始从网络下载图片...');
      Logger.info('   🌐 下载 URL: ${episode.artworkUrl}');
      final startTime = DateTime.now();
      
      final response = await _dio.get(
        episode.artworkUrl!,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      final downloadDuration = DateTime.now().difference(startTime);
      Logger.info('⬇️ [ImageCache] 网络下载完成，耗时: ${downloadDuration.inMilliseconds}ms');
      Logger.info('   📦 响应状态码: ${response.statusCode}');
      Logger.info('   📏 数据大小: ${response.data?.length ?? 0} bytes');

      if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
        Logger.error('❌ [ImageCache] HTTP 错误: ${response.statusCode}');
        throw AppException.network(
          'Failed to download episode artwork: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      Logger.info('💾 [ImageCache] 开始保存到本地文件系统...');
      final imagesDir = await _fileStorageService.getImagesDirectory();
      final fileName = _fileStorageService.generateArtworkFileName();
      final targetFile = File('${imagesDir.path}/$fileName');
      
      Logger.info('   📁 目标目录: ${imagesDir.path}');
      Logger.info('   📄 文件名: $fileName');
      
      await targetFile.writeAsBytes(response.data);
      
      final fileSize = await targetFile.length();
      Logger.info('✅ [ImageCache] 文件保存成功: ${targetFile.path}');
      Logger.info('   📊 文件大小: $fileSize bytes');

      Logger.info('💾 [ImageCache] 更新数据库记录...');
      try {
        final artworkPath = 'images/$fileName';
        await persistEpisodeArtworkPath(
          _isarService.isar,
          episode.id,
          artworkPath,
        );
        episode.artworkPath = artworkPath;
        Logger.info('✅ [ImageCache] 数据库更新成功');
        Logger.info('   🔖 新的 artworkPath: $artworkPath');
      } catch (dbError) {
        Logger.error('❌ [ImageCache] 数据库更新失败（但文件已保存）: $dbError');
      }

      Logger.info('🎉 [ImageCache] ===== Episode 封面图下载流程完成 =====\n');
      return targetFile;
    } on DioException catch (e, stackTrace) {
      Logger.error(
        '❌ [ImageCache] 网络请求异常: ${episode.artworkUrl}',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.network(
        'Failed to download episode artwork: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error(
        '❌ [ImageCache] 未知错误',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.storage(
        'Failed to save episode artwork',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<File?> downloadAndSavePodcastArtwork(Podcast podcast) async {
    try {
      Logger.info('🎬 [ImageCache] ===== 开始 Podcast 封面图下载流程 =====');
      Logger.info('   📋 Podcast ID: ${podcast.id}');
      Logger.info('   📝 标题: ${podcast.title}');
      Logger.info('   🔗 artworkUrl: ${podcast.artworkUrl}');
      Logger.info('   📁 当前 artworkPath: ${podcast.artworkPath ?? "无"}');

      if (podcast.artworkUrl.isEmpty) {
        Logger.warning('⚠️ [ImageCache] artworkUrl 为空，跳过下载');
        return null;
      }

      if (podcast.artworkPath != null && podcast.artworkPath!.isNotEmpty) {
        Logger.info('🔍 [ImageCache] 检查本地文件是否存在: ${podcast.artworkPath}');
        final existingFile = File(await _fileStorageService.getFullFilePath(podcast.artworkPath!));
        if (await existingFile.exists()) {
          Logger.info('✅ [ImageCache] 本地文件已存在，跳过下载: ${existingFile.path}');
          Logger.info('   📊 文件大小: ${await existingFile.length()} bytes');
          return existingFile;
        } else {
          Logger.warning('⚠️ [ImageCache] artworkPath 存在但文件不存在，需要重新下载');
        }
      }

      Logger.info('⬇️ [ImageCache] 开始从网络下载图片...');
      Logger.info('   🌐 下载 URL: ${podcast.artworkUrl}');
      final startTime = DateTime.now();
      
      final response = await _dio.get(
        podcast.artworkUrl,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      final downloadDuration = DateTime.now().difference(startTime);
      Logger.info('⬇️ [ImageCache] 网络下载完成，耗时: ${downloadDuration.inMilliseconds}ms');
      Logger.info('   📦 响应状态码: ${response.statusCode}');
      Logger.info('   📏 数据大小: ${response.data?.length ?? 0} bytes');

      if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
        Logger.error('❌ [ImageCache] HTTP 错误: ${response.statusCode}');
        throw AppException.network(
          'Failed to download podcast artwork: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      Logger.info('💾 [ImageCache] 开始保存到本地文件系统...');
      final imagesDir = await _fileStorageService.getImagesDirectory();
      final fileName = _fileStorageService.generateArtworkFileName();
      final targetFile = File('${imagesDir.path}/$fileName');
      
      Logger.info('   📁 目标目录: ${imagesDir.path}');
      Logger.info('   📄 文件名: $fileName');
      
      await targetFile.writeAsBytes(response.data);
      
      final fileSize = await targetFile.length();
      Logger.info('✅ [ImageCache] 文件保存成功: ${targetFile.path}');
      Logger.info('   📊 文件大小: $fileSize bytes');

      Logger.info('💾 [ImageCache] 更新数据库记录...');
      try {
        final artworkPath = 'images/$fileName';
        await persistPodcastArtworkPath(
          _isarService.isar,
          podcast.id,
          artworkPath,
        );
        podcast.artworkPath = artworkPath;
        Logger.info('✅ [ImageCache] 数据库更新成功');
        Logger.info('   🔖 新的 artworkPath: $artworkPath');
      } catch (dbError) {
        Logger.error('❌ [ImageCache] 数据库更新失败（但文件已保存）: $dbError');
      }

      Logger.info('🎉 [ImageCache] ===== Podcast 封面图下载流程完成 =====\n');
      return targetFile;
    } on DioException catch (e, stackTrace) {
      Logger.error(
        '❌ [ImageCache] 网络请求异常: ${podcast.artworkUrl}',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.network(
        'Failed to download podcast artwork: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error(
        '❌ [ImageCache] 未知错误',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.storage(
        'Failed to save podcast artwork',
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

  Future<String> getCacheSizeFormatted() async {
    try {
      final sizeInBytes = await getCacheSize();
      return _formatBytes(sizeInBytes);
    } catch (e, stackTrace) {
      Logger.error(
        'Error formatting cache size',
        error: e,
        stackTrace: stackTrace,
      );
      return 'Unknown';
    }
  }

  String _formatBytes(int bytes) {
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
