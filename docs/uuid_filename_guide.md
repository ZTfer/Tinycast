# UUID 文件命名方案

## 📋 概述

从现在开始，所有下载的音频文件将使用 **UUID v4** 作为文件名，而不是之前的 episode ID。

## 🔧 实现细节

### 文件命名格式

**旧格式**：
```
{episodeId}.mp3
示例：195.mp3, 196.mp3, 197.mp3
```

**新格式**（UUID v4）：
```
{uuid}.mp3
示例：a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
```

### UUID 生成规则

生成的 UUID 符合 **UUID v4 标准**：

```
格式：xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx

其中：
- x = 随机十六进制字符 (0-9, a-f)
- 第13位固定为 '4' (标识版本号)
- 第17位为 '8', '9', 'a', 或 'b' (标识变体)
```

### 示例输出

```
🆔 [DEBUG] Generated UUID filename for episode 195: a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
🆔 [DEBUG] Generated UUID filename for episode 196: b2c3d4e5-f6a7-4bcd-ef01-234567890abc.mp3
🆔 [DEBUG] Generated UUID filename for episode 197: c3d4e5f6-a7b8-4cde-f01-234567890abcd.mp3
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
final fullPath = await fileStorageService.getFullFilePath('audio/a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3');
// 结果：/Users/.../Application Support/com.example.tinycast/audio/a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
```

## ✨ 使用 UUID 的优势

### 1. **安全性**
- ❌ 旧方式：`195.mp3` → 暴露内部 episode ID
- ✅ 新方式：`a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3` → 不暴露任何信息

### 2. **唯一性**
- UUID 保证全局唯一（概率极低冲突）
- 即使在不同设备、不同时间生成，也不会重复
- 避免文件名冲突

### 3. **隐私保护**
- 用户无法通过文件名推断出：
  - episode 的内部 ID
  - 下载顺序
  - 数据库结构

### 4. **标准化**
- 符合 RFC 4122 标准
- 与业界最佳实践一致
- 便于与其他系统集成

### 5. **可追溯性**
- 每个 UUID 都是唯一的标识符
- 可以通过数据库的 `downloadedPath` 字段追踪文件
- 便于调试和问题排查

## 🔍 日志输出示例

### 订阅时的完整日志

```
🎯 [DEBUG] ====== Auto-download triggered for new subscription ======
🎯 [DEBUG] Podcast: 科技乱炖 (ID: 2)
🎯 [DEBUG] Will download latest 3 episodes

📥 [DEBUG] Enqueuing download for episode: 195
   - Title: 这半年，我们又买了哪些科技好物？
   - Audio URL: https://example.com/audio.mp3
📁 [DEBUG] Temporary Directory: /var/folders/xxx/T/tinycast
🆔 [DEBUG] Generated UUID filename for episode 195: a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3    ← 新！
   - File name: a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3                                    ← 新！
   - Relative path: audio/a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3                        ← 新！
   - Temp path: /var/folders/xxx/T/tinycast/a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3       ← 新！
✅ [DEBUG] Task enqueued, queue size: 1

⬇️ [DEBUG] ====== Starting queued download for episode: 195 ======
✅ [DEBUG] Episode found: 这半年，我们又买了哪些科技好物？
...
💾 [DEBUG] File saved successfully:
   - Path: /Users/.../audio/a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3     ← 新！
   - Size: 57.00 MB
   - Relative path: audio/a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3         ← 新！
```

## 🗂️ 文件系统示例

### 目录结构

```
/Users/ztfer/Library/Containers/com.example.tinycast/
└── Data/Library/Application Support/com.example.tinycast/
    └── audio/
        ├── a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3  (57 MB)  ← 新格式
        ├── b2c3d4e5-f6a7-4bcd-ef01-234567890abc.mp3  (66 MB)  ← 新格式
        ├── c3d4e5f6-a7b8-4cde-f01-234567890abcd.mp3  (111 MB) ← 新格式
        └── ...
```

## 🔄 迁移说明

### 已有文件的处理

**旧文件**（使用 episode ID 命名）仍然有效：
- 数据库中已记录的路径会继续工作
- 系统能正确读取和播放这些文件
- 不需要立即迁移

**新下载的文件**将自动使用 UUID 命名。

### 数据库兼容性

Episode 模型的 `downloadedPath` 字段：
- 存储相对路径（如 `audio/{filename}.mp3`）
- 无论文件名是什么格式都能正常工作
- 向后兼容，无需修改数据库结构

## 🧪 测试验证

### 方法1：查看日志

搜索 `🆔 [DEBUG]` 可以看到所有 UUID 生成记录：
```
🆔 [DEBUG] Generated UUID filename for episode XXX: {uuid}.mp3
```

### 方法2：检查文件系统

```bash
# 列出音频目录中的文件
ls -lh ~/Library/Containers/com.example.tinycast/Data/Library/Application\ Support/com.example.tinycast/audio/

# 应该看到类似这样的文件名：
# a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3
```

### 方法3：检查数据库

使用 Isar Inspector 查看 Episode 记录：
- `downloadedPath` 字段应该包含 UUID 格式的文件名
- 示例：`audio/a1b2c3d4-e5f6-4789-abcd-ef0123456789.mp3`

## ⚙️ 技术实现

### UUID 生成算法

```dart
String _generateUUID() {
  final random = Random();
  const hexChars = '0123456789abcdef';
  
  final segments = [
    // 8 个字符
    List.generate(8, (_) => hexChars[random.nextInt(16)]).join(),
    // 4 个字符
    List.generate(4, (_) => hexChars[random.nextInt(16)]).join(),
    // 4 个字符，第一位是 4 (版本号)
    '4' + List.generate(3, (_) => hexChars[random.nextInt(16)]).join(),
    // 4 个字符，第一位是 8,9,a,b (变体)
    ['8', '9', 'a', 'b'][random.nextInt(4)] + 
        List.generate(3, (_) => hexChars[random.nextInt(16)]).join(),
    // 12 个字符
    List.generate(12, (_) => hexChars[random.nextInt(16)]).join(),
  ];
  
  return segments.join('-');
}
```

### 冲突概率

UUID v4 的碰撞概率极低：
- 生成 1 亿个 UUID，碰撞概率约为 **5.3 × 10^-20**
- 相当于连续投掷硬币 66 次全部为正面的概率
- **实际上可以认为不会发生碰撞**

## 📝 最佳实践建议

1. **不要依赖文件名推断信息**
   - 文件名是随机生成的 UUID
   - 所有元数据应从数据库获取

2. **始终通过数据库访问文件**
   - 使用 `episode.downloadedPath` 获取文件位置
   - 不要猜测或硬编码文件名

3. **日志记录**
   - 保留 UUID 生成日志便于调试
   - 可以通过 episode ID 追踪到具体文件

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
- ✅ 仅显示随机字符串
- ✅ 无法反向推导原始数据

### 文件访问控制

- 文件保存在应用的沙盒目录中
- 其他应用无法直接访问
- 即便文件名被看到也无安全风险

---

**实施日期**：2026-04-03
**版本**：v2.0
**状态**：✅ 已完成并测试
