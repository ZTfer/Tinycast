# 设置迁移到 Isar Spec

## Why

当前设置存储在 `shared_preferences` 中，多窗口场景下需要频繁调用 `reload()` 才能同步数据，导致性能问题（特别是睡眠定时器每秒检查一次）。迁移到 Isar 后，利用其 `watch()` Stream 机制实现跨窗口自动实时同步，无需手动 reload，性能更优。

## 变更内容

- 创建 `AppSettingsModel` Isar 模型类
- 在 `IsarService` 中注册 Settings Schema
- 迁移 `SettingsService` 使用 Isar 替代 SharedPreferences
- 修改 `SettingsProvider` 使用 Isar `watch()` 实现自动更新
- 添加首次迁移逻辑：从 SharedPreferences 读取现有数据写入 Isar
- 移除 `SettingsService` 中所有 `_reloadPrefs()` 调用
- 移除 `shared_preferences` 依赖

## 影响

- 受影响的规格：settings-storage-rules, sleep-timer, persist-speed-volume
- 受影响的代码：
  - `lib/data/models/app_settings_model.dart`（新增）
  - `lib/data/database/isar_service.dart`
  - `lib/data/services/settings_service.dart`
  - `lib/presentation/providers/settings_provider.dart`
  - `lib/presentation/providers/playback_provider.dart`
  - `pubspec.yaml`

## ADDED Requirements

### 需求：Isar 设置模型

系统应使用 Isar 数据库存储应用设置。

#### 场景：设置模型定义
- **当**定义 AppSettingsModel
- **则**使用 Isar `@collection` 注解
- **并且**包含所有现有设置字段：downloadOnFavorite, removePlayedDownloads, autoDownloadPolicy, playbackSpeed, volume, skipForwardTime, skipBackwardTime, continuousPlay, sleepTimer, sleepTimerEndTimeMillis
- **并且**使用单例模式，只有一条记录（id = 0）

### 需求：实时设置监听

系统应使用 Isar `watch()` 实现设置的自动实时更新。

#### 场景：设置变更自动同步
- **当**某个窗口修改了设置
- **则**Isar `watch()` Stream 会发出新值
- **并且**所有监听该 Stream 的窗口自动收到更新
- **并且**无需手动调用 reload 或广播

#### 场景：睡眠定时器实时检查
- **当**睡眠定时器需要检查设置
- **则**直接从内存中的 SettingsState 读取
- **并且**无需调用 loadSettings() 和 reload()
- **并且**性能开销接近零

### 需求：数据迁移

系统应在首次启动时将 SharedPreferences 数据迁移到 Isar。

#### 场景：首次迁移
- **当**应用首次启动且 Isar 中无设置数据
- **则**从 SharedPreferences 读取现有设置
- **并且**写入 Isar AppSettingsModel
- **并且**标记迁移完成，不再重复迁移

## MODIFIED Requirements

### 需求：现有 SettingsService
当前使用 SharedPreferences 存储设置，包含 `_reloadPrefs()` 方法用于多窗口同步。迁移后：
- 移除所有 SharedPreferences 相关代码
- 移除 `_reloadPrefs()` 方法
- 使用 Isar 的 `put()` 保存设置
- 使用 Isar 的 `watch()` 监听设置变更
- 移除所有 `get*()` 方法中的 `_reloadPrefs()` 调用

### 需求：现有 SettingsProvider
当前使用 `loadSettings()` 加载设置。迁移后：
- 在 `build()` 方法中订阅 Isar `watch()` Stream
- 收到新值时自动更新 state
- 移除 `loadSettings()` 方法（不再需要手动加载）

## REMOVED Requirements

### 需求：SharedPreferences reload 机制
**Reason**: Isar 的 `watch()` Stream 替代了手动 reload 机制
**Migration**: 移除所有 `_reloadPrefs()` 调用，使用 Isar Stream 替代