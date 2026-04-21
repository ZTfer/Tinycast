import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as pp;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import '../../core/utils/app_exception.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/storage_error_handler.dart';

class FileStorageService {
  FileStorageService._();

  static final FileStorageService _instance = FileStorageService._();

  static FileStorageService get instance => _instance;

  Directory? _cachedTempDir;
  Directory? _cachedSupportDir;
  Directory? _cachedAudioDir;
  Directory? _cachedImagesDir;

  bool _isInitialized = false;

  void clearCache() {
    _cachedTempDir = null;
    _cachedSupportDir = null;
    _cachedAudioDir = null;
    _cachedImagesDir = null;
    _isInitialized = false;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    Logger.info('🚀 [FILE_STORAGE] Initializing all directories...');
    final startTime = DateTime.now();

    // 并行加载所有目录
    await Future.wait([
      getTemporaryDirectory(),
      getApplicationSupportDirectory(),
      getAudioDirectory(),
      getImagesDirectory(),
    ]);

    _isInitialized = true;
    final duration = DateTime.now().difference(startTime);
    Logger.info(
      '✅ [FILE_STORAGE] All directories initialized in ${duration.inMilliseconds}ms',
    );
  }

  Future<Directory> getTemporaryDirectory() async {
    if (_cachedTempDir != null) return _cachedTempDir!;
    try {
      final dir = await pp.getTemporaryDirectory();
      _cachedTempDir = dir;
      Logger.debug('📁 [DEBUG] Temporary Directory: ${dir.path}');
      return dir;
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
    if (_cachedSupportDir != null) return _cachedSupportDir!;
    try {
      final dir = await pp.getApplicationSupportDirectory();
      _cachedSupportDir = dir;
      Logger.debug('📁 [DEBUG] Application Support Directory: ${dir.path}');
      return dir;
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
    if (_cachedImagesDir != null) return _cachedImagesDir!;
    try {
      final supportDir = await getApplicationSupportDirectory();
      final imagesDir = Directory(p.join(supportDir.path, 'images'));

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
        Logger.info('🖼️ [DEBUG] Images directory created: ${imagesDir.path}');
      } else {
        Logger.debug('🖼️ [DEBUG] Images directory exists: ${imagesDir.path}');
      }

      _cachedImagesDir = imagesDir;
      Logger.debug('🖼️ [DEBUG] Images Directory: ${imagesDir.path}');
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
    if (_cachedAudioDir != null && await _cachedAudioDir!.exists()) {
      return _cachedAudioDir!;
    }

    try {
      final supportDir = await getApplicationSupportDirectory();
      final audioDir = Directory(p.join(supportDir.path, 'audio'));

      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
        Logger.info('🎵 [DEBUG] Audio directory created: ${audioDir.path}');
      } else {
        Logger.debug('🎵 [DEBUG] Audio directory exists: ${audioDir.path}');

        // 列出音频目录中的文件
        try {
          final files = audioDir.listSync();
          if (files.isEmpty) {
            Logger.debug('🎵 [DEBUG] Audio directory is empty');
          } else {
            for (var file in files) {
              if (file is File) {
                final size = file.lengthSync();
                Logger.debug(
                  '🎵 [DEBUG] Audio file found: ${file.path} (${_formatFileSize(size)})',
                );
              }
            }
          }
        } catch (listError) {
          Logger.warning(
            '🎵 [DEBUG] Failed to list audio directory: $listError',
          );
        }
      }

      Logger.debug('🎵 [DEBUG] Audio Directory: ${audioDir.path}');
      _cachedAudioDir = audioDir;
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

  Future<void> deleteFileSafely(String relativePath, {String? context}) async {
    try {
      final fullPath = await getFullFilePath(relativePath);
      await StorageErrorHandler.deleteFileSafely(fullPath);

      final contextStr = context != null ? ' ($context)' : '';
      Logger.info('文件删除成功: $relativePath$contextStr');
    } catch (e, stackTrace) {
      final contextStr = context != null ? ' ($context)' : '';
      Logger.error(
        '删除文件失败: $relativePath$contextStr',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<int> deleteFilesSafely(
    List<String> relativePaths, {
    String? context,
  }) async {
    int successCount = 0;

    for (final path in relativePaths) {
      try {
        await deleteFileSafely(path, context: context);
        successCount++;
      } catch (e) {
        // 错误已经在 deleteFileSafely 中记录
      }
    }

    return successCount;
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
    final uuid = _generateUUID();
    Logger.debug(
      '🆔 [DEBUG] Generated UUID filename for episode $episodeId: $uuid.mp3',
    );
    return '$uuid.mp3';
  }

  String generateArtworkFileName() {
    final uuid = _generateUUID();
    Logger.debug('🆔 [DEBUG] Generated UUID filename for artwork: $uuid.jpg');
    return '$uuid.jpg';
  }

  String _generateUUID() {
    final random = Random();
    const hexChars = '0123456789abcdef';

    // 生成 UUID v4 格式：xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
    final segments = [
      // 8 个字符
      List.generate(8, (_) => hexChars[random.nextInt(16)]).join(),
      // 4 个字符
      List.generate(4, (_) => hexChars[random.nextInt(16)]).join(),
      // 4 个字符，第一位是 4（UUID v4）
      '4${List.generate(3, (_) => hexChars[random.nextInt(16)]).join()}',
      // 4 个字符，第一位是 8,9,a,b
      '${['8', '9', 'a', 'b'][random.nextInt(4)]}'
          '${List.generate(3, (_) => hexChars[random.nextInt(16)]).join()}',
      // 12 个字符
      List.generate(12, (_) => hexChars[random.nextInt(16)]).join(),
    ];

    return segments.join('-');
  }

  String generateImageFileName(String url) {
    final bytes = utf8.encode(url);
    final hash = sha256.convert(bytes);
    return '$hash.jpg';
  }

  Future<String> getFullFilePath(String relativePath) async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final fullPath = p.join(supportDir.path, relativePath);
      Logger.debug(
        '📄 [DEBUG] Full file path: $fullPath (relative: $relativePath)',
      );
      return fullPath;
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
