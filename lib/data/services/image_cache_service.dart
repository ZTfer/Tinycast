import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/utils/app_exception.dart';
import '../../core/utils/logger.dart';
import 'file_storage_service.dart';

class ImageCacheService {
  ImageCacheService._();

  static final ImageCacheService _instance = ImageCacheService._();

  static ImageCacheService get instance => _instance;

  final FileStorageService _fileStorageService = FileStorageService.instance;
  final Dio _dio = Dio();

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

      if (response.statusCode == 200) {
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
