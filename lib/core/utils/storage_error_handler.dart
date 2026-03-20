import 'dart:io';
import 'app_exception.dart';
import 'logger.dart';

/// 存储错误处理工具类
class StorageErrorHandler {
  StorageErrorHandler._();

  /// 处理文件系统异常
  static AppException handleFileSystemException(FileSystemException e) {
    Logger.error('文件系统错误', error: e);

    final message = e.message;

    if (e.osError?.errorCode == 2) {
      return AppException.storage(
        '文件或目录不存在: $message',
        originalError: e,
      );
    }

    if (e.osError?.errorCode == 13) {
      return AppException.permission(
        '没有文件访问权限: $message',
        originalError: e,
      );
    }

    if (e.osError?.errorCode == 28) {
      return AppException.storage(
        '磁盘空间不足: $message',
        originalError: e,
      );
    }

    return AppException.storage(
      message,
      originalError: e,
    );
  }

  /// 处理 IO 异常
  static AppException handleIOException(IOException e) {
    Logger.error('IO 错误', error: e);

    return AppException.storage(
      'IO 操作失败: ${e.toString()}',
      originalError: e,
    );
  }

  /// 验证文件路径
  static void validateFilePath(String path) {
    if (path.isEmpty) {
      throw AppException.validation('文件路径不能为空');
    }

    try {
      final file = File(path);
      final directory = Directory(path);

      if (!file.existsSync() && !directory.existsSync()) {
        throw AppException.storage('文件或目录不存在: $path');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException.storage(
        '验证文件路径失败: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// 验证目录路径
  static void validateDirectoryPath(String path) {
    if (path.isEmpty) {
      throw AppException.validation('目录路径不能为空');
    }

    try {
      final directory = Directory(path);
      if (!directory.existsSync()) {
        throw AppException.storage('目录不存在: $path');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException.storage(
        '验证目录路径失败: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// 安全创建目录
  static Future<Directory> createDirectorySafely(String path) async {
    try {
      final directory = Directory(path);

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      return directory;
    } on FileSystemException catch (e) {
      throw handleFileSystemException(e);
    } catch (e) {
      Logger.error('创建目录失败', error: e);
      throw AppException.storage(
        '创建目录失败: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// 安全读取文件
  static Future<String> readFileSafely(String path) async {
    try {
      final file = File(path);

      if (!await file.exists()) {
        throw AppException.storage('文件不存在: $path');
      }

      return await file.readAsString();
    } on FileSystemException catch (e) {
      throw handleFileSystemException(e);
    } catch (e) {
      Logger.error('读取文件失败', error: e);
      throw AppException.storage(
        '读取文件失败: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// 安全写入文件
  static Future<void> writeFileSafely(String path, String content) async {
    try {
      final file = File(path);

      // 确保父目录存在
      final parentDir = file.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }

      await file.writeAsString(content);
    } on FileSystemException catch (e) {
      throw handleFileSystemException(e);
    } catch (e) {
      Logger.error('写入文件失败', error: e);
      throw AppException.storage(
        '写入文件失败: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// 安全删除文件
  static Future<void> deleteFileSafely(String path) async {
    try {
      final file = File(path);

      if (!await file.exists()) {
        Logger.warning('文件不存在，跳过删除: $path');
        return;
      }

      await file.delete();
    } on FileSystemException catch (e) {
      throw handleFileSystemException(e);
    } catch (e) {
      Logger.error('删除文件失败', error: e);
      throw AppException.storage(
        '删除文件失败: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// 检查磁盘空间
  static Future<bool> hasEnoughSpace(String path, int requiredBytes) async {
    try {
      final directory = Directory(path);

      if (!await directory.exists()) {
        return false;
      }

      // 这里可以添加实际的磁盘空间检查逻辑
      // 由于 Flutter 的文件系统 API 限制，可能需要使用平台特定的方法
      return true;
    } catch (e) {
      Logger.error('检查磁盘空间失败', error: e);
      return false;
    }
  }

  /// 清理临时文件
  static Future<void> cleanupTempFiles(String tempDir) async {
    try {
      final directory = Directory(tempDir);

      if (!await directory.exists()) {
        return;
      }

      final files = directory.listSync();

      for (var file in files) {
        if (file is File) {
          try {
            await file.delete();
          } catch (e) {
          Logger.warning('删除临时文件失败: ${file.path}');
        }
        }
      }
    } catch (e) {
      Logger.error('清理临时文件失败', error: e);
      throw AppException.storage(
        '清理临时文件失败: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// 获取文件大小
  static Future<int> getFileSize(String path) async {
    try {
      final file = File(path);

      if (!await file.exists()) {
        throw AppException.storage('文件不存在: $path');
      }

      return await file.length();
    } on FileSystemException catch (e) {
      throw handleFileSystemException(e);
    } catch (e) {
      Logger.error('获取文件大小失败', error: e);
      throw AppException.storage(
        '获取文件大小失败: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
