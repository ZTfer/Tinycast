# 音频下载功能调试指南

## 调试日志说明

下载流程通过 `lib/core/utils/logger.dart` 的 `Logger` 门面输出日志。日志文本里常见的
`[DEBUG]`、`[AUTO-DOWNLOAD]`、`[IMAGE_CACHE]` 等是**消息标签**，不是日志级别；
真正的级别由 `Logger.debug/info/warning/error` 决定。

## 文件日志位置与读取方式

除控制台输出外，`Logger` 会把日志追加写入本地文件。文件日志由
`lib/main.dart` 的 `_initializeApp()` 自动调用 `Logger.initFileLogging()` 开启，
无需手动配置。

### 位置规则

日志写在 `getApplicationSupportDirectory()` 返回的应用支持目录下，与音频、封面图
同级，**不随系统清理临时目录而丢失**：

- 目录：`<应用支持目录>/log/`
- 文件名：`<YYYY-MM-DD>.log`（按初始化时的本地日期命名，如 `2026-08-25.log`）

各平台大致位置：

| 平台 | 日志目录 |
|------|----------|
| macOS（沙盒） | `~/Library/Containers/com.example.tinycast/Data/Library/Application Support/com.example.tinycast/log/` |
| iOS | 应用沙盒 `Library/Application Support/log/` |
| Android | `/data/data/com.example.tinycast/files/log/` |
| Linux | `~/.local/share/tinycast/log/` |
| Windows | `%APPDATA%` 下应用目录中的 `log\` |

打包方式（bundle id、产品名）不同会导致路径差异，最准确的定位方式是应用启动时
输出的那条 info 日志，其中包含完整文件路径：

```text
[INFO] [TinyCast] 📝 [LOGGER] File logging initialized: /Users/<用户名>/Library/Containers/com.example.tinycast/Data/Library/Application Support/com.example.tinycast/log/2026-08-25.log
```

先记住这条路径，后续的 `tail` / `grep` 命令都以它为准。

### 行格式

```text
[2026-08-25T14:30:00.123456] [INFO] [TinyCast] 🔄 [SYNC] Starting sync...
  Error: <异常对象>           ← 仅 error 级别附带
  StackTrace: <堆栈>          ← 仅 error 级别附带
```

### 级别与输出位置

| 构建模式 | 控制台 | 文件 |
|----------|--------|------|
| debug | INFO 及以上 | INFO 及以上 |
| profile | 无 | INFO 及以上 |
| release | 无 | WARNING 及以上 |

`Logger` 默认最小级别是 `kReleaseMode ? warning : info`。`Logger.debug()` 的调用
默认会被过滤掉——包括 `📊` 进度、队列状态块、文件路径细节和 `🆔` 文件名。
需要查看这些日志时，在启动早期临时加入：

```dart
Logger.setMinLevel(LogLevel.debug);
```

例如放在 `lib/main.dart` 的 `_initializeApp()` 开头或 `main()` 中，重新运行应用；
调试结束后移除该行。开启后 debug 级日志会同时进入控制台与文件日志。

### 读取方式

以 macOS 沙盒路径为例，其他平台替换为上一节的日志目录：

```bash
# 实时跟随当天日志
tail -f "$HOME/Library/Containers/com.example.tinycast/Data/Library/Application Support/com.example.tinycast/log/$(date +%F).log"

# 按标签 / 级别检索
grep '\[AUTO-DOWNLOAD\]' <日志目录>/2026-08-25.log
grep '\[ERROR\]' <日志目录>/2026-08-25.log

# 忘记路径时，从历史日志中找回初始化行
grep -R 'File logging initialized' <日志目录>/*.log
```

### 注意事项

- **应用支持目录生命周期**：日志随应用数据保留，卸载应用或手动清理应用数据时才会
  删除；不会被系统临时目录清理机制回收
- **按天命名但不滚动**：文件名在初始化时固定，应用跨天持续运行会继续写入启动
  日期的文件
- **失败静默降级**：目录创建或写入失败时文件日志自动停用（不抛异常），此时只剩
  控制台输出
- **多窗口共享**：桌面端每个窗口引擎都会初始化文件日志，追加写入同一日期文件
- **debug 级日志默认不输出**：进度 `📊`、队列状态块、文件路径细节等
  `Logger.debug` 内容需要先调用 `Logger.setMinLevel(LogLevel.debug)` 才会出现

## 日志标识符

| 标识 | 含义 / 典型内容 |
|------|-----------------|
| `📁 [DEBUG]` | 临时目录、Application Support 目录 |
| `🎵 [DEBUG]` | 音频目录创建、存在、为空、文件列表 |
| `🖼️ [DEBUG]` / `🎬 [ImageCache]` | 图片目录、封面图下载 |
| `🆔 [DEBUG]` | 由 episode ID 派生的稳定音频文件名 |
| `📥 [DEBUG]` | 任务入队、标题、音频 URL |
| `📦 [DEBUG]` | 按播客批量下载、集数、逐集列表 |
| `⬇️` | 下载开始、自动下载策略、封面下载 |
| `🔄 [DEBUG]` | 队列处理、出队、恢复、服务器不支持 Range |
| `📊` | 下载进度，按 25% 档位输出 |
| `✅` | 入队成功、队列启动、下载完成、封面保存 |
| `❌` | 下载失败、批量失败、封面失败 |
| `⚠️` | 重复下载、文件已存在检查失败、封面失败等非致命问题 |
| `🛑 [DEBUG]` | 任务在真正开始前已被取消 |
| `🚫` | 下载被取消 |
| `⏸️` | 下载已暂停 |
| `📄 [DEBUG]` | 相对路径解析出的完整路径 |
| `🧪 [TEST]` | 手动测试代码的输出（如果自行添加） |

## 关键调试场景

### 场景1：订阅新播客时的自动下载

订阅成功后只会在**本次新增订阅**时触发自动下载。以下日志中包含 `[DEBUG]` 的行
需要先按上文开启 `Logger.setMinLevel(LogLevel.debug)` 才能看到；典型序列：

```text
[INFO] 🕒 [LIBRARY] addPodcast 开始, rssUrl=https://example.com/feed.xml
...
[INFO] 🕒 [LIBRARY] ... 调度自动下载任务
[INFO] ⬇️ [AUTO-DOWNLOAD] 策略: latest3, 播客ID: 2
[INFO] 📦 [DEBUG] ====== Starting podcast download: 2 ======
[INFO] 📦 [DEBUG] Download limit: 3 episodes
[INFO] 📦 [DEBUG] Episodes to download: 3
[DEBUG] 📦 [DEBUG] Episode 1/3: ID=195, Title="第一集"
[INFO] 📥 [DEBUG] Enqueuing download for episode: 195
[DEBUG]    - Title: 第一集
[DEBUG]    - Audio URL: https://example.com/audio.mp3
[DEBUG]    - File name: a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
[DEBUG]    - Relative path: audio/a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
[DEBUG]    - Temp path: /var/folders/xxx/T/a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
[DEBUG] ✅ [DEBUG] Task enqueued, queue size: 1
[INFO] ✅ [DEBUG] Episode added to queue successfully: 195
...（其余集数同理）
[INFO] 🔄 [DEBUG] ====== Processing download queue ======
[DEBUG] 🔄 [DEBUG] Queue status:
[DEBUG]    - Can start new: true
[DEBUG]    - Queue length: 3
[DEBUG]    - Active downloads: 0
[DEBUG]    - Max concurrent: 3
[INFO] 🔄 [DEBUG] Dequeued task #1: 195 (status: queued)
[INFO] ⬇️ [DEBUG] ====== Starting queued download for episode: 195 ======
[DEBUG] 📊 25%
[DEBUG] 📊 50%
[DEBUG] 📊 75%
[INFO] ✅ 下载完成: 195 (57.00 MB)
...
```

策略为关闭时只有：

```text
[INFO] ⬇️ [AUTO-DOWNLOAD] 自动下载策略为关闭，跳过
```

时间范围策略（`past24h` / `past7d` / `past14d` / `past30d`）会先输出：

```text
[INFO] ⬇️ [AUTO-DOWNLOAD] 时间范围策略，截止时间: 2026-08-18 14:30:00.000
[INFO] ⬇️ [AUTO-DOWNLOAD] 总集数: 50
[INFO] ⬇️ [AUTO-DOWNLOAD] 时间范围策略，找到 2 集
[INFO] ⬇️ [AUTO-DOWNLOAD] 准备下载: 第一集, pubDate: 2026-08-20 10:00:00.000
```

时间范围策略使用 `downloadEpisodeById()` 并发触发，多个下载任务的队列日志会交错，
按 episode ID 过滤更清晰。

### 场景2：单个下载过程

以下 `[DEBUG]` 行同样需要先开启 debug 级别：

```text
[INFO] ⬇️ 开始下载: 第一集 (195)
[INFO] 📥 [DEBUG] Enqueuing download for episode: 195
...
[INFO] 🔄 [DEBUG] ====== Processing download queue ======
[INFO] 🔄 [DEBUG] Dequeued task #1: 195 (status: queued)
[INFO] ⬇️ [DEBUG] ====== Starting queued download for episode: 195 ======
[DEBUG] 🆔 [DEBUG] Audio filename for episode 195:
       a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
[DEBUG] 📊 25%
[DEBUG] 📊 50%
[DEBUG] 📊 75%
[INFO] 🖼️ 开始下载 episode 封面图: 第一集
[INFO] ✅ 下载完成: 195 (57.00 MB)
```

补充说明：

- 如果目标文件已存在：`✅ 文件已存在, 标记完成: 195`，不会重新下载
- 如果同一任务已在队列/下载中：`⚠️ 下载已在进行中: 195`
- 如果临时文件已有数据但服务器不支持 Range：
  `🔄 服务器不支持断点续传, 重新下载: 195`
- 音频完成日志先于封面下载；封面失败只输出
  `⚠️ 封面图下载失败（不影响音频）`
- 进度 `📊` 是 `Logger.debug`，默认被过滤；按上文调用
  `Logger.setMinLevel(LogLevel.debug)` 后才会出现在控制台与文件日志

### 场景3：失败、暂停与取消

下载失败：

```text
[ERROR] ❌ 下载失败: 195, <错误信息>
  Error: <异常对象>
  StackTrace: <堆栈>
```

数据库中没有该 episode 时，错误信息是 `Episode not found: 195`，同样以
`❌ 下载失败` 输出。失败不会自动重试，也不会把失败状态写入数据库。

暂停与恢复：

```text
[INFO] ⏸️ 下载已暂停: 195
[INFO] Download paused for episode: 195
[INFO] 🔄 [RESUME] Status changed to idle synchronously for episode: 195
[INFO] ⬇️ 开始下载: 第一集 (195)
```

取消：

```text
[INFO] 🚫 下载取消: 195
[INFO] Temporary file deleted for episode: 195
[INFO] Download cancelled for episode: 195
```

排队中的任务被取消：

```text
[INFO] 已取消排队中的下载: 195
```

任务出队后、真正开始前被取消：

```text
[INFO] 🛑 [DEBUG] Download task was cancelled before start: 195
```

### 场景4：检查音频目录内容

```text
[DEBUG] 📁 [DEBUG] Application Support Directory: <app-support-path>
[DEBUG] 🎵 [DEBUG] Audio directory exists: <app-support-path>/audio
[DEBUG] 🎵 [DEBUG] Audio file found: <app-support-path>/audio/a1b2c3d4-....mp3 (57.00 MB)
[DEBUG] 🎵 [DEBUG] Audio Directory: <app-support-path>/audio
```

目录为空时：

```text
[DEBUG] 🎵 [DEBUG] Audio directory exists: <app-support-path>/audio
[DEBUG] 🎵 [DEBUG] Audio directory is empty
```

## 常见问题排查

### 问题1：找不到下载的文件

**症状**：日志显示下载完成，但按 `{episodeId}.mp3` 找不到文件。

**排查步骤**：

1. 确认看到 `✅ 下载完成: <id> (<size>)`
2. 文件名现在是 UUID 形状，不是 `{episodeId}.mp3`：
   `a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3`
3. 以数据库 `episode.downloadedPath` 为准；它是相对路径（`audio/...mp3`），
   需要拼接 Application Support 目录
4. macOS 启用沙盒后，路径在容器内：

   ```text
   ~/Library/Containers/com.example.tinycast/Data/Library/Application Support/com.example.tinycast/audio/
   ```

   不要只看 `~/Library/Application Support/tinycast/audio/`
5. 搜索 `🆔 [DEBUG] Audio filename for episode <id>` 可得到该集的确定文件名
6. 如果日志是 `✅ 文件已存在, 标记完成`，说明复用了一个已有文件（可能是旧命名），
   路径同样以 `downloadedPath` 为准

### 问题2：下载失败

**症状**：任务入队后状态变为 failed，没有 `✅ 下载完成`。

**排查步骤**：

1. 搜索 `❌ 下载失败: <id>`，读取后面的错误信息与堆栈
2. 检查 `Audio URL` 是否可访问、HTTP 状态码是否为 200/206
3. 检查临时目录是否可写、磁盘空间是否充足
4. 检查是否手动取消（`🚫 下载取消`）或暂停（`⏸️ 下载已暂停`）
5. 下载失败**没有自动重试**；修复原因后重新调用 `downloadEpisode()` 或
   `downloadEpisodeById()`

### 问题3：文件已下载但数据库状态未更新

**症状**：音频目录中能看到文件，但 UI 仍显示未下载。

**排查步骤**：

1. 确认有 `✅ 下载完成: <id>`，它表示文件已 rename 到最终目录并写入数据库
2. 如果只有 `📊` 进度、没有 `✅ 下载完成`，说明任务未进入终态，数据库也不会写入
   中间进度
3. 用 Isar Inspector 查看 `episodes` 记录：
   - `isDownloaded` 是否为 `true`
   - `downloadedPath` 是否为 `audio/<uuid>.mp3`
4. `❌ [ImageCache] 数据库更新失败` 与音频无关；它只影响封面

### 问题4：自动下载未触发

**症状**：订阅播客后没有下载任务。

**排查步骤**：

1. 搜索 `⬇️ [AUTO-DOWNLOAD]`：
   - 没有该行：可能不是新订阅（已订阅会直接跳过），或订阅流程在调用前失败
   - `自动下载策略为关闭，跳过`：把设置中的自动下载策略改为非 `off`
2. 查看 `📦 [DEBUG] Episodes to download: N`：
   - `0`：该播客没有已入库的 episode，或时间范围策略没有命中
3. 时间范围策略要检查截止时间日志与 `找到 N 集`
4. 检查 `⬇️ [AUTO-DOWNLOAD] 自动下载失败` 的 error/stackTrace

### 问题5：队列不继续下载

**症状**：有任务入队，但没有后续下载。

**排查步骤**：

1. 搜索 `🔄 [DEBUG] ====== Processing download queue ======`
2. 查看队列状态块中的 `Can start new`、`Queue length`、`Active downloads`、
   `Max concurrent`
3. 如果出现 `🔄 [DEBUG] No tasks were processed from queue!` 且队列非空，
   通常是并发已满（默认 3）
4. 进入下载后立即失败，会继续处理队列；失败原因见 `❌ 下载失败`
5. 完整的调用链与状态诊断见
   [docs/download_queue_debug.md](download_queue_debug.md)

### 问题6：暂停/恢复没有按预期工作

- `pauseDownload()` 只对 `downloading` 状态有效；对排队中任务不会暂停
- `resumeDownload()` 只对 `paused` 状态有效
- 失败任务不是 paused，重新下载请调用 `downloadEpisode()` / `downloadEpisodeById()`
- 暂停会保留临时文件；取消会删除临时文件并重置数据库下载状态

## 手动测试方法

### 方法1：使用 Flutter DevTools

1. 运行应用：`flutter run -d macos`（或 `./run.sh`）
2. 如需查看 `[DEBUG]` 细节，先按上文临时开启 `Logger.setMinLevel(LogLevel.debug)`
3. 打开 DevTools 的 Console
4. 过滤 `[DEBUG]`、`[AUTO-DOWNLOAD]` 或具体 episode ID
5. 观察入队、队列处理、进度与完成日志

### 方法2：使用命令行输出

```bash
flutter run -d macos --verbose
```

### 方法3：手动触发下载

```dart
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/services/audio_download_service.dart';
import 'package:tinycast/core/utils/logger.dart';

Future<void> testSingleDownload(int episodeId) async {
  final episode = await IsarService.instance.isar.episodes.get(episodeId);
  if (episode == null) {
    Logger.warning('Episode not found: $episodeId');
    return;
  }
  await AudioDownloadService.instance.downloadEpisode(episode);
}

Future<void> testBatchDownload(int podcastId) async {
  await AudioDownloadService.instance.downloadPodcastEpisodes(
    podcastId,
    limit: 2,
  );
}

void checkQueueStatus() {
  final service = AudioDownloadService.instance;
  Logger.info('Queue length: ${service.getQueueLength()}');
  Logger.info('Active: ${service.getActiveDownloadsCount()}');
  Logger.info('Queued IDs: ${service.getQueuedDownloads()}');
  Logger.info('Active IDs: ${service.getActiveDownloads()}');
  Logger.info('Paused IDs: ${service.getPausedDownloads()}');
}
```

### 方法4：检查文件系统

```bash
# macOS 沙盒容器
ls -lh ~/Library/Containers/com.example.tinycast/Data/Library/\
Application\ Support/com.example.tinycast/audio/

# 或者打开 Finder
open ~/Library/Containers/com.example.tinycast/Data/Library/\
Application\ Support/com.example.tinycast/audio/
```

## 性能与状态监控

通过日志可以观察：

- **进度档位**：`📊` 只在跨越 25% 档位时输出，不能当作实时速度曲线
- **文件大小**：`✅ 下载完成: <id> (<size>)`
- **队列状态**：队列长度、活跃下载数、最大并发数
- **错误**：`❌ 下载失败` 与封面警告
- **存储**：通过 `CacheCleanupService.getCacheSizeFormatted()` 等 API 查询

## 最佳实践

1. **按 episode ID 过滤**：批量下载时多个任务日志交错
2. **先看入队，再看队列，再看完成**：三段式定位比只看错误更高效
3. **区分日志标签与级别**：消息里的 `[DEBUG]` 不代表它不会写入文件
4. **关注 `✅ 下载完成` 与 `❌ 下载失败`**：这是任务终态的直接证据
5. **以数据库路径为准**：文件名是哈希派生的，不要从集数或标题推断

## 相关文件

- `lib/data/services/audio_download_service.dart` — 下载、队列、暂停/恢复/取消
- `lib/data/services/file_storage_service.dart` — 目录与文件名生成
- `lib/data/services/image_cache_service.dart` — 封面图缓存
- `lib/data/services/cache_cleanup_service.dart` — 缓存清理
- `lib/presentation/features/search/podcast_search_provider.dart` — 订阅后的自动下载触发
- `lib/presentation/widgets/molecules/episode_item/episode_control_bar.dart` — 收藏时的下载触发
- `lib/core/utils/logger.dart` — 日志级别与文件日志
