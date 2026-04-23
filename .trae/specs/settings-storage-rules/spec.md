# 设置模块存储规则与通用设置功能 Spec

## Why

当前设置模块尚未实现完整的持久化存储，需要建立统一的存储规则：普通设置使用 shared_preferences，敏感信息使用 flutter_secure_storage。同时需要实现通用设置功能（收藏时下载、播放完自动删除、自动下载策略）。

## What Changes

- 在 `.agents/rules/` 创建设置模块存储规则文件
- 添加 `shared_preferences: ^2.5.5` 和 `flutter_secure_storage` 依赖
- 实现设置状态管理 Provider（结合 Riverpod）
- 实现下载设置功能（收藏时下载、播放完自动删除）
- 实现自动下载设置功能（订阅时自动下载策略）
- 更新现有设置 UI 组件连接状态管理

## Impact

- 受影响的规格：settings-management, download-management
- 受影响的代码：
  - `.agents/rules/settings_storage_rules.md` (新建)
  - `pubspec.yaml` (添加依赖)
  - `lib/data/services/settings_service.dart` (新建)
  - `lib/presentation/providers/settings_provider.dart` (新建)
  - `lib/domain/entities/settings.dart` (新建)
  - `lib/presentation/features/settings/` (更新)

## ADDED Requirements

### Requirement: 设置存储规则

系统 SHALL 建立统一的设置存储规则。

#### Scenario: 普通设置存储
- **WHEN** 存储普通设置（主题、开关、倍速等）
- **THEN** 使用 shared_preferences 存储
- **AND** 对于复杂设置组，封装成类，转 JSON 字符串存入

#### Scenario: 敏感信息存储
- **WHEN** 存储敏感信息（如 Auth Token、用户密码）
- **THEN** 使用 flutter_secure_storage 存储
- **AND** 数据存储于 iOS Keychain / Android Keystore

#### Scenario: 状态管理集成
- **WHEN** 设置发生变化
- **THEN** 通过 Riverpod Provider 通知 UI
- **AND** UI 实时响应设置变化

### Requirement: 通用设置数据模型

系统 SHALL 定义通用设置的数据模型。

#### Scenario: 下载设置模型
- **WHEN** 定义下载设置
- **THEN** 包含以下字段：
  - `downloadOnFavorite: bool` - 收藏时下载
  - `removePlayedDownloads: bool` - 播放完自动删除

#### Scenario: 自动下载设置模型
- **WHEN** 定义自动下载设置
- **THEN** 包含以下字段：
  - `autoDownloadPolicy: AutoDownloadPolicy` - 自动下载策略
  - 枚举值：`off`, `latest1`, `latest2`, `latest3`, `latest5`, `latest10`, `past24h`, `past7d`, `past14d`, `past30d`, `all`
  - 默认值：`latest3`

### Requirement: 设置服务

系统 SHALL 提供设置持久化服务。

#### Scenario: 保存下载设置
- **WHEN** 用户更改下载设置
- **THEN** 通过 shared_preferences 保存
- **AND** 通过 Riverpod 通知 UI 更新

#### Scenario: 保存自动下载设置
- **WHEN** 用户更改自动下载策略
- **THEN** 通过 shared_preferences 保存
- **AND** 通过 Riverpod 通知 UI 更新

#### Scenario: 加载设置
- **WHEN** 应用启动
- **THEN** 从 shared_preferences 加载所有设置
- **AND** 应用默认值（如果未设置）

### Requirement: 收藏时下载功能

系统 SHALL 实现收藏时下载功能。

#### Scenario: 启用收藏时下载
- **WHEN** 用户勾选"收藏时下载"
- **AND** 用户通过下拉菜单收藏 episode
- **THEN** 执行收藏操作
- **AND** 同时开始下载该 episode

#### Scenario: 禁用收藏时下载
- **WHEN** 用户未勾选"收藏时下载"
- **AND** 用户通过下拉菜单收藏 episode
- **THEN** 仅执行收藏操作
- **AND** 不下载 episode

### Requirement: 播放完自动删除功能

系统 SHALL 实现播放完自动删除功能。

#### Scenario: 启用播放完自动删除
- **WHEN** 用户勾选"播放完自动删除"
- **AND** episode 播放完成
- **THEN** 自动删除对应的音频文件
- **AND** 更新数据库中文件记录

#### Scenario: 禁用播放完自动删除
- **WHEN** 用户未勾选"播放完自动删除"
- **AND** episode 播放完成
- **THEN** 不自动删除音频文件

### Requirement: 自动下载策略

系统 SHALL 实现订阅时自动下载策略。

#### Scenario: 关闭自动下载
- **WHEN** 用户选择"关闭"
- **AND** 用户订阅新播客
- **THEN** 不自动下载任何音频文件

#### Scenario: 最新 N 集自动下载
- **WHEN** 用户选择"最新 1/2/3/5/10 集"
- **AND** 用户订阅新播客
- **THEN** 自动下载对应播客最新 N 集的音频文件

#### Scenario: 过去 N 天自动下载
- **WHEN** 用户选择"过去 24 小时/7 天/14 天/30 天"
- **AND** 用户订阅新播客
- **THEN** 自动下载对应播客过去 N 天内所有 episode 的音频文件

#### Scenario: 所有单集自动下载
- **WHEN** 用户选择"所有单集"
- **AND** 用户订阅新播客
- **THEN** 自动下载对应播客所有 episode 的音频文件

## MODIFIED Requirements

### Requirement: 现有设置页面
- 更新 `auto_download_settings_dropdown.dart` 连接 Riverpod Provider
- 更新 `download_settings/` 下的组件连接 Riverpod Provider
- 确保所有设置变更实时反映到 UI

## REMOVED Requirements

无
