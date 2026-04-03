# 音频下载功能使用指南

## 概述

Tinycast 提供了完整的音频下载功能，支持单个下载、批量下载、队列管理、断点续传等功能。

## 核心功能

### 1. 单个音频下载

```dart
import 'package:tinycast/data/services/audio_download_service.dart';
import 'package:tinycast/data/models/episode_model.dart';

// 获取下载服务实例
final downloadService = AudioDownloadService.instance;

// 下载单个节目
await downloadService.downloadEpisode(episode);
```

### 2. 批量下载

```dart
// 批量下载多个节目
final episodes = [episode1, episode2, episode3];
await downloadService.downloadEpisodesBatch(episodes);
```

### 3. 根据 Podcast ID 下载所有剧集

```dart
// 下载播客的所有剧集
await downloadService.downloadPodcastEpisodes(podcastId);

// 下载播客的最新 10 集
await downloadService.downloadPodcastEpisodes(podcastId, limit: 10);
```

### 4. 下载队列管理

```dart
// 获取队列中的下载数量
final queueLength = downloadService.getQueueLength();

// 获取正在下载的数量
final activeCount = downloadService.getActiveDownloadsCount();

// 获取队列中的所有下载 ID
final queuedDownloads = downloadService.getQueuedDownloads();

// 获取正在下载的所有下载 ID
final activeDownloads = downloadService.getActiveDownloads();

// 取消排队中的下载
await downloadService.cancelQueuedDownload(episodeId);
```

### 5. 下载控制

```dart
// 暂停下载
await downloadService.pauseDownload(episodeId);

// 恢复下载
await downloadService.resumeDownload(episodeId);

// 取消下载
await downloadService.cancelDownload(episodeId);

// 删除已下载的文件
await downloadService.deleteDownloadedEpisode(episodeId);
```

### 6. 监听下载状态

```dart
// 监听下载状态变化
downloadService.getDownloadStatusStream(episodeId).listen((status) {
  switch (status) {
    case DownloadStatus.queued:
      print('已加入队列');
      break;
    case DownloadStatus.downloading:
      print('正在下载');
      break;
    case DownloadStatus.paused:
      print('已暂停');
      break;
    case DownloadStatus.completed:
      print('下载完成');
      break;
    case DownloadStatus.failed:
      print('下载失败');
      break;
    case DownloadStatus.cancelled:
      print('已取消');
      break;
    default:
      break;
  }
});

// 监听下载进度
downloadService.getDownloadProgressStream(episodeId).listen((progress) {
  print('下载进度: ${(progress * 100).toStringAsFixed(1)}%');
});
```

### 7. 查询下载状态

```dart
// 检查节目是否已下载
final isDownloaded = await downloadService.isEpisodeDownloaded(episodeId);

// 获取下载进度
final progress = await downloadService.getDownloadProgress(episodeId);

// 获取当前下载状态
final status = downloadService.getDownloadStatus(episodeId);
```

## 缓存清理功能

### 1. 清理所有缓存

```dart
import 'package:tinycast/data/services/cache_cleanup_service.dart';

final cleanupService = CacheCleanupService.instance;

// 清理所有缓存
await cleanupService.clearAllCache();
```

### 2. 清理特定类型的缓存

```dart
// 仅清理音频缓存
await cleanupService.clearAudioCache();

// 仅清理图片缓存
await cleanupService.clearImageCache();

// 清理已播放的节目
await cleanupService.clearPlayedEpisodes();

// 清理特定播客的所有文件
await cleanupService.clearPodcastFiles(podcastId);
```

### 3. 保留最近的节目

```dart
// 仅保留最近 10 集，删除其他已下载的节目
await cleanupService.keepRecentEpisodes(10);
```

### 4. 自动清理

```dart
// 当缓存超过 500MB 时自动清理
await cleanupService.autoCleanupIfNeeded(maxCacheSizeMB: 500);
```

### 5. 查询缓存大小

```dart
// 获取缓存总大小（字节）
final cacheSize = await cleanupService.getCacheSize();

// 获取格式化的缓存大小
final cacheSizeFormatted = await cleanupService.getCacheSizeFormatted();

// 获取音频缓存大小
final audioCacheSize = await cleanupService.getAudioCacheSizeFormatted();

// 获取图片缓存大小
final imageCacheSize = await cleanupService.getImageCacheSizeFormatted();
```

## 文件存储说明

### 存储位置

- **临时缓存**: `getTemporaryDirectory()` - 用于未完成的下载
- **永久存储**: `getApplicationSupportDirectory()` - 用于已下载的播客
  - iOS/macOS: `Library/Application Support`
  - Android: `files` 目录
  - Windows/Linux: `AppData` 或 `.config` 目录

### 文件命名规则

- 音频文件: `{episodeId}.mp3`
- 图片文件: `{sha256(url)}.jpg`
- 数据库中存储相对路径: `audio/{episodeId}.mp3`

### 最佳实践

1. **使用相对路径**: 数据库中只存储相对路径，确保跨设备兼容性
2. **文件命名**: 使用 EpisodeID 而不是原始文件名，避免特殊字符问题
3. **并发控制**: 默认最多同时下载 3 个文件，避免占用过多带宽
4. **断点续传**: 支持从上次中断的位置继续下载
5. **自动清理**: 定期检查缓存大小，自动清理旧文件

## 完整示例

```dart
import 'package:tinycast/data/services/audio_download_service.dart';
import 'package:tinycast/data/services/cache_cleanup_service.dart';
import 'package:tinycast/data/models/episode_model.dart';

class DownloadExample {
  final downloadService = AudioDownloadService.instance;
  final cleanupService = CacheCleanupService.instance;

  // 下载播客的最新 5 集
  Future<void> downloadLatestEpisodes(int podcastId) async {
    await downloadService.downloadPodcastEpisodes(podcastId, limit: 5);
  }

  // 监听下载进度
  void monitorDownload(String episodeId) {
    downloadService.getDownloadStatusStream(episodeId).listen((status) {
      print('状态: $status');
    });

    downloadService.getDownloadProgressStream(episodeId).listen((progress) {
      print('进度: ${(progress * 100).toStringAsFixed(1)}%');
    });
  }

  // 清理缓存
  Future<void> cleanup() async {
    final cacheSize = await cleanupService.getCacheSizeFormatted();
    print('当前缓存大小: $cacheSize');

    await cleanupService.keepRecentEpisodes(10);
    print('已清理，仅保留最近 10 集');

    final newSize = await cleanupService.getCacheSizeFormatted();
    print('清理后缓存大小: $newSize');
  }
}
```

## 注意事项

1. 下载前确保有足够的存储空间
2. 建议在 WiFi 环境下下载大文件
3. 定期清理缓存，避免占用过多空间
4. 下载失败时会自动重试（如果网络恢复）
5. 应用退出后，下载队列会清空，但已下载的文件会保留
