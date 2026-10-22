# 下载队列排查指南

## 队列模型

`AudioDownloadService` 使用一个纯内存队列：

- FIFO（`Queue<DownloadTask>`），默认最多 **3** 个并发下载
- `_downloadTasks` 保存所有入队/下载中的任务；`DownloadQueue` 分别维护排队与活跃任务
- 应用重启后队列与任务状态全部丢失；已完成的音频文件和数据库记录保留
- 下载失败不会自动重试；暂停、取消、失败都会触发一次队列调度

相关方法：

| 方法 | 作用 |
|------|------|
| `downloadEpisode(episode)` | 单集入队，等待该任务进入终态 |
| `downloadEpisodesBatch(episodes)` | 批量入队，返回时任务通常还没下载完 |
| `downloadPodcastEpisodes(podcastId, limit: n)` | 查询数据库后批量入队 |
| `_processQueue()` | 私有调度循环：在并发未满时不断 `dequeue()` 并启动下载 |
| `_startDownloadFromQueue(task)` | 从数据库取出 episode，执行实际传输与落盘 |
| `getQueueLength()` / `getActiveDownloadsCount()` | 查看排队数 / 活跃数 |
| `getQueuedDownloads()` / `getActiveDownloads()` / `getPausedDownloads()` | 查看任务 ID |

## 关键日志

队列主循环的入口日志是 info 级别，默认可见：

```text
🔄 [DEBUG] ====== Processing download queue ======
🔄 [DEBUG] Dequeued task #1: 195 (status: queued)
✅ [DEBUG] Successfully started 1 download(s) from queue
⬇️ [DEBUG] ====== Starting queued download for episode: 195 ======
```

队列状态明细、出队数量和任务状态属于 `Logger.debug`，默认被过滤。需要排查时，
在启动早期临时加入：

```dart
Logger.setMinLevel(LogLevel.debug);
```

然后可以看到：

```text
🔄 [DEBUG] ====== Processing download queue ======
🔄 [DEBUG] Queue status:
   - Can start new: true
   - Queue length: 3
   - Active downloads: 0
   - Max concurrent: 3
🔄 [DEBUG] Dequeued task #1: 195 (status: queued)
🔄 [DEBUG] Dequeued task #2: 196 (status: queued)
🔄 [DEBUG] Dequeued task #3: 197 (status: queued)
✅ [DEBUG] Successfully started 3 download(s) from queue
```

队列为空时会看到：

```text
🔄 [DEBUG] No more tasks in queue
```

并发已满而队列仍有任务：

```text
🔄 [DEBUG] No tasks were processed from queue!
🔄 [DEBUG] ERROR: Queue has 3 items but cannot start new downloads
🔄 [DEBUG] This might mean max concurrent downloads reached or queue logic issue
```

注意：`No tasks were processed from queue!` 也会在“队列本来为空、只是又调度了一次”
时出现；只有同时打印 `Queue has N items` 才表示确实有积压。

## 排查路径

### 1. 完全没有 "Processing download queue"

说明调度入口没有被调用，或应用根本没有入队任务：

- 检查是否调用了 `downloadEpisode()` / `downloadEpisodesBatch()` /
  `downloadPodcastEpisodes()`
- 订阅自动下载是否触发：搜索 `⬇️ [AUTO-DOWNLOAD]`；策略为 `off` 时会直接跳过
- `downloadEpisode()` 发现目标文件已存在时会直接标记完成，不会进入队列：
  搜索 `✅ 文件已存在, 标记完成`
- 任务已在下载中时只会等待现有任务，不会再入队：
  搜索 `⚠️ 下载已在进行中`

### 2. 有 "Processing download queue" 但没有出队

查看同一段日志中的队列状态：

| 状态 | 含义 |
|------|------|
| `Can start new: false` | 活跃下载数已达到 `Max concurrent`（默认 3），等已有任务结束 |
| `Queue length: 0` | 没有排队任务，只是重复调度 |
| `Active downloads` 等于 `Max concurrent` | 并发已满，属于正常背压 |

如果队列非空且 `Can start new: true`，但仍没有 `Dequeued task`，检查
`DownloadQueue.dequeue()` 与 `_downloadTasks` 是否一致；正常情况下
`canStartNewDownload` 为 true 时 `dequeue()` 会返回队首任务。

### 3. 任务出队后立即失败

`_startDownloadFromQueue()` 的第一步是从 Isar 读取 episode：

```text
❌ 下载失败: 195, Episode not found: 195
```

出现该日志说明队列入队时的 episode 已不在数据库中，或者 ID 类型解析失败。
检查：

1. episode ID 是否为整数
2. 该记录是否仍存在于 `episodes` 集合
3. 订阅/刷新过程中是否删除了该 episode

随后会执行：

1. 检查是否在开始前被取消 → `🛑 [DEBUG] Download task was cancelled before start`
2. 再次检查目标文件是否已存在 → 存在则直接完成
3. HTTP 传输
4. 临时文件 rename 到 `Application Support/audio`
5. 写入数据库并下载封面

常见的立即失败原因：

- 音频 URL 为空或不可访问
- HTTP 状态码不是 200/206
- 临时目录不可写、磁盘空间不足
- 服务器返回的内容长度与实际字节数不一致

### 4. 任务下载中卡住

按以下顺序排查：

1. 搜索 `⬇️ 开始下载` 与 `⏸️ 下载已暂停`，确认任务是在下载还是已暂停
2. 暂停的任务不会占用并发名额（`removeActive`），但仍保留在 `_downloadTasks`
3. 检查 `getActiveDownloadsCount()` 是否长期等于 3；如果是，等当前任务完成或取消
4. 检查网络超时配置：连接 30 秒、接收 30 分钟
5. 如果用户取消，会删除临时文件并重置数据库状态：
   `🚫 下载取消` / `Download cancelled for episode`

### 5. 下载完成但队列不继续

每个任务结束（完成、失败、取消、暂停）都会调用 `_processQueue()`。如果队列没有
继续，通常是：

- 后续任务在入队时被跳过（已在队列/已下载）
- 所有任务都在活跃集合中
- 日志被过滤，实际已经调度

核对 `getQueueLength()`、`getActiveDownloadsCount()` 与
`getPausedDownloads()` 三个值，可以判断任务究竟卡在哪个集合。

## 手动触发与状态检查

```dart
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/services/audio_download_service.dart';
import 'package:tinycast/core/utils/logger.dart';

Future<void> triggerSingleDownload(int episodeId) async {
  final episode = await IsarService.instance.isar.episodes.get(episodeId);
  if (episode == null) {
    Logger.warning('Episode not found: $episodeId');
    return;
  }
  await AudioDownloadService.instance.downloadEpisode(episode);
}

Future<void> triggerPodcastDownload(int podcastId) async {
  await AudioDownloadService.instance.downloadPodcastEpisodes(
    podcastId,
    limit: 3,
  );
}

void printQueueState() {
  final service = AudioDownloadService.instance;
  Logger.info('Queue: ${service.getQueueLength()}');
  Logger.info('Active: ${service.getActiveDownloadsCount()}');
  Logger.info('Queued: ${service.getQueuedDownloads()}');
  Logger.info('Active IDs: ${service.getActiveDownloads()}');
  Logger.info('Paused: ${service.getPausedDownloads()}');
}
```

## 文件系统检查

macOS 沙盒容器：

```bash
# 已完成的音频
ls -lh ~/Library/Containers/com.example.tinycast/Data/Library/\
Application\ Support/com.example.tinycast/audio/

# 应用支持目录
ls -la ~/Library/Containers/com.example.tinycast/Data/Library/\
Application\ Support/com.example.tinycast/

# 系统临时目录中的未完成分片（路径以日志中的 Temporary Directory 为准）
ls -la /var/folders/*/*/T/ | grep '\.mp3'
```

临时文件与最终文件使用同一个 UUID 形状名称；下载完成后临时文件会被 rename，
正常不会残留。任务被取消时临时文件会被删除；失败时可能保留，供下次尝试续传。

## 相关日志与文档

- 文件日志位置、日志级别与完整下载日志：见
  [download_debug_guide.md](download_debug_guide.md)
- 文件名与路径规则：见 [uuid_filename_guide.md](../reference/uuid_filename_guide.md)
- 核心实现：`lib/data/services/audio_download_service.dart`
