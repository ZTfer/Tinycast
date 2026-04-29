# Tasks

- [x] Task 1: 创建 AppSettingsModel Isar 模型
  - [x] SubTask 1.1: 创建 `lib/data/models/app_settings_model.dart`
  - [x] SubTask 1.2: 使用 `@collection` 注解，定义所有设置字段
  - [x] SubTask 1.3: 使用 `@Enumerated(EnumType.ordinal)` 处理枚举字段
  - [x] SubTask 1.4: 运行 `dart run build_runner build` 生成 `.g.dart` 文件
  - [x] SubTask 1.5: 在 `IsarService.open()` 中注册 SettingsSchema

- [x] Task 2: 迁移 SettingsService 使用 Isar
  - [x] SubTask 2.1: 移除 SharedPreferences 相关导入和 `_prefs` 字段
  - [x] SubTask 2.2: 修改 `loadSettings()` 为从 Isar 读取
  - [x] SubTask 2.3: 移除 `_reloadPrefs()` 方法
  - [x] SubTask 2.4: 修改所有 `set*()` 方法使用 Isar `put()`
  - [x] SubTask 2.5: 移除所有 `get*()` 方法中的 `_reloadPrefs()` 调用
  - [x] SubTask 2.6: 添加 `watchSettings()` 方法返回 Isar Stream
  - [x] SubTask 2.7: 添加首次迁移逻辑（从 SharedPreferences 迁移到 Isar）

- [x] Task 3: 修改 SettingsProvider 使用 Isar watch
  - [x] SubTask 3.1: 在 `build()` 方法中订阅 `watchSettings()` Stream
  - [x] SubTask 3.2: 收到新值时自动更新 state
  - [x] SubTask 3.3: 移除 `loadSettings()` 方法调用
  - [x] SubTask 3.4: 在 `ref.onDispose()` 中取消 Stream 订阅

- [x] Task 4: 更新 PlaybackNotifier 中的设置读取
  - [x] SubTask 4.1: `_checkSleepTimer()` 改为从 SettingsProvider state 读取
  - [x] SubTask 4.2: `_handleNextEpisodePlayback()` 改为从 SettingsProvider state 读取
  - [x] SubTask 4.3: `_restoreSettingsFromPrefs()` 移除（设置已通过 Provider 加载）

- [x] Task 5: 移除 shared_preferences 依赖
  - [x] SubTask 5.1: 从 `pubspec.yaml` 移除 `shared_preferences`
  - [x] SubTask 5.2: 运行 `flutter pub get`

# Task Dependencies

- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 2]
- [Task 4] depends on [Task 3]
- [Task 5] depends on [Task 2]