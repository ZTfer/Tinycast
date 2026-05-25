# Mobile Platform Support Spec

## Why
当前 TinyCast 项目仅支持 macOS/Windows/Linux 桌面平台，使用了大量桌面专属包（window_manager、desktop_multi_window、flutter_acrylic），导致无法在 iOS/Android 移动端编译运行。需要调整 main.dart 及相关文件，使项目能够在移动端正常 build 和运行。

## What Changes
- **main.dart**: 添加平台检测逻辑，移动端使用 MobileHome 作为首页，跳过桌面窗口系统初始化
- **multi_window.dart**: 将窗口初始化函数（initMainWindow 等）添加平台条件判断，移动端跳过 window_manager 调用
- **window_utils.dart 导出文件**: 使用条件导出机制，移动端使用空实现版本
- **homepage.dart**: 桌面端主页保持不变，但需要确保其仅在桌面平台使用

## Impact
- Affected specs: 多窗口功能（桌面端保留，移动端不支持多窗口）
- Affected code: lib/main.dart, lib/multi_window.dart, lib/window_utils.dart, lib/src/window_utils_*.dart
- 新增移动端入口文件引用

## ADDED Requirements
### Requirement: 移动端平台检测与路由
系统 SHALL 在应用启动时检测平台类型，并根据平台选择对应的主页组件和初始化流程。

#### Scenario: 移动端启动
- **WHEN** 应用在 iOS 或 Android 设备上启动
- **THEN** 使用 MobileHome 作为首页，跳过所有桌面窗口系统初始化

#### Scenario: 桌面端启动
- **WHEN** 应用在 macOS/Windows/Linux 上启动
- **THEN** 使用现有的 HomePage 和多窗口系统，行为保持不变

## MODIFIED Requirements
### Requirement: main.dart 启动逻辑
main() 函数 SHALL 根据平台类型分支：移动端直接 runApp，桌面端继续使用 WindowController 和多窗口机制。

### Requirement: multi_window.dart 桌面窗口初始化
initMainWindow()、initSettingsWindow()、initSubscribeWindow()、initEpisodeDetailWindow() 函数 SHALL 仅在桌面平台执行 window_manager 相关操作，移动端调用时直接返回。

## REMOVED Requirements
**无**。所有桌面端功能保留，仅添加移动端支持。
