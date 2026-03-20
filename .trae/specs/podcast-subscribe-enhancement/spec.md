# 播客订阅完善和 Library 空状态优化 Spec

## Why

当前播客搜索和订阅功能已经基本实现，但存在以下问题：

1. SubscribeEpisodeAddButton 组件不支持自定义图标，限制了组件的复用性
2. Library 页面的空状态设计不够友好，缺少引导用户订阅播客的交互元素
3. 需要确保添加按钮的交互逻辑和状态显示更加清晰

## What Changes

- 改进 SubscribeEpisodeAddButton 组件，支持传入自定义图标
- 优化 Library 页面的空状态展示，参考 queue_empty_page 的设计风格
- 创建 LibraryEmptyPage 组件，包含空状态信息和操作按钮
- 确保播客订阅流程的完整性和用户体验

## Impact

- Affected specs: podcast-search-and-subscribe（扩展订阅功能）
- Affected code:
  - lib/presentation/pages/subscribe/subscribe_search_result/subscribe_episode_add_button.dart
  - lib/presentation/pages/library/library.dart
  - lib/presentation/pages/library/library_empty_page/（新建目录）
  - lib/presentation/pages/library/library_empty_page/library_empty_page.dart（新建）
  - lib/presentation/pages/library/library_empty_page/library_empty_info.dart（新建）
  - lib/presentation/pages/library/library_empty_page/library_empty_control_bar/（新建目录）
  - lib/presentation/pages/library/library_empty_page/library_empty_control_bar/library_empty_control_bar.dart（新建）
  - lib/presentation/pages/library/library_empty_page/library_empty_control_bar/library_empty_button.dart（新建）

## ADDED Requirements

### Requirement: SubscribeEpisodeAddButton 支持自定义图标

系统 SHALL 允许 SubscribeEpisodeAddButton 组件接收自定义图标参数。

#### Scenario: 使用自定义图标

- **WHEN** 调用 SubscribeEpisodeAddButton 时传入 icon 参数
- **THEN** 按钮在未订阅状态下显示自定义图标
- **THEN** 已订阅状态仍显示 check 图标
- **THEN** 加载状态显示加载指示器

#### Scenario: 使用默认图标

- **WHEN** 调用 SubscribeEpisodeAddButton 时未传入 icon 参数
- **THEN** 按钮在未订阅状态下显示默认的 plus 图标
- **THEN** 已订阅状态显示 check 图标
- **THEN** 加载状态显示加载指示器

### Requirement: Library 空状态页面

系统 SHALL 在 Library 页面为空时展示友好的空状态页面。

#### Scenario: 显示空状态页面

- **WHEN** Library 页面没有已订阅的播客
- **THEN** 显示 LibraryEmptyPage 组件
- **THEN** 展示空状态图标和提示文字
- **THEN** 展示操作按钮（RSS 订阅、搜索播客）
- **THEN** 提供引导用户订阅播客的交互

#### Scenario: 空状态页面布局

- **WHEN** 用户查看空状态页面
- **THEN** 页面布局参考 queue_empty_page 的设计风格
- **THEN** 包含图标占位区域（120x120）
- **THEN** 包含主标题和副标题
- **THEN** 包含操作按钮栏

### Requirement: Library 空状态操作按钮

系统 SHALL 在 Library 空状态页面提供操作按钮。

#### Scenario: RSS 订阅按钮

- **WHEN** 用户点击 RSS 订阅按钮
- **THEN** 导航到 RSS 订阅页面
- **THEN** 用户可以输入 RSS URL 订阅播客

#### Scenario: 搜索播客按钮

- **WHEN** 用户点击搜索播客按钮
- **THEN** 导航到搜索页面
- **THEN** 用户可以搜索和发现播客

## MODIFIED Requirements

### Requirement: 播客订阅流程

播客订阅流程 SHALL 确保数据一致性和用户体验。

#### Scenario: 添加播客到数据库

- **WHEN** 用户点击添加按钮
- **THEN** 系统检查数据库中是否已存在该播客（通过 RSS URL）
- **THEN** 如果不存在，显示加载状态
- **THEN** 解析 RSS 并保存播客和节目信息到数据库
- **THEN** 保存成功后，按钮状态更新为已订阅
- **THEN** 如果已存在，按钮保持已订阅状态

#### Scenario: 批量添加播客

- **WHEN** 用户点击"全部关注"按钮
- **THEN** 系统遍历所有搜索结果
- **THEN** 对每个播客检查数据库中是否已存在
- **THEN** 只添加不存在的播客
- **THEN** 显示每个播客的添加状态
- **THEN** 全部完成后更新按钮状态

## REMOVED Requirements

无
