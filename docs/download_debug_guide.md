# 音频下载功能调试指南

## 📋 调试日志说明

我已经为音频下载功能添加了详细的调试日志，使用 emoji 标识符
让你更容易识别不同类型的日志信息。

## 🔍 日志标识符

### 📁 文件路径相关

- `📁 [DEBUG]` - 文件目录和路径信息
- `📄 [DEBUG]` - 完整文件路径

### 🎵 音频文件相关

- `🎵 [DEBUG]` - 音频目录和文件操作
- `🎯 [DEBUG]` - 自动下载触发

### ⬇️ 下载流程相关

- `⬇️ [DEBUG]` - 下载开始
- `📥 [DEBUG]` - 下载任务创建
- `📦 [DEBUG]` - 批量下载
- `📊 [DEBUG]` - 下载进度

### ✅ 成功状态

- `✅ [DEBUG]` - 操作成功

### ❌ 错误状态

- `❌ [DEBUG]` - 操作失败或错误

### ⚠️ 警告状态

- `⚠️ [DEBUG]` - 非致命性问题

### 🔄 恢复/续传

- `🔄 [DEBUG]` - 断点续传

### 📝 其他信息

- `🖼️ [DEBUG]` - 图片相关
- `💾 [DEBUG]` - 文件保存
- `🗑️ [DEBUG]` - 文件删除
- `⏱️ [DEBUG]` - 时间统计
- `🌐 [DEBUG]` - 网络请求
- `⏸️ [DEBUG]` - 暂停状态

## 🎯 关键调试场景

### 场景1：订阅新播客时的自动下载

当你订阅一个新播客时，你应该看到以下日志序列：

```text
[INFO] 🎯 [DEBUG] ====== Auto-download triggered for new subscription ======
[INFO] 🎯 [DEBUG] Podcast: 播客名称 (ID: 123)
[INFO] 🎯 [DEBUG] Total episodes available: 50
[INFO] 🎯 [DEBUG] Will download latest 3 episodes
[INFO] 📦 [DEBUG] ====== Starting podcast download: 123 ======
[INFO] 📦 [DEBUG] Download limit: 3 episodes
[INFO] 📦 [DEBUG] Found 50 total episodes for podcast 123
[INFO] 📦 [DEBUG] Episodes to download: 3
[DEBUG] 📦 [DEBUG] Episode 1/3: ID=456, Title="第一集"
[DEBUG] 📦 [DEBUG] Episode 2/3: ID=789, Title="第二集"
[DEBUG] 📦 [DEBUG] Episode 3/3: ID=101, Title="第三集"
[INFO] 📥 [DEBUG] Enqueuing download for episode: 456
[DEBUG]    - Title: 第一集
[DEBUG]    - Audio URL: https://example.com/audio.mp3
[DEBUG] 📁 [DEBUG] Temporary Directory: /var/folders/xxx/T/tinycast
[DEBUG] 📁 [DEBUG] Application Support Directory:
       /Users/user/Library/Application Support/tinycast
[DEBUG]    - File name: 456.mp3
[DEBUG]    - Relative path: audio/456.mp3
[DEBUG]    - Temp path: /var/folders/xxx/T/tinycast/456.mp3
[DEBUG] ✅ [DEBUG] Task enqueued, queue size: 1
[INFO] ✅ [DEBUG] Episode added to queue successfully: 456
... (重复其他两个episode)
[INFO] ✅ [DEBUG] Auto-download tasks added to queue successfully
```

### 场景2：单个下载过程

当下载任务开始执行时：

```text
[DEBUG] ⬇️ [DEBUG] ====== Starting download for episode: 456 ======
[DEBUG] ⬇️ [DEBUG] Episode title: 第一集
[DEBUG] ⬇️ [DEBUG] Audio URL: https://example.com/audio.mp3
[DEBUG] ⬇️ [DEBUG] Podcast ID: 123
[DEBUG] 📁 [DEBUG] File paths:
[DEBUG]    - Audio directory: /Users/user/Library/Application Support/
              tinycast/audio
[DEBUG]    - Temp directory: /var/folders/xxx/T/tinycast
[DEBUG]    - File name: 456.mp3
[DEBUG]    - Relative path: audio/456.mp3
[DEBUG]    - Absolute path: /Users/user/Library/Application Support/
              tinycast/audio/456.mp3
[DEBUG]    - Temp path: /var/folders/xxx/T/tinycast/456.mp3
[DEBUG] ✅ [DEBUG] Audio directory exists and is ready
[INFO] 📥 [DEBUG] Download task created, updating database...
[DEBUG] 🆕 [DEBUG] No existing temp file, starting fresh download
[DEBUG] 🌐 [DEBUG] Starting HTTP download from: https://example.com/audio.mp3
[DEBUG] 📊 [DEBUG] Progress: 10.0% (5.00 MB / 50.00 MB)
[DEBUG] 📊 [DEBUG] Progress: 20.0% (10.00 MB / 50.00 MB)
[DEBUG] 📊 [DEBUG] Progress: 30.0% (15.00 MB / 50.00 MB)
...
[INFO] ✅ [DEBUG] Download completed successfully!
[INFO] ⏱️ [DEBUG] Download duration: 25s
[DEBUG] 🗑️ [DEBUG] Deleted existing file at:
       /Users/user/Library/Application Support/tinycast/audio/456.mp3
[INFO] 💾 [DEBUG] File saved successfully:
[INFO]    - Path: /Users/user/Library/Application Support/tinycast/audio/456.mp3
[INFO]    - Size: 50.00 MB
[INFO]    - Relative path: audio/456.mp3
```

### 场景3：检查音频目录内容

当你调用获取音频目录的方法时：

```text
[DEBUG] 📁 [DEBUG] Application Support Directory:
       /Users/user/Library/Application Support/tinycast
[DEBUG] 🎵 [DEBUG] Audio directory exists:
       /Users/user/Library/Application Support/tinycast/audio
[DEBUG] 🎵 [DEBUG] Audio file found:
       /Users/user/Library/Application Support/tinycast/audio/456.mp3 (50.00 MB)
[DEBUG] 🎵 [DEBUG] Audio file found:
       /Users/user/Library/Application Support/tinycast/audio/789.mp3 (30.00 MB)
[DEBUG] 🎵 [DEBUG] Audio Directory:
       /Users/user/Library/Application Support/tinycast/audio
```

如果目录为空：

```text
[DEBUG] 🎵 [DEBUG] Audio directory exists:
       /Users/user/Library/Application Support/tinycast/audio
[DEBUG] 🎵 [DEBUG] Audio directory is empty
```

## 🔧 常见问题排查

### 问题1：找不到下载的文件

**症状**：订阅成功但找不到音频文件

**排查步骤**：

1. 查看是否有 `🎵 [DEBUG] Audio directory created` 日志
2. 确认目录路径是否正确（macOS 应该在
   `/Users/{用户名}/Library/Application Support/tinycast/audio/`）
3. 检查是否有 `💾 [DEBUG] File saved successfully` 日志
4. 如果有错误，查看 `❌ [DEBUG] ERROR:` 相关日志

### 问题2：下载失败

**症状**：下载任务添加但未完成

**排查步骤**：

1. 查看 `🌐 [DEBUG] Starting HTTP download from:` 后的日志
2. 检查网络请求是否成功
3. 查看 DioException 相关的错误信息
4. 检查临时文件是否被正确创建

### 问题3：数据库更新失败

**症状**：文件已下载但数据库状态未更新

**排查步骤**：

1. 查看 `📥 [DEBUG] Download task created, updating database...`
   日志
2. 确认 Isar 数据库连接正常
3. 检查 episode ID 是否有效

### 问题4：自动下载未触发

**症状**：订阅播客后没有自动下载

**排查步骤**：

1. 查看 `🎯 [DEBUG] ====== Auto-download triggered for new
   subscription ======` 日志
2. 确认 podcastId 是否正确传递
3. 检查是否有 `⚠️ [DEBUG] Auto-download failed but subscription
   succeeded` 警告

## 🛠️ 手动测试方法

### 方法1：使用 Flutter DevTools

1. 运行应用：`flutter run -d macos`
2. 打开浏览器访问 DevTools
3. 在 Console 中搜索 `[DEBUG]` 过滤日志
4. 观察完整的下载流程

### 方法2：使用命令行输出

```bash
flutter run -d macos --verbose
```

在终端中直接查看所有日志输出。

### 方法3：手动触发下载

在代码中添加测试代码：

```dart
// 测试单个下载
final episode = await getTestEpisode();
await AudioDownloadService.instance.downloadEpisode(episode);

// 测试批量下载
await AudioDownloadService.instance.downloadPodcastEpisodes(
  123,
  limit: 3,
);
```

### 方法4：检查文件系统

```bash
# macOS
ls -la ~/Library/Application\ Support/tinycast/audio/

# 或者打开 Finder
open ~/Library/Application\ Support/tinycast/audio/
```

## 📊 性能监控

通过日志你可以监控：

- **下载速度**：通过进度变化和时间计算
- **文件大小**：每个文件的准确大小
- **队列状态**：当前排队和正在下载数量
- **存储空间**：音频目录中的所有文件大小总和
- **错误率**：下载失败的次数和原因

## 💡 最佳实践

1. **定期清理日志**：调试完成后可以移除或注释掉 DEBUG 日志
2. **关注关键节点**：重点关注 `✅` 和 `❌` 标识的日志
3. **时间戳对比**：注意日志的时间顺序，确保流程正确
4. **文件验证**：每次下载后确认文件确实存在且大小正确
5. **异常处理**：即使出现警告（⚠️），也要确认主流程是否完成

## 🔗 相关文件

- `lib/data/services/file_storage_service.dart` - 文件存储服务（路径管理）
- `lib/data/services/audio_download_service.dart` - 音频下载服务（核心逻辑）
- `lib/data/repositories/podcast_repository_impl.dart` - 订阅仓库（自动下载触发）
- `lib/core/utils/logger.dart` - 日志工具类

---

**提示**：如果你在生产环境中不需要这么多日志，可以：

1. 将 `Logger.debug()` 改为条件编译
2. 使用不同的日志级别
3. 创建一个 DebugService 来统一管理调试开关
