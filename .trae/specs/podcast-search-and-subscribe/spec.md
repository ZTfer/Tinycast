# 播客搜索和订阅功能 Spec

## Why

当前 RSS 订阅功能只支持直接输入完整的 RSS URL，用户体验不够友好。用户希望能够通过输入域名或部分 URL 来搜索和发现播客，并能够批量订阅多个播客。

## What Changes

- 改进 RSS 输入框，支持输入包含或不包含协议的链接
- 实现播客搜索服务，支持从域名解析 RSS 链接
- 实现搜索结果展示功能
- 实现单个播客添加功能
- 实现批量添加播客功能
- 改进播客信息展示组件，支持封面图 lazyload
- 改进"全部关注"按钮为可交互的按钮组件

## Impact

- Affected specs: rss-subscription（扩展订阅功能）
- Affected code:
  - lib/presentation/pages/subscribe/subscribe_by_rss/rss_input_material.dart
  - lib/presentation/pages/subscribe/subscribe_action_bar/subscribe_action_bar.dart
  - lib/presentation/pages/subscribe/subscribe_search_result/subscribe_search_result.dart
  - lib/presentation/pages/subscribe/subscribe_search_result/subscribe_search_list.dart
  - lib/presentation/pages/subscribe/subscribe_search_result/subscribe_search_list_title.dart
  - lib/presentation/pages/subscribe/subscribe_search_result/subscribe_episode_info.dart
  - lib/presentation/pages/subscribe/subscribe_search_result/subscribe_episode_add_button.dart
  - lib/data/services/podcast_search_service.dart（新建）
  - lib/presentation/providers/podcast_search_provider.dart（新建）

## ADDED Requirements

### Requirement: RSS URL 输入增强

系统 SHALL 支持用户输入包含或不包含协议的 RSS URL。

#### Scenario: 输入包含协议的 URL

- **WHEN** 用户输入包含 `https://` 或 `http://` 的完整 URL
- **THEN** 系统直接使用该 URL 进行解析

#### Scenario: 输入不包含协议的 URL

- **WHEN** 用户输入不包含协议的 URL（如 `example.com/podcast.xml` 或 `example.com`）
- **THEN** 系统自动添加 `https://` 前缀

### Requirement: 播客搜索服务

系统 SHALL 提供播客搜索服务，支持从域名或 URL 解析播客信息。

#### Scenario: 直接输入 RSS XML 文件

- **WHEN** 用户输入的 URL 包含 `.xml` 文件
- **THEN** 系统直接解析该 XML 文件，提取播客信息

#### Scenario: 输入域名

- **WHEN** 用户只输入域名（如 `example.com`）
- **THEN** 系统获取页面 HTML，检查 `<head>` 中是否包含 `type="application/rss+xml"` 的 `<link>` 标签
- **THEN** 如果找到 RSS 链接，解析该 RSS 文件
- **THEN** 如果没有找到 RSS 链接，检查 `href` 属性中是否包含 `.xml` 文件链接

#### Scenario: 搜索失败

- **WHEN** 系统无法从输入的 URL 找到有效的播客 RSS
- **THEN** 返回错误状态，展示错误提示页面

### Requirement: 搜索结果展示

系统 SHALL 根据搜索结果展示不同的页面状态。

#### Scenario: 搜索成功

- **WHEN** 搜索成功并找到播客
- **THEN** 展示 SubscribeSearchList 组件，显示搜索到的播客列表

#### Scenario: header内容搜索失败

- **WHEN** 搜索失败或未找到播客
- **THEN** 展示 SubscribeSearchResultError 组件，显示错误提示

#### Scenario: 搜索中

- **WHEN** 正在搜索播客
- **THEN** 展示加载状态指示器

### Requirement: 单个播客添加

系统 SHALL 支持用户添加单个播客到数据库。

#### Scenario: 添加新播客

- **WHEN** 用户点击播客的添加按钮
- **THEN** 系统检查数据库中是否已存在该播客（通过 RSS URL）
- **THEN** 如果不存在，将播客信息保存到数据库
- **THEN** 如果已存在，显示提示信息

#### Scenario: 添加按钮状态

- **WHEN** 播客已存在于数据库
- **THEN** 添加按钮显示为禁用状态或已订阅状态
- **WHEN** 正在添加播客
- **THEN** 添加按钮显示加载状态

### Requirement: 批量添加播客

系统 SHALL 支持用户批量添加所有搜索结果中的播客。

#### Scenario: 批量添加新播客

- **WHEN** 用户点击"全部关注"按钮
- **THEN** 系统遍历所有搜索结果
- **THEN** 对每个播客检查数据库中是否已存在
- **THEN** 只添加不存在的播客
- **THEN** 显示添加进度和结果统计

#### Scenario: 所有播客已订阅

- **WHEN** 所有搜索结果中的播客都已存在于数据库
- **THEN** 显示提示信息，无需重复添加

### Requirement: 播客信息展示

系统 SHALL 正确展示播客的封面图、标题和描述。

#### Scenario: 展示播客信息

- **WHEN** 搜索结果包含播客信息
- **THEN** SubscribeEpisodeInfo 组件展示播客封面图（支持 lazyload）
- **THEN** 展示播客标题
- **THEN** 展示播客描述（description）
- **THEN** 如果封面图加载失败，显示默认占位图

### Requirement: 批量操作按钮

系统 SHALL 提供一个可交互的批量操作按钮。

#### Scenario: 按钮样式

- **WHEN** 用户查看批量操作按钮
- **THEN** 按钮样式与 SearchToolbarDeleteButton 类似，但不包含图标
- **THEN** 按钮支持悬停和点击状态的视觉反馈

#### Scenario: 按钮交互

- **WHEN** 用户点击批量操作按钮
- **THEN** 触发批量添加播客的操作

## MODIFIED Requirements

### Requirement: RSS 订阅界面

RSS 订阅界面 SHALL 支持搜索和订阅两种模式。

#### Scenario: 搜索模式

- **WHEN** 用户在 RSS 输入框中输入 URL 并点击搜索按钮
- **THEN** 系统进入搜索模式
- **THEN** 展示搜索结果页面
- **THEN** 用户可以查看和添加搜索到的播客

#### Scenario: 订阅模式

- **WHEN** 用户在 RSS 输入框中输入 URL 并点击订阅按钮
- **THEN** 系统进入订阅模式
- **THEN** 直接订阅该 RSS 链接对应的播客

## REMOVED Requirements

无
