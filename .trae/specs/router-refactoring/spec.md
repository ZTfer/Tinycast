# 路由系统重构 Spec

## 为什么

当前路由系统存在以下问题：
1. 新窗口打开逻辑（settings 和 subscribe）直接在 sidebar 组件中处理，没有使用统一的 router 系统
2. body.dart 使用字符串匹配的 switch 语句来切换页面，没有使用 app_router 中定义的路由方法
3. 路由逻辑分散，不利于测试和维护
4. 不符合 MVVM 架构规范，导航逻辑应该集中管理

## 变更内容

- 将新窗口打开逻辑从 sidebar.dart 移动到 app_router.dart
- 更新 sidebar.dart 使用 router 的新窗口方法
- 更新 body.dart 使用 router 的导航方法（可选，用于统一页面切换逻辑）

## 影响

- 受影响的规格：project-architecture
- 受影响的代码：
  - lib/presentation/widgets/molecules/sidebar/sidebar.dart
  - lib/presentation/pages/body.dart
  - lib/core/router/app_router.dart

## 新增需求

### 需求：统一路由管理

系统应提供统一的路由管理，包括页面导航和新窗口打开。

#### 场景：打开设置窗口

- **当**用户点击侧边栏的设置按钮
- **则**系统应通过 router 打开新的设置窗口
- **并且**窗口参数通过 router 统一管理

#### 场景：打开订阅窗口

- **当**用户点击侧边栏的订阅按钮
- **则**系统应通过 router 打开新的订阅窗口
- **并且**窗口参数通过 router 统一管理

#### 场景：页面导航

- **当**用户在侧边栏切换页面
- **则**系统应通过 router 的导航方法进行页面切换
- **并且**使用 app_router.dart 中定义的路由常量

## 修改的需求

### 需求：新窗口打开逻辑

将 sidebar.dart 中的新窗口打开逻辑移动到 app_router.dart。

#### 场景：移除 sidebar 中的窗口逻辑

- **当**重构代码
- **则**从 sidebar.dart 移除 _openSettingsWindow 和 _openSubscribeWindow 方法
- **并且**改为调用 router 的对应方法

#### 场景：在 router 中添加窗口方法

- **当**添加新方法
- **则**在 app_router.dart 中添加 openSettingsWindow 和 openSubscribeWindow 方法
- **并且**使用 desktop_multi_window 包创建窗口

### 需求：页面导航逻辑（可选）

更新 body.dart 使用 router 的导航方法，替代字符串匹配的 switch 语句。

#### 场景：使用路由常量

- **当**重构页面切换逻辑
- **则**使用 AppRoutes 中定义的常量
- **并且**通过 router 的 navigateTo 方法进行导航

## 移除的需求

无
