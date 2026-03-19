import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as pp;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../core/utils/app_exception.dart';
import '../../core/utils/logger.dart';

class FileStorageService {
  FileStorageService._();

  static final FileStorageService _instance = FileStorageService._();

  static FileStorageService get instance => _instance;

  Future<Directory> getTemporaryDirectory() async {
    try {
      return await pp.getTemporaryDirectory();
    } catch (e, stackTrace) {
      Logger.error(
        'Error getting temporary directory',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.storage(
        'Failed to get temporary directory',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Directory> getApplicationSupportDirectory() async {
    try {
      return await pp.getApplicationSupportDirectory();
    } catch (e, stackTrace) {
      Logger.error(
        'Error getting application support directory',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.storage(
        'Failed to get application support directory',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Directory> getImagesDirectory() async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final imagesDir = Directory(p.join(supportDir.path, 'images'));

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
        Logger.info('Images directory created: ${imagesDir.path}');
      }

      return imagesDir;
    } catch (e, stackTrace) {
      Logger.error(
        'Error getting images directory',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.storage(
        'Failed to get images directory',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Directory> getAudioDirectory() async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final audioDir = Directory(p.join(supportDir.path, 'audio'));

      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
        Logger.info('Audio directory created: ${audioDir.path}');
      }

      return audioDir;
    } catch (e, stackTrace) {
      Logger.error(
        'Error getting audio directory',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.storage(
        'Failed to get audio directory',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> fileExists(String relativePath) async {
    try {
      final fullPath = await getFullFilePath(relativePath);
      return File(fullPath).existsSync();
    } catch (e, stackTrace) {
      Logger.error(
        'Error checking file existence: $relativePath',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> deleteFile(String relativePath) async {
    try {
      final fullPath = await getFullFilePath(relativePath);
      final file = File(fullPath);

      if (await file.exists()) {
        await file.delete();
        Logger.info('File deleted: $fullPath');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error deleting file: $relativePath',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.storage(
        'Failed to delete file: $relativePath',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<int> getFileSize(String relativePath) async {
    try {
      final fullPath = await getFullFilePath(relativePath);
      final file = File(fullPath);

      if (await file.exists()) {
        return await file.length();
      }

      return 0;
    } catch (e, stackTrace) {
      Logger.error(
        'Error getting file size: $relativePath',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.storage(
        'Failed to get file size: $relativePath',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  String joinPath(List<String> parts) {
    return p.joinAll(parts);
  }

  String generateAudioFileName(String episodeId) {
    return '$episodeId.mp3';
  }

  String generateImageFileName(String url) {
    final bytes = utf8.encode(url);
    final hash = sha256.convert(bytes);
    return '$hash.jpg';
  }

  Future<String> getFullFilePath(String relativePath) async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      return p.join(supportDir.path, relativePath);
    } catch (e, stackTrace) {
      Logger.error(
        'Error getting full file path: $relativePath',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.storage(
        'Failed to get full file path: $relativePath',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
