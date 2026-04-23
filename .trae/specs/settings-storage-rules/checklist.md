# 检查清单

## 规则文件
- [ ] `.agents/rules/settings_storage_rules.md` 已创建
- [ ] 规则包含 shared_preferences 使用规范
- [ ] 规则包含 flutter_secure_storage 使用规范
- [ ] 规则包含 Riverpod 状态管理集成最佳实践

## 依赖
- [ ] shared_preferences: ^2.5.5 已添加到 pubspec.yaml
- [ ] flutter_secure_storage 已添加到 pubspec.yaml
- [ ] flutter pub get 执行成功

## 数据模型
- [ ] Settings 实体类已创建
- [ ] DownloadSettings 模型已定义
- [ ] AutoDownloadPolicy 枚举已定义
- [ ] toJson/fromJson 方法已实现

## 设置服务
- [ ] SettingsService 已创建
- [ ] shared_preferences 初始化正常
- [ ] 下载设置保存/加载方法正常
- [ ] 自动下载设置保存/加载方法正常
- [ ] JSON 序列化正常工作

## Riverpod Provider
- [ ] SettingsNotifier 已创建
- [ ] settingsProvider 已创建
- [ ] 设置状态管理正常
- [ ] 设置变化流式更新正常

## 下载设置 UI
- [ ] download_when_favorite.dart 已连接 Provider
- [ ] remove_played_downloads.dart 已连接 Provider
- [ ] 设置变化实时反映到 UI

## 自动下载设置 UI
- [ ] auto_download_settings_dropdown.dart 已连接 Provider
- [ ] 选项与 AutoDownloadPolicy 枚举一致
- [ ] 默认选项为"最新 3 集"

## 收藏时下载集成
- [ ] 收藏功能检查 downloadOnFavorite 设置
- [ ] 启用时同时触发下载
- [ ] 禁用时仅执行收藏

## 播放完自动删除集成
- [ ] 播放完成回调检查 removePlayedDownloads
- [ ] 启用时删除音频文件并更新数据库
- [ ] 禁用时不做操作

## 订阅时自动下载集成
- [ ] 订阅播客时读取 autoDownloadPolicy
- [ ] 根据策略异步执行下载
- [ ] 复用现有异步下载功能
