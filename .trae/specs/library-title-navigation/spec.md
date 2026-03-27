# Library 页面标题导航功能 Spec

## Why

用户需要在 Library 页面点击播客标题时能够跳转到播客详情页面，同时标题需要有 hover 下划线效果以提升交互体验。此外，MiniPlayer 需要始终展示在页面顶部，确保用户随时可以控制播放。

## What Changes

- 修改 `LibraryShowInfo` 组件，将播客标题改为可点击的链接样式
- 添加 hover 时下划线效果
- 点击标题时导航到播客详情页面
- 确保 MiniPlayer 在 `HomePage` 中始终展示在顶部

## Impact

- Affected specs: 播客详情页面导航、MiniPlayer 展示
- Affected code:
  - `lib/presentation/pages/library/library_show_info/library_show_info.dart`
  - `lib/presentation/pages/library/library_list_item/library_list_item.dart`
  - `lib/presentation/pages/library/library.dart`
  - `lib/presentation/pages/homepage.dart`

## ADDED Requirements

### Requirement: 播客标题点击导航

Library 页面的播客标题需要支持点击跳转到播客详情页面。

#### Scenario: 用户点击播客标题

- **WHEN** 用户在 Library 页面点击播客标题
- **THEN** 页面导航到对应的播客详情页面
- **AND** 导航时传递正确的播客 ID

### Requirement: 标题 Hover 效果

播客标题在鼠标悬停时需要显示下划线效果。

#### Scenario: 鼠标悬停在标题上

- **WHEN** 鼠标悬停在播客标题上
- **THEN** 标题显示下划线
- **AND** 鼠标指针变为手型

#### Scenario: 鼠标移出标题

- **WHEN** 鼠标移出播客标题
- **THEN** 下划线消失

### Requirement: MiniPlayer 始终展示

MiniPlayer 需要始终展示在页面顶部，不受页面内容滚动影响。

#### Scenario: 页面内容滚动

- **WHEN** 用户滚动页面内容
- **THEN** MiniPlayer 保持在顶部固定位置
