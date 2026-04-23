# 任务列表

- [ ] 任务 1：创建设置模块存储规则文件
  - [ ] 子任务 1.1：在 `.agents/rules/` 创建 `settings_storage_rules.md`
  - [ ] 子任务 1.2：定义 shared_preferences 使用规则
  - [ ] 子任务 1.3：定义 flutter_secure_storage 使用规则
  - [ ] 子任务 1.4：定义 Riverpod 状态管理集成最佳实践

- [ ] 任务 2：添加依赖
  - [ ] 子任务 2.1：在 `pubspec.yaml` 添加 `shared_preferences: ^2.5.5`
  - [ ] 子任务 2.2：在 `pubspec.yaml` 添加 `flutter_secure_storage`
  - [ ] 子任务 2.3：运行 `flutter pub get`

- [ ] 任务 3：创建设置数据模型
  - [ ] 子任务 3.1：创建 `lib/domain/entities/settings.dart` 定义 Settings 实体
  - [ ] 子任务 3.2：定义 DownloadSettings 模型
  - [ ] 子任务 3.3：定义 AutoDownloadPolicy 枚举
  - [ ] 子任务 3.4：实现 toJson/fromJson 方法

- [ ] 任务 4：创建设置服务
  - [ ] 子任务 4.1：创建 `lib/data/services/settings_service.dart`
  - [ ] 子任务 4.2：实现 shared_preferences 初始化
  - [ ] 子任务 4.3：实现下载设置保存/加载方法
  - [ ] 子任务 4.4：实现自动下载设置保存/加载方法
  - [ ] 子任务 4.5：实现 JSON 序列化复杂设置

- [ ] 任务 5：创建 Riverpod Provider
  - [ ] 子任务 5.1：创建 `lib/presentation/providers/settings_provider.dart`
  - [ ] 子任务 5.2：实现 SettingsNotifier 状态管理
  - [ ] 子任务 5.3：实现 settingsProvider
  - [ ] 子任务 5.4：实现设置变化流式更新

- [ ] 任务 6：更新下载设置 UI
  - [ ] 子任务 6.1：更新 `download_when_favorite.dart` 连接 Provider
  - [ ] 子任务 6.2：更新 `remove_played_downloads.dart` 连接 Provider
  - [ ] 子任务 6.3：确保实时响应设置变化

- [ ] 任务 7：更新自动下载设置 UI
  - [ ] 子任务 7.1：更新 `auto_download_settings_dropdown.dart` 连接 Provider
  - [ ] 子任务 7.2：确保选项与 AutoDownloadPolicy 枚举一致
  - [ ] 子任务 7.3：确保默认选项为"最新 3 集"

- [ ] 任务 8：集成收藏时下载逻辑
  - [ ] 子任务 8.1：修改收藏功能检查 downloadOnFavorite 设置
  - [ ] 子任务 8.2：如果启用，同时触发下载
  - [ ] 子任务 8.3：如果禁用，仅执行收藏

- [ ] 任务 9：集成播放完自动删除逻辑
  - [ ] 子任务 9.1：在播放完成回调中检查 removePlayedDownloads 设置
  - [ ] 子任务 9.2：如果启用，删除音频文件并更新数据库
  - [ ] 子任务 9.3：如果禁用，不做任何操作

- [ ] 任务 10：集成订阅时自动下载逻辑
  - [ ] 子任务 10.1：在订阅播客时读取 autoDownloadPolicy 设置
  - [ ] 子任务 10.2：根据策略异步执行下载操作
  - [ ] 子任务 10.3：复用现有异步下载功能

## 任务依赖关系

- [任务 2] 无依赖
- [任务 3] 无依赖
- [任务 4] 依赖于 [任务 2, 任务 3]
- [任务 5] 依赖于 [任务 3, 任务 4]
- [任务 6] 依赖于 [任务 5]
- [任务 7] 依赖于 [任务 5]
- [任务 8] 依赖于 [任务 5, 任务 6]
- [任务 9] 依赖于 [任务 5, 任务 6]
- [任务 10] 依赖于 [任务 5, 任务 7]
