# Mobile TabBar 路由功能 Spec

## Why
移动端已实现 TabBarItem 组件基础功能，但尚未实现完整的 TabBar 容器组件及其路由切换逻辑。需要参照桌面端 Sidebar 的路由功能逻辑，实现移动端底部 TabBar，支持 queue 和 library 页面切换。

## What Changes
- 实现 `tabbar.dart` 移动端底部 TabBar 容器组件
- 集成路由切换逻辑，支持 queue 和 library 页面展示
- 使用 TabBarItem 组件作为子按钮

## Impact
- Affected specs: mobile-platform-support
- Affected code:
  - lib/presentation/widgets/organisms/tabbar/tabbar.dart (新增)
  - lib/presentation/widgets/organisms/tabbar/tabbar_item.dart (已实现)
  - lib/core/router/app_routes.dart (引用)
  - lib/core/router/app_router.dart (引用)

## ADDED Requirements
### Requirement: 移动端 TabBar 路由切换
系统 SHALL 在移动端底部提供 TabBar 导航组件，支持通过点击切换不同页面。

#### Scenario: 切换到 Queue 页面
- **WHEN** 用户点击 TabBar 上的 Queue 按钮
- **THEN** 显示 Queue 页面，该按钮处于 active 状态

#### Scenario: 切换到 Library 页面
- **WHEN** 用户点击 TabBar 上的 Library 按钮
- **THEN** 显示 Library 页面，该按钮处于 active 状态

#### Scenario: 初始状态
- **WHEN** 移动端应用启动
- **THEN** TabBar 默认选中 Queue 页面

## MODIFIED Requirements
**无**

## REMOVED Requirements
**无**
