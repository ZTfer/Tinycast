# 依赖项升级 Spec

## Why
项目中存在 31 个依赖包有可用更新版本，包括主要版本升级和次要版本升级。为了确保应用使用最新的功能、安全补丁和性能改进，需要升级所有依赖项。

## What Changes
- 升级所有具有可用更新的依赖包到最新版本
- **BREAKING**: file_picker 从 10.x 升级到 11.x，可能需要 API 调整
- **BREAKING**: package_info_plus 从 9.x 升级到 10.x，可能需要 API 调整
- **BREAKING**: vector_math 从 2.2.x 升级到 2.3.x，可能需要 API 调整
- **BREAKING**: wakelock_plus 从 1.5.x 升级到 1.6.x，可能需要 API 调整
- **BREAKING**: win32 从 5.x 升级到 6.x，可能需要 API 调整
- 修复因 API 变更导致的代码兼容性问题
- 运行分析器确保无错误和警告

## Impact
- Affected specs: 所有使用到已升级依赖的功能模块
- Affected code: 
  - pubspec.yaml - 依赖版本声明
  - 使用 file_picker 的文件
  - 使用 package_info_plus 的文件
  - 使用 vector_math 的文件
  - 使用 wakelock_plus 的文件
  - 使用 win32 的文件（如果有 Windows 平台代码）

## ADDED Requirements

### Requirement: 依赖项升级
系统 SHALL 将所有依赖项升级到最新兼容版本。

#### Scenario: 升级依赖
- **WHEN** 用户运行 `flutter pub outdated`
- **THEN** 显示所有依赖已是最新版本或没有更多可用更新

### Requirement: 代码兼容性更新
系统 SHALL 更新代码以适配依赖的破坏性变更。

#### Scenario: file_picker API 变更
- **WHEN** file_picker 升级到 11.x
- **THEN** 所有调用 file_picker 的代码应使用新的 API

#### Scenario: package_info_plus API 变更
- **WHEN** package_info_plus 升级到 10.x
- **THEN** 所有调用 package_info_plus 的代码应使用新的 API

## REMOVED Requirements

无
