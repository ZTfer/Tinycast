# Podcast Feed 刷新机制 Spec

## Why

当前应用订阅播客后，不会自动更新 RSS 源获取新内容。用户需要手动进入播客详情页并刷新才能看到新剧集。需要一个智能的后台刷新机制，自动检测并下载新剧集，同时平衡及时性与资源消耗（电量、流量）。

## What Changes

- 在 Podcast 模型新增 `lastFetchedAt` 字段记录每次刷新时间
- 新增 `FeedRefreshService` 服务实现增量更新逻辑
- 新增 `FeedRefreshScheduler` 调度器根据策略和网络状态决定刷新时机
- 在 AppSettings 新增刷新频率和用户偏好设置
- 在 PodcastRepository 新增 `refreshPodcastFeed` 方法实现增量拉取
- 在 Library 页面支持下拉刷新触发所有播客的更新
- 新增刷新状态通知机制，UI 可实时展示刷新进度

## Impact

- 受影响的规格：RSS 订阅、播客管理、设置管理
- 受影响的代码：
  - Data 层：`podcast_model.dart`、`local_podcast_datasource.dart`、`podcast_repository_impl.dart`
  - Domain 层：`podcast.dart`、`podcast_repository.dart`、`app_settings.dart`
  - Presentation 层：`library.dart`、`podcast_provider.dart`、设置页面
  - Services 层：新增 `feed_refresh_service.dart`、`feed_refresh_scheduler.dart`

## ADDED Requirements

### Requirement: 增量更新机制

系统应以增量更新为核心，仅获取并保存自上次刷新以来新增的剧集，避免重复下载和处理已有数据。

#### Scenario: 首次刷新（无历史记录）

- **WHEN** 用户首次对某个播客执行刷新
- **THEN** 系统解析完整的 RSS 源
- **AND** 保存所有剧集到数据库
- **AND** 记录 `lastFetchedAt` 为当前时间

#### Scenario: 后续刷新（有历史记录）

- **WHEN** 用户对已订阅播客执行刷新且存在 `lastFetchedAt`
- **THEN** 系统解析 RSS 源并对比剧集的 `guid` 或 `pubDate`
- **AND** 仅保存新增的剧集（数据库中不存在的）
- **AND** 更新播客的 `episodeCount`、`lastUpdated`、`lastFetchedAt`
- **AND** 返回新增剧集数量

#### Scenario: 无新内容

- **WHEN** RSS 源中没有新增剧集
- **THEN** 系统不写入数据库
- **AND** 更新 `lastFetchedAt`
- **AND** 返回新增数量为 0

### Requirement: 网络状态智能判断

系统应根据当前网络环境智能决定是否执行刷新，避免在高成本网络下消耗流量。

#### Scenario: WiFi 网络

- **WHEN** 设备连接 WiFi
- **THEN** 允许正常执行所有刷新操作
- **AND** 可执行大文件下载（如果用户设置允许）

#### Scenario: 蜂窝移动网络

- **WHEN** 设备使用蜂窝网络
- **THEN** 仅执行轻量级 RSS 元数据拉取（XML 通常 < 100KB）
- **AND** 不自动下载音频文件（除非用户明确允许移动网络下载）

#### Scenario: 无网络

- **WHEN** 设备无网络连接
- **THEN** 跳过所有刷新操作
- **AND** 记录网络不可用状态
- **AND** 不显示错误提示给用户（静默跳过）

### Requirement: 后台资源限制规避

系统应遵守操作系统的后台执行限制，避免频繁后台活动导致续航下降。

#### Scenario: macOS 后台刷新

- **WHEN** 应用处于后台或最小化
- **THEN** 使用 NSTimer 或 BGAppRefreshTask（如可用）进行定期刷新
- **AND** 刷新间隔不少于 15 分钟（遵守系统限制）
- **AND** 如果用户设置"仅前台刷新"，则不在后台执行

#### Scenario: 电池优化模式

- **WHEN** 系统电量低于 20% 或处于低电量模式
- **THEN** 暂停所有后台刷新
- **AND** 等待电量恢复或用户手动触发

#### Scenario: 防抖动机制

- **WHEN** 同一播客在 5 分钟内被多次触发刷新
- **THEN** 仅执行第一次刷新
- **AND** 忽略后续的刷新请求直到冷却时间结束

### Requirement: 用户偏好设置

系统应允许用户自定义刷新频率和行为。

#### Scenario: 刷新频率设置

- **WHEN** 用户在设置页面选择刷新频率
- **THEN** 可选值：手动、每 1 小时、每 3 小时、每 6 小时、每 12 小时、每 24 小时
- **AND** 默认值：每 6 小时
- **AND** 设置持久化到 AppSettings

#### Scenario: 移动网络限制

- **WHEN** 用户设置"仅 WiFi 刷新"
- **THEN** 系统仅在 WiFi 网络下执行自动刷新
- **AND** 移动网络下仅允许手动触发刷新

#### Scenario: 刷新通知

- **WHEN** 刷新完成且发现新内容
- **THEN** 可选发送系统通知告知用户新剧集数量
- **AND** 用户可关闭此通知功能

### Requirement: 刷新调度器

系统应维护一个智能调度器，根据用户设置和网络状态决定刷新时机。

#### Scenario: 定时触发

- **WHEN** 到达设定的刷新间隔
- **THEN** 调度器检查网络状态
- **AND** 检查电池状态
- **AND** 如果条件满足，遍历所有已订阅播客执行刷新

#### Scenario: 手动触发

- **WHEN** 用户在 Library 页面下拉刷新
- **THEN** 立即对所有已订阅播客执行刷新
- **AND** 忽略刷新间隔和冷却时间限制

#### Scenario: 单播客刷新

- **WHEN** 用户在播客详情页点击刷新
- **THEN** 仅对该播客执行刷新
- **AND** 忽略刷新间隔限制（手动触发优先）

### Requirement: 并发控制

系统应控制并发刷新数量，避免同时发起过多网络请求。

#### Scenario: 批量刷新

- **WHEN** 需要刷新多个播客（如 Library 下拉刷新）
- **THEN** 使用队列机制，最多同时执行 3 个刷新任务
- **AND** 每个播客刷新完成后，从队列取出下一个
- **AND** 所有任务完成后，返回总新增剧集数量

### Requirement: 错误处理与重试

系统应优雅处理刷新过程中的错误，并提供合理的重试策略。

#### Scenario: 网络超时

- **WHEN** RSS 请求超时
- **THEN** 记录错误日志
- **AND** 更新该播客的 `lastFetchedAt`（避免频繁重试无效源）
- **AND** 在批量刷新中继续处理下一个播客（不中断整个流程）

#### Scenario: RSS 解析失败

- **WHEN** RSS 格式错误或源不可用
- **THEN** 记录错误但不删除已有数据
- **AND** 标记该播客为"刷新失败"状态
- **AND** 用户下次手动刷新时再次尝试

#### Scenario: 连续失败降级

- **WHEN** 某个播客连续 3 次刷新失败
- **THEN** 延长该播客的刷新间隔至 24 小时
- **AND** 在 UI 上显示警告图标提示用户

## MODIFIED Requirements

### Requirement: Podcast 数据模型

在 Podcast 实体和模型中新增以下字段：

- `lastFetchedAt`: DateTime? - 上次成功刷新时间
- `refreshFailedCount`: int - 连续刷新失败次数（用于降级策略）

### Requirement: AppSettings

在 AppSettings 中新增以下设置项：

- `feedRefreshInterval`: FeedRefreshInterval - 刷新频率（默认每 6 小时）
- `refreshOnCellular`: bool - 是否允许移动网络刷新（默认 false）
- `notifyOnNewEpisodes`: bool - 发现新剧集时是否通知（默认 true）
- `backgroundRefreshEnabled`: bool - 是否允许后台刷新（默认 true）

### Requirement: PodcastRepository

新增以下方法：

- `Future<FeedRefreshResult> refreshPodcastFeed(int podcastId)` - 刷新单个播客的 RSS 源
- `Future<BatchRefreshResult> refreshAllFeeds({bool force = false})` - 批量刷新所有播客

### Requirement: PodcastProvider

- 刷新操作期间展示 loading 状态
- 刷新完成后自动刷新 UI 列表
- 提供刷新结果反馈（新增剧集数量）

### Requirement: Library 页面

- 支持下拉刷新触发所有播客更新
- 刷新期间显示进度指示器
- 刷新完成后展示结果提示

## REMOVED Requirements

无
