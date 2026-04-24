import 'dart:io';
import 'package:isar_community/isar.dart';
import '../../core/utils/app_exception.dart';
import '../../core/utils/logger.dart';
import '../database/isar_service.dart';
import '../models/episode_model.dart' as model;
import '../models/podcast_model.dart';
import 'audio_download_service.dart';
import 'file_storage_service.dart';
import 'image_cache_service.dart';

class CacheCleanupService {
  CacheCleanupService._();

  static final CacheCleanupService _instance = CacheCleanupService._();

  static CacheCleanupService get instance => _instance;

  final FileStorageService _fileStorageService = FileStorageService.instance;
  final ImageCacheService _imageCacheService = ImageCacheService.instance;
  final IsarService _isarService = IsarService.instance;

  Future<void> clearAllCache() async {
    try {
      Logger.info('开始清理所有缓存');

      await clearAudioCache();
      await clearImageCache();

      Logger.info('所有缓存清理完成');
    } catch (e, stackTrace) {
      Logger.error('清理所有缓存失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '清理所有缓存失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> clearAudioCache() async {
    try {
      Logger.info('开始清理音频缓存');

      final audioDir = await _fileStorageService.getAudioDirectory();
      if (!await audioDir.exists()) {
        Logger.info('音频目录不存在，无需清理');
        return;
      }

      final files = audioDir.listSync();
      int deletedCount = 0;

      for (var file in files) {
        if (file is File) {
          await file.delete();
          deletedCount++;
        }
      }

      // 批量更新数据库中所有 episode 的下载状态
      await _isarService.isar.writeTxn(() async {
        final downloadedEpisodes = await _isarService.isar.episodes
            .filter()
            .isDownloadedEqualTo(true)
            .findAll();

        for (final episode in downloadedEpisodes) {
          episode.isDownloaded = false;
          episode.downloadedPath = null;
          episode.downloadProgress = 0.0;
          episode.updatedAt = DateTime.now();
        }

        await _isarService.isar.episodes.putAll(downloadedEpisodes);

        // 发送事件通知 UI 刷新
        for (final episode in downloadedEpisodes) {
          AudioDownloadService.instance.sendGlobalEvent(
            episodeId: episode.id.toString(),
            status: DownloadStatus.cancelled,
          );
        }

        Logger.info('音频缓存清理完成: $deletedCount 个文件已删除，${downloadedEpisodes.length} 条数据库记录已更新');
      });
    } catch (e, stackTrace) {
      Logger.error('清理音频缓存失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '清理音频缓存失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> clearImageCache() async {
    try {
      Logger.info('开始清理图片缓存');

      await _imageCacheService.clearCache();

      // 清除数据库中所有 episode 和 podcast 的图片路径
      await _clearAllImagePaths();

      Logger.info('图片缓存清理完成');
    } catch (e, stackTrace) {
      Logger.error('清理图片缓存失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '清理图片缓存失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _clearAllImagePaths() async {
    try {
      Logger.info('开始清除数据库中的图片路径');

      // 清除 episode 的 artworkPath
      await _isarService.isar.writeTxn(() async {
        final episodes = await _isarService.isar.episodes
            .filter()
            .artworkPathIsNotNull()
            .findAll();

        for (final episode in episodes) {
          episode.artworkPath = null;
        }

        await _isarService.isar.episodes.putAll(episodes);

        Logger.info('已清除 ${episodes.length} 个 episode 的 artworkPath');
      });

      // 清除 podcast 的 artworkPath
      await _isarService.isar.writeTxn(() async {
        final podcasts = await _isarService.isar.podcasts
            .filter()
            .artworkPathIsNotNull()
            .findAll();

        for (final podcast in podcasts) {
          podcast.artworkPath = null;
        }

        await _isarService.isar.podcasts.putAll(podcasts);

        Logger.info('已清除 ${podcasts.length} 个 podcast 的 artworkPath');
      });

      Logger.info('数据库中图片路径清除完成');
    } catch (e, stackTrace) {
      Logger.error('清除图片路径失败', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> clearPlayedEpisodes() async {
    try {
      Logger.info('开始清理已播放节目');

      final playedEpisodes = await _isarService.isar.episodes
          .filter()
          .isPlayedEqualTo(true)
          .isDownloadedEqualTo(true)
          .findAll();

      int deletedCount = 0;

      // 先删除所有文件
      for (final episode in playedEpisodes) {
        if (episode.downloadedPath != null) {
          try {
            await _fileStorageService.deleteFile(episode.downloadedPath!);
            deletedCount++;
          } catch (e) {
            Logger.warning('删除已播放节目文件失败: ${episode.downloadedPath}');
          }
        }
      }

      // 批量更新数据库状态
      await _isarService.isar.writeTxn(() async {
        for (final episode in playedEpisodes) {
          episode.isDownloaded = false;
          episode.downloadedPath = null;
          episode.downloadProgress = 0.0;
          episode.updatedAt = DateTime.now();
        }

        await _isarService.isar.episodes.putAll(playedEpisodes);

        // 发送事件通知 UI 刷新
        for (final episode in playedEpisodes) {
          AudioDownloadService.instance.sendGlobalEvent(
            episodeId: episode.id.toString(),
            status: DownloadStatus.cancelled,
          );
        }
      });

      Logger.info('已播放节目清理完成: $deletedCount 个文件已删除');
    } catch (e, stackTrace) {
      Logger.error('清理已播放节目失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '清理已播放节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> keepRecentEpisodes(int count) async {
    try {
      Logger.info('开始保留最近 $count 集节目');

      final downloadedEpisodes = await _isarService.isar.episodes
          .filter()
          .isDownloadedEqualTo(true)
          .sortByPubDateDesc()
          .findAll();

      if (downloadedEpisodes.length <= count) {
        Logger.info('已下载节目数量 ($count) 不超过保留数量，无需清理');
        return;
      }

      final episodesToDelete = downloadedEpisodes.skip(count).toList();
      int deletedCount = 0;

      for (var episode in episodesToDelete) {
        if (episode.downloadedPath != null) {
          try {
            await _fileStorageService.deleteFile(episode.downloadedPath!);
            deletedCount++;
          } catch (e) {
            Logger.warning('删除节目文件失败: ${episode.downloadedPath}');
          }
        }

        await _updateEpisodeDownloadStatus(episode.id, false, null);
      }

      Logger.info('保留最近节目完成: $deletedCount 个文件已删除');
    } catch (e, stackTrace) {
      Logger.error('保留最近节目失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '保留最近节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> clearPodcastFiles(int podcastId) async {
    try {
      Logger.info('开始清理播客文件: $podcastId');

      final episodes = await _isarService.isar.episodes
          .filter()
          .podcastIdEqualTo(podcastId)
          .isDownloadedEqualTo(true)
          .findAll();

      int deletedCount = 0;

      for (var episode in episodes) {
        if (episode.downloadedPath != null) {
          try {
            await _fileStorageService.deleteFile(episode.downloadedPath!);
            deletedCount++;
          } catch (e) {
            Logger.warning('删除播客节目文件失败: ${episode.downloadedPath}');
          }
        }

        await _updateEpisodeDownloadStatus(episode.id, false, null);
      }

      Logger.info('播客文件清理完成: $deletedCount 个文件已删除');
    } catch (e, stackTrace) {
      Logger.error('清理播客文件失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '清理播客文件失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<int> getCacheSize() async {
    try {
      final audioSize = await getAudioCacheSize();
      final imageSize = await getImageCacheSize();

      return audioSize + imageSize;
    } catch (e, stackTrace) {
      Logger.error('获取缓存总大小失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '获取缓存总大小失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<int> getAudioCacheSize() async {
    try {
      final audioDir = await _fileStorageService.getAudioDirectory();
      if (!await audioDir.exists()) {
        return 0;
      }

      final files = audioDir.listSync();
      int totalSize = 0;

      for (var file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }

      Logger.debug('音频缓存大小: $totalSize 字节');
      return totalSize;
    } catch (e, stackTrace) {
      Logger.error('获取音频缓存大小失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '获取音频缓存大小失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<int> getImageCacheSize() async {
    try {
      return await _imageCacheService.getCacheSize();
    } catch (e, stackTrace) {
      Logger.error('获取图片缓存大小失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '获取图片缓存大小失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> autoCleanupIfNeeded({int maxCacheSizeMB = 500}) async {
    try {
      Logger.info('检查是否需要自动清理');

      final currentCacheSize = await getCacheSize();
      final currentCacheSizeMB = currentCacheSize / (1024 * 1024);

      if (currentCacheSizeMB > maxCacheSizeMB) {
        Logger.warning(
          '缓存大小超过限制 (${currentCacheSizeMB.toStringAsFixed(2)} MB)，开始自动清理',
        );

        await _cleanupOldestFiles(targetCacheSizeMB: maxCacheSizeMB);
      } else {
        Logger.info(
          '缓存大小正常 (${currentCacheSizeMB.toStringAsFixed(2)} MB)，无需清理',
        );
      }
    } catch (e, stackTrace) {
      Logger.error('自动清理检查失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '自动清理检查失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _cleanupOldestFiles({required int targetCacheSizeMB}) async {
    try {
      Logger.info('开始清理最旧的文件');

      final downloadedEpisodes = await _isarService.isar.episodes
          .filter()
          .isDownloadedEqualTo(true)
          .sortByPubDate()
          .findAll();

      int deletedCount = 0;

      for (var episode in downloadedEpisodes) {
        if (episode.downloadedPath != null) {
          try {
            await _fileStorageService.deleteFile(episode.downloadedPath!);
            deletedCount++;
          } catch (e) {
            Logger.warning('删除最旧节目文件失败: ${episode.downloadedPath}');
          }

          await _updateEpisodeDownloadStatus(episode.id, false, null);
        }

        final currentCacheSize = await getCacheSize();
        final currentCacheSizeMB = currentCacheSize / (1024 * 1024);

        if (currentCacheSizeMB < targetCacheSizeMB) {
          Logger.info('已达到目标缓存大小，停止清理');
          break;
        }
      }

      Logger.info('自动清理完成: $deletedCount 个文件已删除');
    } catch (e, stackTrace) {
      Logger.error('清理最旧文件失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '清理最旧文件失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _updateEpisodeDownloadStatus(
    int episodeId,
    bool isDownloaded,
    String? downloadedPath,
  ) async {
    try {
      await _isarService.isar.writeTxn(() async {
        final episode = await _isarService.isar.episodes.get(episodeId);
        if (episode != null) {
          episode.isDownloaded = isDownloaded;
          episode.downloadedPath = downloadedPath;
          episode.downloadProgress = isDownloaded ? 1.0 : 0.0;
          episode.updatedAt = DateTime.now();
          await _isarService.isar.episodes.put(episode);
        }
      });
    } catch (e, stackTrace) {
      Logger.error('更新节目下载状态失败: $episodeId', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '更新节目下载状态失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  String formatBytes(int bytes) {
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

  Future<String> getCacheSizeFormatted() async {
    try {
      final sizeInBytes = await getCacheSize();
      return formatBytes(sizeInBytes);
    } catch (e, stackTrace) {
      Logger.error('格式化缓存大小失败', error: e, stackTrace: stackTrace);
      return 'Unknown';
    }
  }

  Future<String> getAudioCacheSizeFormatted() async {
    try {
      final sizeInBytes = await getAudioCacheSize();
      return formatBytes(sizeInBytes);
    } catch (e, stackTrace) {
      Logger.error('格式化音频缓存大小失败', error: e, stackTrace: stackTrace);
      return 'Unknown';
    }
  }

  Future<String> getImageCacheSizeFormatted() async {
    try {
      final sizeInBytes = await getImageCacheSize();
      return formatBytes(sizeInBytes);
    } catch (e, stackTrace) {
      Logger.error('格式化图片缓存大小失败', error: e, stackTrace: stackTrace);
      return 'Unknown';
    }
  }
}
