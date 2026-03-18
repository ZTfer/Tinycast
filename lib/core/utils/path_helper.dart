import 'dart:io';
import 'package:path/path.dart' as p;
import 'app_exception.dart';
import 'logger.dart';

class PathHelper {
  PathHelper._();

  static String getFileName(String path) {
    return p.basename(path);
  }

  static String getFileExtension(String path) {
    return p.extension(path);
  }

  static String getDirectoryName(String path) {
    return p.dirname(path);
  }

  static String join(String part1, String part2, [String? part3, String? part4]) {
    return p.join(part1, part2, ifNull(part3, ''), ifNull(part4, ''));
  }

  static String normalize(String path) {
    return p.normalize(path);
  }

  static String absolute(String path) {
    return p.absolute(path);
  }

  static bool isAbsolute(String path) {
    return p.isAbsolute(path);
  }

  static bool isRelative(String path) {
    return p.isRelative(path);
  }

  static bool exists(String path) {
    try {
      return File(path).existsSync() || Directory(path).existsSync();
    } catch (e) {
      Logger.error('Error checking path existence', error: e);
      return false;
    }
  }

  static bool isFile(String path) {
    try {
      return File(path).existsSync();
    } catch (e) {
      Logger.error('Error checking if path is a file', error: e);
      return false;
    }
  }

  static bool isDirectory(String path) {
    try {
      return Directory(path).existsSync();
    } catch (e) {
      Logger.error('Error checking if path is a directory', error: e);
      return false;
    }
  }

  static Future<void> createDirectory(String path) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        Logger.info('Directory created: $path');
      }
    } catch (e, stackTrace) {
      Logger.error('Error creating directory', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        'Failed to create directory: $path',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        Logger.info('File deleted: $path');
      }
    } catch (e, stackTrace) {
      Logger.error('Error deleting file', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        'Failed to delete file: $path',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> deleteDirectory(String path) async {
    try {
      final directory = Directory(path);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        Logger.info('Directory deleted: $path');
      }
    } catch (e, stackTrace) {
      Logger.error('Error deleting directory', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        'Failed to delete directory: $path',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<int> getFileSize(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e, stackTrace) {
      Logger.error('Error getting file size', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        'Failed to get file size: $path',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  static String formatFileSize(int bytes) {
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

  static Future<List<String>> listFiles(String path, {String? extension}) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) {
        return [];
      }

      final entities = await directory.list().toList();
      final files = entities.whereType<File>().toList();

      if (extension != null) {
        return files
            .where((file) => p.extension(file.path) == extension)
            .map((file) => file.path)
            .toList();
      }

      return files.map((file) => file.path).toList();
    } catch (e, stackTrace) {
      Logger.error('Error listing files', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        'Failed to list files in: $path',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<List<String>> listDirectories(String path) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) {
        return [];
      }

      final entities = await directory.list().toList();
      return entities
          .whereType<Directory>()
          .map((dir) => dir.path)
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Error listing directories', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        'Failed to list directories in: $path',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  static String? ifNull(String? value, String defaultValue) {
    return value ?? defaultValue;
  }
}
