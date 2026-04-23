# 检查清单

## 规则文件
- [x] `.agents/rules/settings_storage_rules.md` 已创建
- [x] 规则包含 shared_preferences 使用规范
- [x] 规则包含 flutter_secure_storage 使用规范
- [x] 规则包含 Riverpod 状态管理集成最佳实践

## 依赖
- [x] shared_preferences: ^2.5.5 已添加到 pubspec.yaml
- [x] flutter_secure_storage 已添加到 pubspec.yaml
- [x] flutter pub get 执行成功

## 数据模型
- [x] AppSettings 实体类已创建
- [x] AutoDownloadPolicy 枚举已定义
- [x] toJson/fromJson 方法已实现

## 设置服务
- [x] SettingsService 已创建
- [x] shared_preferences 初始化正常
- [x] 下载设置保存/加载方法正常
- [x] 自动下载设置保存/加载方法正常
- [x] JSON 序列化正常工作

## Riverpod Provider
- [x] SettingsNotifier 已创建
- [x] settingsProvider 已创建
- [x] 设置状态管理正常
- [x] 设置变化流式更新正常

## 下载设置 UI
- [x] download_when_favorite.dart 已连接 Provider
- [x] remove_played_downloads.dart 已连接 Provider
- [x] 设置变化实时反映到 UI

## 自动下载设置 UI
- [x] auto_download_settings_dropdown.dart 已连接 Provider
- [x] 选项与 AutoDownloadPolicy 枚举一致
- [x] 默认选项为"最新 3 集"
- [x] auto_download_settings.dart 父组件已连接 Provider

## 收藏时下载集成
- [x] 收藏功能检查 downloadOnFavorite 设置
- [x] 启用时同时触发下载
- [x] 禁用时仅执行收藏

## 播放完自动删除集成
- [x] 播放完成回调检查 removePlayedDownloads 设置
- [x] 启用时删除音频文件并更新数据库
- [x] 禁用时不做任何操作

## 订阅时自动下载集成
- [x] 订阅播客时读取 autoDownloadPolicy
- [x] 根据策略异步执行下载
- [x] 复用现有异步下载功能

## 代码质量
- [x] flutter analyze 通过，无错误
