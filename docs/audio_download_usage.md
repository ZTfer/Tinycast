# 音频下载功能使用指南

## 概述

TinyCast 的下载能力由 `AudioDownloadService` 提供：单个/批量/按播客下载、内存队列、暂停/恢复/取消、Range 断点续传、下载状态与进度 Stream、失败与完成处理。缓存清理由 `CacheCleanupService` 提供。

下载队列只存在于内存中：应用重启后未完成的任务不会自动恢复，但已完成的音频文件与 `downloadedPath` 记录会保留。

## 核心功能

### 1. 单个音频下载

```dart
import 'package:tinycast/data/services/audio_download_service.dart';
import 'package:tinycast/data/models/episode_model.dart';

final downloadService = AudioDownloadService.instance;

// 等待该任务进入终态（完成、失败、取消或暂停）
await downloadService.downloadEpisode(episode);
```

`downloadEpisode()` 会先检查数据库中记录的 `downloadedPath` 与目标文件名是否已存在；已存在则直接标记完成，不重复下载。

### 2. 批量下载

```dart
final episodes = [episode1, episode2, episode3];
await downloadService.downloadEpisodesBatch(episodes);
```

批量方法只负责**入队并启动调度**，返回时任务通常尚未下载完成。需要等待结果时，监听状态/进度 Stream，或对单集调用 `downloadEpisode()`。

### 3. 按 Podcast ID 下载剧集

```dart
// 下载该播客的全部剧集
await downloadService.downloadPodcastEpisodes(podcastId);

// 按发布日期倒序，下载最新 10 集
await downloadService.downloadPodcastEpisodes(podcastId, limit: 10);
```

### 4. 下载队列管理

```dart
final queueLength = downloadService.getQueueLength();
final activeCount = downloadService.getActiveDownloadsCount();
final queuedDownloads = downloadService.getQueuedDownloads();
final activeDownloads = downloadService.getActiveDownloads();
final pausedDownloads = downloadService.getPausedDownloads();

// 取消仍在排队、尚未开始的任务
await downloadService.cancelQueuedDownload(episodeId);
```

队列默认最多同时下载 **3** 个文件（`DownloadQueue(maxConcurrentDownloads: 3)`）。

### 5. 下载控制

```dart
// 暂停正在下载的任务；已写入的临时文件保留
await downloadService.pauseDownload(episodeId);

// 恢复暂停的任务；若服务器支持 Range，会从已有字节继续
await downloadService.resumeDownload(episodeId);

// 取消任务：删除临时文件，并把数据库下载状态重置为未下载
await downloadService.cancelDownload(episodeId);

// 删除已完成的下载文件，并清空数据库中的下载记录
await downloadService.deleteDownloadedEpisode(episodeId);
```

`resumeDownload()` 只接受处于暂停状态的任务。任务失败后需要重新调用 `downloadEpisode()`（或 `downloadEpisodeById()`）重新入队；已有临时文件会在服务器支持 Range 时被复用。

### 6. 监听下载状态

```dart
downloadService.getDownloadStatusStream(episodeId).listen((status) {
  switch (status) {
    case DownloadStatus.queued:
      break;
    case DownloadStatus.downloading:
      break;
    case DownloadStatus.paused:
      break;
    case DownloadStatus.completed:
      break;
    case DownloadStatus.failed:
      break;
    case DownloadStatus.cancelled:
      break;
    case DownloadStatus.idle:
      break;
  }
});

downloadService.getDownloadProgressStream(episodeId).listen((progress) {
  print('下载进度: ${(progress * 100).toStringAsFixed(1)}%');
});
```

全局事件流可用于刷新下载列表：

```dart
downloadService.globalEventStream.listen((event) {
  print('${event.episodeId}: ${event.status}');
});
```

### 7. 查询下载状态

```dart
final isDownloaded = await downloadService.isEpisodeDownloaded(episodeId);
final progress = await downloadService.getDownloadProgress(episodeId);
final status = downloadService.getDownloadStatus(episodeId); // 可能为 null
```

进度只在内存任务存在时实时更新；下载完成后从数据库读取 `downloadProgress`。下载中的中间进度不会逐字节写入数据库。

## 自动下载的触发点

自动下载不是定时任务，当前只在这些用户动作上触发：

| 触发点 | 位置 | 条件 |
|--------|------|------|
| 新订阅播客 | `lib/presentation/features/search/podcast_search_provider.dart` 的 `addPodcast()` → `_handleAutoDownload()` | 设置中的 `autoDownloadPolicy` 不是 `off` |
| 收藏单集 | `lib/presentation/widgets/molecules/episode_item/episode_control_bar.dart` | 设置中的 `downloadOnFavorite` 为 `true` |
| 播放完成后的清理 | `lib/presentation/providers/playback_provider.dart` | 设置中的 `removePlayedDownloads` 为 `true`（这是删除，不是下载） |

`autoDownloadPolicy` 的可选值见
[docs/database.md](database.md#27-appsettingsmodel应用设置)。按时间范围的策略（`past24h` / `past7d` / `past14d` / `past30d`）会筛选 `pubDate` 晚于截止时间的剧集；`all` 下载全部。

## 缓存清理功能

### 1. 清理所有缓存

```dart
import 'package:tinycast/data/services/cache_cleanup_service.dart';

final cleanupService = CacheCleanupService.instance;
await cleanupService.clearAllCache();
```

### 2. 清理特定类型的缓存

```dart
await cleanupService.clearAudioCache();
await cleanupService.clearImageCache();
await cleanupService.clearPlayedEpisodes();
await cleanupService.clearPodcastFiles(podcastId);
```

### 3. 保留最近的节目

```dart
// 仅保留最近 10 集已下载节目，删除其他已下载文件
await cleanupService.keepRecentEpisodes(10);
```

### 4. 按容量清理（手动调用）

```dart
// 缓存超过 500MB 时，按发布时间从旧到新删除文件，直到回到上限以内
await cleanupService.autoCleanupIfNeeded(maxCacheSizeMB: 500);
```

`autoCleanupIfNeeded()` 是公开 API，但**当前没有启动流程或定时器调用它**。应用不会自动执行按容量清理；需要清理时由调用方显式触发。删除失败的文件会保留数据库下载状态，便于后续重试。

### 5. 查询缓存大小

```dart
final cacheSize = await cleanupService.getCacheSize();
final cacheSizeFormatted = await cleanupService.getCacheSizeFormatted();
final audioCacheSize = await cleanupService.getAudioCacheSizeFormatted();
final imageCacheSize = await cleanupService.getImageCacheSizeFormatted();
```

## 文件存储说明

### 存储位置

- **临时文件**：`getTemporaryDirectory()`，用于下载中的音频分片
- **音频文件**：`getApplicationSupportDirectory()/audio/`
- **图片文件**：`getApplicationSupportDirectory()/images/`

macOS 启用 App Sandbox 后，实际路径位于容器内：

```text
~/Library/Containers/com.example.tinycast/Data/Library/Application Support/com.example.tinycast/audio/
```

iOS 位于应用沙盒的 `Library/Application Support/audio/`；Android 位于应用私有的 `files/audio/`；Windows/Linux 的 `Application Support` 位置随平台而异。最可靠的定位方式是查看启动日志中的：

```text
📁 [DEBUG] Application Support Directory: <path>
🎵 [DEBUG] Audio Directory: <path>
```

### 文件命名规则

| 类型 | 当前命名 | 说明 |
|------|----------|------|
| 音频 | `<UUID 形状>.mp3` | 由 `SHA-256("tinycast:audio:<episodeId>")` 确定性派生，同一集稳定不变 |
| 单集/播客封面 | `<随机 UUID>.jpg` | `generateArtworkFileName()` 生成，路径记录在 `artworkPath` |
| 数据库音频路径 | `audio/<UUID 形状>.mp3` | 相对路径，不存绝对路径 |

示例：

```text
audio/a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
images/3f2a1b4c-5d6e-4f70-8a9b-0c1d2e3f4a5b.jpg
```

音频文件名不再使用 `{episodeId}.mp3`，也不再由每次下载随机生成。算法与旧文件兼容方式见
[docs/uuid_filename_guide.md](uuid_filename_guide.md)。

### 下载完成时的文件流转

1. 下载写入系统临时目录中的 `<UUID 形状>.mp3`
2. 完成后 `rename` 到 `Application Support/audio/<UUID 形状>.mp3`
3. 数据库写入 `isDownloaded=true`、`downloadedPath=audio/<UUID 形状>.mp3`、`downloadProgress=1.0`
4. 尝试下载单集封面；封面失败只记录警告，不影响音频下载结果

### 最佳实践

1. **使用相对路径**：数据库中只存 `audio/...` 或 `images/...`，绝对路径在运行时拼接
2. **不要依赖文件名推断元数据**：文件名是哈希派生的标识，不是标题或集数
3. **并发上限**：默认同时下载 3 个文件
4. **断点续传有前提**：只有服务器返回 `206 Partial Content` 时才从已有字节继续；否则从头下载
5. **没有自动重试**：失败后需要重新调用下载方法；临时文件可能保留，重试时可能续传
6. **清理需要显式调用**：`autoCleanupIfNeeded()` 当前未接入定时调度
7. **区分内存态与持久态**：队列、进度、暂停状态在应用退出后丢失；文件与最终下载记录保留

## 完整示例

```dart
import 'package:tinycast/data/services/audio_download_service.dart';
import 'package:tinycast/data/services/cache_cleanup_service.dart';
import 'package:tinycast/data/models/episode_model.dart';

class DownloadExample {
  final downloadService = AudioDownloadService.instance;
  final cleanupService = CacheCleanupService.instance;

  Future<void> downloadLatestEpisodes(int podcastId) async {
    await downloadService.downloadPodcastEpisodes(podcastId, limit: 5);
  }

  void monitorDownload(String episodeId) {
    downloadService.getDownloadStatusStream(episodeId).listen((status) {
      print('状态: $status');
    });

    downloadService.getDownloadProgressStream(episodeId).listen((progress) {
      print('进度: ${(progress * 100).toStringAsFixed(1)}%');
    });
  }

  Future<void> cleanup() async {
    print('当前缓存大小: ${await cleanupService.getCacheSizeFormatted()}');

    await cleanupService.keepRecentEpisodes(10);

    print('清理后缓存大小: ${await cleanupService.getCacheSizeFormatted()}');
  }
}
```

## 注意事项

1. 下载前确保有足够的存储空间
2. 大文件建议在 Wi-Fi 环境下下载
3. 缓存不会自动按容量清理，需要显式调用清理 API
4. 下载失败不会自动重试；重新调用下载方法时，若服务器支持 Range 可复用临时文件
5. 应用退出后，内存队列清空；未完成的临时分片可能留在系统临时目录，已完成的文件保留
6. `deleteDownloadedEpisode()` 会删除文件并重置数据库下载状态。若文件删除失败，
   目前仍会重置数据库状态（只记录错误日志），可能留下孤立文件，需要手动清理
