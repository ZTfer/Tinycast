# UUID 形状文件命名方案

## 📋 概述

所有下载的音频文件使用 **UUID 形状**的文件名。该名称由 episode ID 经
SHA-256 派生而来，对同一 episode **稳定不变**（不是每次调用随机生成），
因此暂停恢复、失败重试和「文件已存在」检查始终指向同一个文件，
不会留下无法回收的临时分片。

## 🔧 实现细节

### 文件命名格式

**旧格式**：

```text
{episodeId}.mp3
示例：195.mp3, 196.mp3, 197.mp3
```

**新格式**（稳定 UUID 形状）：

```text
{uuid}.mp3
示例：a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
```

### 生成规则

```text
1. digest = SHA-256("tinycast:audio:{episodeId}")   （64 位十六进制）
2. 取前 32 位，按 UUID 格式分段：8-4-4-4-12
3. 第 13 位固定为 '4'（版本位）
4. 第 17 位强制为 8/9/a/b（变体位）
5. 追加 .mp3 后缀
```

同一 episode 无论调用多少次、在多少台设备上，得到的名称都相同。

### 示例输出

```text
🆔 [DEBUG] Audio filename for episode 195:
       a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
🆔 [DEBUG] Audio filename for episode 195:   ← 再次调用，名称相同
       a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
🆔 [DEBUG] Audio filename for episode 196:   ← 不同 episode，名称不同
       b2c3d4e5-f6a7-4bcd-8f01-234567890abc.mp3
```

## 💾 数据库存储

### 存储的路径格式

数据库中的 `downloadedPath` 字段存储的是**相对路径**：

```dart
// 存储在 Episode 模型中
episode.downloadedPath = 'audio/a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3';
```

### 完整路径计算

```dart
// 获取完整路径
final fullPath = await fileStorageService.getFullFilePath(
  'audio/a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3',
);
// 结果：/Users/.../Application Support/com.example.tinycast/audio/
//        a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
```

## ✨ 使用 UUID 的优势

### 1. **安全性**

- ❌ 旧方式：`195.mp3` → 暴露内部 episode ID
- ✅ 新方式：`a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3`
  → 不暴露任何信息

### 2. **稳定性**

- 同一 episode 的名称恒定，暂停/恢复、失败重试复用同一临时文件
- 「文件已存在」检查可靠，不会因为重新生成名称而重复下载
- 不会在临时目录留下无法定位的孤儿分片

### 3. **隐私保护**

- 文件名不直接暴露 episode ID，无法一眼读出数据库主键
- 哈希空间足够分散，不同 episode 不会重名
- 注意：这是本地沙盒内的命名策略，不构成密码学安全边界

### 4. **标准化**

- 名称形状符合 UUID v4 格式（版本位、变体位均正确）
- 与业界常见的文件名去标识化做法一致
- 便于与其他按 UUID 处理文件名的系统集成

### 5. **可追溯性**

- 名称由 episode ID 确定性派生，重算即可定位文件
- 也可以通过数据库的 `downloadedPath` 字段追踪文件
- 便于调试和问题排查

## 🔍 日志输出示例

### 订阅时的完整日志

以下 `[DEBUG]` 行需要先临时调用 `Logger.setMinLevel(LogLevel.debug)`；默认最小
级别为 INFO，debug 级日志会被过滤。

```text
⬇️ [AUTO-DOWNLOAD] 策略: latest3, 播客ID: 2
📦 [DEBUG] ====== Starting podcast download: 2 ======
📦 [DEBUG] Download limit: 3 episodes
📦 [DEBUG] Episodes to download: 3
📦 [DEBUG] Episode 1/3: ID=195, Title="这半年，我们又买了哪些科技好物？"
📥 [DEBUG] Enqueuing download for episode: 195
   - Title: 这半年，我们又买了哪些科技好物？
   - Audio URL: https://example.com/audio.mp3
📁 [DEBUG] Temporary Directory: /var/folders/xxx/T
🆔 [DEBUG] Audio filename for episode 195:
       a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
   - File name: a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
   - Relative path: audio/a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
   - Temp path: /var/folders/xxx/T/
              a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
✅ [DEBUG] Task enqueued, queue size: 1
✅ [DEBUG] Episode added to queue successfully: 195

🔄 [DEBUG] ====== Processing download queue ======
🔄 [DEBUG] Dequeued task #1: 195 (status: queued)
⬇️ [DEBUG] ====== Starting queued download for episode: 195 ======
🆔 [DEBUG] Audio filename for episode 195:
       a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
✅ 下载完成: 195 (57.00 MB)
```

`🆔 [DEBUG]` 在入队生成文件名和开始下载前的“文件是否已存在”检查中各输出一次，
两次名称相同。日志里的 `File name`、`Relative path` 与 `Temp path` 都来自同一个
确定性文件名。

## 🗂️ 文件系统示例

### 目录结构

```text
/Users/ztfer/Library/Containers/com.example.tinycast/
└── Data/Library/Application Support/com.example.tinycast/
    └── audio/
        ├── a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3 (57 MB)  ← 新格式
        ├── b2c3d4e5-f6a7-4bcd-8f01-234567890abc.mp3 (66 MB)  ← 新格式
        ├── c3d4e5f6-a7b8-4cde-9f01-234567890abc.mp3 (111 MB) ← 新格式
        └── ...
```

## 🔄 迁移说明

### 已有文件的处理

**旧文件**（使用 episode ID 命名）仍然有效：

- 数据库中已记录的路径会继续工作
- 系统能正确读取和播放这些文件
- 不需要立即迁移，也不会被自动改名

**新下载的文件**使用稳定 UUID 形状命名。旧文件不会因为新算法上线而改名：
如果 `downloadedPath` 仍指向 `audio/195.mp3`，该集继续使用旧文件；只有删除记录后
重新下载，才会生成新的 `audio/<uuid>.mp3`。因此同一集在迁移期可能先后出现过
两种文件名，旧文件只有仍被 `downloadedPath` 引用时才有意义。

### 数据库兼容性

Episode 模型的 `downloadedPath` 字段：

- 存储相对路径（如 `audio/{filename}.mp3`）
- 文件名可以旧格式或新格式，读取时都以该字段为准
- 向后兼容，无需修改数据库结构
- 清理旧文件时应通过数据库记录定位，不要按文件名格式批量删除

### 如何识别是否需要迁移

不需要主动迁移。判断某集是否可直接播放，只看：

1. `episode.downloadedPath` 是否非空
2. 该相对路径对应的文件是否存在

旧文件存在则继续使用；文件缺失时重新下载，新文件会自然采用 UUID 形状名称。
用户若想统一命名，可显式删除旧下载后重新下载，但这不是必需步骤。

## 🧪 测试验证

### 方法1：查看日志

搜索 `🆔 [DEBUG]` 可以看到音频文件名生成记录：

```text
🆔 [DEBUG] Audio filename for episode XXX: {uuid}.mp3
```

同一 episode 的日志名在每次生成时都相同。

### 方法2：检查文件系统

```bash
# 列出音频目录中的文件
ls -lh ~/Library/Containers/com.example.tinycast/Data/Library/\
Application\ Support/com.example.tinycast/audio/

# 应该看到类似这样的文件名：
# a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
```

### 方法3：检查数据库

使用 Isar Inspector 查看 Episode 记录：

- `downloadedPath` 字段应该包含 UUID 格式的文件名
- 示例：`audio/a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3`

## ⚙️ 技术实现

### 音频文件名生成（确定性）

```dart
String generateAudioFileName(String episodeId) {
  final digest = sha256
      .convert(utf8.encode('tinycast:audio:$episodeId'))
      .toString();
  final version = '4${digest.substring(13, 16)}';
  final variantValue = (int.parse(digest[16], radix: 16) & 0x3) | 0x8;
  final variant =
      '${variantValue.toRadixString(16)}${digest.substring(17, 20)}';
  return '${digest.substring(0, 8)}-${digest.substring(8, 12)}-'
      '$version-$variant-${digest.substring(20, 32)}.mp3';
}
```

- 输入固定为 `tinycast:audio:{episodeId}`，因此结果只取决于 episode ID
- 取摘要前 32 个十六进制字符，按 `8-4-4-4-12` 分段
- 版本位固定为 `4`，变体位强制落在 `8/9/a/b`
- 封面图仍使用随机 UUID（`generateArtworkFileName()`），不需要稳定复用

### 名称唯一性

音频文件名不再依赖随机数，而是依赖 SHA-256：

- 同一 episode 在任何设备、任何时间生成的名字完全一致
- 名称使用 SHA-256 摘要截取并改写得到的 32 个十六进制字符，两个不同 episode
  只有在这些字符碰撞时才会同名，实际使用中可以忽略
- 即使发生极端碰撞，数据库中的 `downloadedPath` 仍是最终依据

## 📝 最佳实践建议

1. **不要依赖文件名推断信息**
   - 文件名是由 episode ID 哈希派生的 UUID 形状字符串
   - 所有元数据应从数据库获取

2. **始终通过数据库访问文件**
   - 使用 `episode.downloadedPath` 获取文件位置
   - 需要重新计算名称时统一调用 `generateAudioFileName(episodeId)`

3. **日志记录**
   - 保留 `🆔 [DEBUG] Audio filename` 日志便于调试
   - 日志中的名称可稳定复现，可通过 episode ID 追踪到具体文件

4. **清理策略**
   - 使用数据库记录判断文件是否需要删除
   - 不要仅根据文件名做决策

## 🔐 安全考虑

### 信息泄露防护

**不暴露的信息**：

- ❌ Episode 内部 ID
- ❌ 下载顺序或时间戳
- ❌ 用户行为模式
- ❌ 数据库主键序列

**暴露的信息**（安全）：

- ✅ 仅显示哈希派生的伪随机字符串
- ✅ 无法直接读出原始 episode ID

### 边界说明

名称是「命名混淆」而非加密：知道 episode ID 的人可以重算文件名。
安全性依赖应用沙盒与系统权限，而非文件名本身。

### 文件访问控制

- 文件保存在应用的沙盒目录中
- 其他应用无法直接访问
- 即便文件名被看到也无安全风险

---

**实施日期**：2026-04-03
**版本**：v2.0
**状态**：✅ 已完成并测试
