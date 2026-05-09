# macOS Window Frosted Glass Effect Spec

## Why
使用 `macos_window_utils` 替代 `window_manager` 实现窗口毛玻璃效果，以提供更原生、更高质量的 macOS 视觉体验，同时将窗口相关代码单独管理，提升可维护性。

## What Changes
- 添加 `macos_window_utils` 依赖到 `pubspec.yaml`
- 创建新的 `lib/macos_window_utils.dart` 文件，集中管理 macOS 窗口特效
- 在 `macos_window_utils.dart` 中实现窗口毛玻璃效果配置方法
- 更新相关窗口初始化逻辑以使用新的毛玻璃效果

## Impact
- Affected specs: window-management, multi-window
- Affected code: `lib/multi_window.dart`, `pubspec.yaml`, 新增 `lib/macos_window_utils.dart`

## ADDED Requirements
### Requirement: macOS Window Frosted Glass Effect
系统 SHALL 使用 `macos_window_utils` 包实现 macOS 窗口毛玻璃效果。

#### Scenario: 窗口启用毛玻璃效果
- **WHEN** 应用初始化窗口时
- **THEN** 窗口应当显示原生 macOS 毛玻璃背景效果

### Requirement: Separate Window Utils File
系统 SHALL 将 `macos_window_utils` 相关代码集中在 `lib/macos_window_utils.dart` 文件中管理。

#### Scenario: 文件结构
- **WHEN** 开发者需要管理 macOS 窗口特效代码
- **THEN** 所有相关代码应当在 `macos_window_utils.dart` 中找到

## MODIFIED Requirements
### Requirement: Window Initialization
窗口初始化流程 SHALL 集成毛玻璃效果设置。
