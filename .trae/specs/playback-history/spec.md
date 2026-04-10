# 播放历史功能 Spec

## Why
用户需要追踪和管理播放历史记录，包括当前正在播放的episode、播放进度以及已完成的播放记录。这将为用户提供完整的收听历史视图，并支持应用重启后恢复上次播放状态。

## What Changes
- 新增 `PlayHistory` 数据模型和 Isar collection
- 创建播放历史页面（参考 favorite 页面结构）
- 修复 sidebar 中 history 按钮的路由（目前错误地指向 `/favorite`）
- 在 AppRoutes 中添加 history 路由
- 创建播放历史的 provider 和 repository 层
- 修改 mini_player 启动逻辑，从数据库恢复上次播放状态
- 集成播放进度自动保存到 PlayHistory 表

## Impact
- Affected specs: audio-playback, mini-player-enhancement
- Affected code:
  - `/lib/data/models/` - 新增 play_history_model.dart
  - `/lib/data/database/isar_service.dart` - 注册新 schema
  - `/lib/core/router/app_routes.dart` - 添加 history 路由
  - `/lib/core/router/app_router.dart` - 添加 history 页面映射
  - `/lib/presentation/widgets/organisms/sidebar/sidebar.dart` - 修正 history 按钮路由
  - `/lib/presentation/features/` - 新增 history feature 模块
  - `/lib/presentation/providers/` - 新增 play_history_provider.dart
  - `/lib/presentation/providers/playback_provider.dart` - 集成历史记录保存逻辑
  - `/lib/presentation/widgets/organisms/mini_player/` - 启动时恢复播放状态

## ADDED Requirements

### Requirement: PlayHistory 数据模型
系统 SHALL 提供 PlayHistory 数据模型用于持久化播放记录。

#### 字段定义：
- `id` (Id): 主键，自增
- `episodeId` (int): 外键，关联 Episode 表
- `podcastId` (int): 外键，关联 Podcast 表（用于快速查询）
- `title` (String): 副本字段，存储 episode 标题（解耦设计）
- `artworkUrl` (String?): 副本字段，存储封面 URL
- `lastPlayedPositionMs` (int): 上次播放位置（毫秒）
- `isPlayed` (bool): 是否已听完（播放完成标记）
- `playedDuration` (int): 累计收听时长（毫秒，用于统计）
- `status` (PlayHistoryStatus): 状态枚举（playing / completed / skipped）
- `lastUpdateTime` (DateTime): 最后更新时间（用于排序）
- `createdAt` (DateTime): 记录创建时间
- `isDeleted` (bool): 软删除标记（保留完整历史）

#### Scenario: 创建/更新播放记录
- **WHEN** 用户开始播放某个 episode
- **THEN** 系统创建或更新对应的 PlayHistory 记录，status 设为 playing

#### Scenario: 标记播放完成
- **WHEN** episode 播放完成或用户手动标记已完成
- **THEN** 系统更新记录：isPlayed=true, status=completed, lastUpdateTime=now

#### Scenario: 软删除保护
- **WHEN** 用户从 Episode 表删除某集
- **THEN** PlayHistory 表中仍保留该记录（设置 isDeleted=true）

### Requirement: 播放历史页面
系统 SHALL 提供播放历史页面，展示用户已完成的播放记录列表。

#### 页面特性：
- 仅显示 status=completed 的记录
- 按 lastUpdateTime 倒序排列（最新在前）
- 列表项显示：封面图、标题、播客名称、播放完成时间
- 支持空状态展示（无历史记录时的提示）
- 点击列表项可重新播放对应 episode

#### Scenario: 查看播放历史
- **WHEN** 用户点击 sidebar 的 History 按钮
- **THEN** 系统导航到播放历史页面，显示已完成的播放记录列表

#### Scenario: 空状态处理
- **WHEN** 用户没有任何播放完成的记录
- **THEN** 页面显示友好的空状态提示（参考 FavoriteEmptyPage 设计）

### Requirement: Sidebar 路由修正
系统 SHALL 修正 sidebar 中 History 按钮的路由配置。

#### 当前问题：
History 按钮（L53-61）错误地指向 `AppRoutes.favorite`

#### 修正方案：
- 将 route 改为 `AppRoutes.history`
- 确保 AppRoutes 中定义了 history 常量

### Requirement: MiniPlayer 启动恢复
系统 SHALL 在应用启动时从数据库恢复上次播放状态到 MiniPlayer。

#### 恢复逻辑：
- 应用启动时查询 PlayHistory 表中 status=playing 或 isPlayed=false 的最新记录
- 如果找到记录，将 episode 信息加载到 playbackProvider
- 使用 lastPlayedPositionMs 恢复播放进度
- 如果没有找到记录，MiniPlayer 保持默认空状态

#### Scenario: 应用启动恢复
- **WHEN** 用户关闭应用时有正在播放的 episode
- **THEN** 下次启动时 MiniPlayer 自动显示该 episode 信息和进度

### Requirement: 播放进度自动保存
系统 SHALL 在播放过程中定期自动保存播放进度到数据库。

#### 保存策略：
- 每 10 秒或每前进 5% 进度时保存一次
- 保存字段：lastPlayedPositionMs, playedDuration, lastUpdateTime
- 应用进入后台时立即保存
- episode 切换时保存上一条的最终状态

#### Scenario: 进度自动保存
- **WHEN** 用户正在播放 episode 且满足保存条件
- **THEN** 系统自动更新 PlayHistory 记录的进度信息

## MODIFIED Requirements

### Requirement: IsarService Schema 注册
修改 IsarService.open() 方法，在 schemas 列表中新增 PlayHistorySchema。

**Current**: `[PodcastSchema, EpisodeSchema, SearchHistoryModelSchema, FavoriteSchema]`
**Updated**: `[PodcastSchema, EpisodeSchema, SearchHistoryModelSchema, FavoriteSchema, PlayHistorySchema]`

### Requirement: PlaybackNotifier 集成
在 PlaybackNotifier 中集成 PlayHistory 的创建和更新逻辑：

- `playEpisode()` 方法中：创建或更新 PlayHistory 记录
- 监听进度变化时：定期调用 saveProgress()
- `stop()` 或切换 episode 时：更新当前记录状态

## REMOVED Requirements
无
