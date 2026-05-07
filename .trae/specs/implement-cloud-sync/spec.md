# 云数据同步功能 Spec

## Why
用户在多个平台（Windows、Linux、macOS、iOS、Android）使用 TinyCast 时，需要同步订阅的播客、播放状态、播放历史和收藏记录。当前应用仅有本地 Isar 数据库，无云同步能力，需要设计 Supabase 数据库表结构和同步机制，实现跨平台数据同步。

## What Changes
- 重新设计 Supabase 数据库表结构，对齐本地 Isar 模型的同步字段
- 在本地 Isar 模型中添加 `supabaseId` 字段，建立本地与云端记录的映射
- **BREAKING** 将播放状态（isPlayed、playProgress）从 Episode 模型迁移到 PlayHistory 模型
- 创建同步服务（SyncService），实现增量同步逻辑
- 创建同步 Provider，管理同步状态
- 实现后台定时同步机制（间隔 5 分钟）
- 同步过程中增量刷新 UI（queue、library、history、favorite 页面）
- 生成同步测试文档和测试文件

## Impact
- Affected specs: supabase-google-auth, playback-history, favorite-management, queue-management, mark-as-played
- Affected code:
  - `lib/data/models/podcast_model.dart` - 添加 supabaseId
  - `lib/data/models/episode_model.dart` - 添加 supabaseId，移除 isPlayed/playProgress（迁移到 history）
  - `lib/data/models/play_history_model.dart` - 添加 supabaseId，扩展播放状态字段
  - `lib/data/models/favorite_model.dart` - 添加 supabaseId
  - `lib/data/models/queue_model.dart` - 添加 supabaseId
  - `lib/core/services/sync_service.dart` - 新建
  - `lib/core/providers/sync_provider.dart` - 新建
  - `lib/data/datasources/remote_sync_datasource.dart` - 新建
  - `lib/presentation/providers/playback_provider.dart` - 重构播放状态逻辑
  - `lib/presentation/providers/play_history_provider.dart` - 适配新字段
  - Supabase 数据库表 - 重建

## ADDED Requirements

### Requirement: Supabase 数据库表设计
系统 SHALL 在 Supabase 中创建以下表，并启用 RLS 策略

#### Scenario: Podcasts 表
- **GIVEN** 用户已登录
- **WHEN** 系统创建 podcasts 表
- **THEN** 表包含字段：id(bigint PK), itunes_id(text UNIQUE), title, author, description, is_explicit, itunes_artwork_url, itunes_collection_explicitness, itunes_collection_view_url, itunes_content_advisory_rating, itunes_country, itunes_genre_ids(text[]), itunes_genres(text[]), itunes_primary_genre_name, itunes_release_date(timestamptz), keywords(text[]), language, last_updated(timestamptz), owner_email, owner_name, rss_urls(text[]), subtitle, website_url, created_at(timestamptz), updated_at(timestamptz)
- **AND** itunes_id 为 UNIQUE 约束，相同 itunes_id 视为同一 podcast
- **AND** rss_urls 为数组类型，存储多个 rssUrl

#### Scenario: Episodes 表
- **GIVEN** 用户已登录
- **WHEN** 系统创建 episodes 表
- **THEN** 表包含字段：id(bigint PK), podcast_id(bigint FK→podcasts), guid(text), artwork_url, audio_url, description, duration(int), is_explicit, itunes_artwork_url, itunes_content_advisory_rating, itunes_explicitness, itunes_id, itunes_release_date(timestamptz), link, podcast_itunes_id, pub_date(timestamptz), title, updated_at(timestamptz), created_at(timestamptz)
- **AND** (guid, podcast_id) 为 UNIQUE 约束，相同 guid 视为同一 episode
- **AND** artwork_url 为 null 时不同步

#### Scenario: User Podcast Subscriptions 表
- **GIVEN** 用户已登录
- **WHEN** 系统创建 user_podcast_subscriptions 表
- **THEN** 表包含字段：id(uuid PK), user_id(uuid FK→profiles), podcast_id(bigint FK→podcasts), subscribed_at(timestamptz), created_at(timestamptz)
- **AND** (user_id, podcast_id) 为 UNIQUE 约束

#### Scenario: Playback History 表
- **GIVEN** 用户已登录
- **WHEN** 系统创建 playback_history 表
- **THEN** 表包含字段：id(uuid PK), user_id(uuid FK→profiles), episode_id(bigint FK→episodes), artwork_url, description, episode_guid, episode_itunes_id, is_deleted(bool), is_played(bool), last_played_position_ms(int), last_update_time(timestamptz), played_duration(int), podcast_guid, podcast_itunes_id, status(text), title, created_at(timestamptz)
- **AND** (user_id, episode_id) 为 UNIQUE 约束

#### Scenario: Favorites 表
- **GIVEN** 用户已登录
- **WHEN** 系统创建 favorites 表
- **THEN** 表包含字段：id(uuid PK), user_id(uuid FK→profiles), episode_id(bigint FK→episodes), episode_guid, episode_itunes_id, created_at(timestamptz)
- **AND** (user_id, episode_id) 为 UNIQUE 约束

#### Scenario: Queue Items 表
- **GIVEN** 用户已登录
- **WHEN** 系统创建 queue_items 表
- **THEN** 表包含字段：id(uuid PK), user_id(uuid FK→profiles), episode_id(bigint FK→episodes), episode_guid, episode_itunes_id, podcast_guid, podcast_itunes_id, position(int), added_at(timestamptz), created_at(timestamptz)
- **AND** (user_id, episode_id) 为 UNIQUE 约束

### Requirement: 本地 Isar 模型添加 supabaseId
系统 SHALL 在所有需要同步的 Isar 模型中添加 supabaseId 字段

#### Scenario: Podcast 模型添加 supabaseId
- **WHEN** 系统更新 Podcast Isar 模型
- **THEN** 添加 `String? supabaseId` 字段，用于关联云端记录

#### Scenario: Episode 模型添加 supabaseId
- **WHEN** 系统更新 Episode Isar 模型
- **THEN** 添加 `String? supabaseId` 字段

#### Scenario: PlayHistory 模型添加 supabaseId
- **WHEN** 系统更新 PlayHistory Isar 模型
- **THEN** 添加 `String? supabaseId` 字段

#### Scenario: Favorite 模型添加 supabaseId
- **WHEN** 系统更新 Favorite Isar 模型
- **THEN** 添加 `String? supabaseId` 字段

#### Scenario: Queue 模型添加 supabaseId
- **WHEN** 系统更新 Queue Isar 模型
- **THEN** 添加 `String? supabaseId` 字段

### Requirement: 播放状态迁移到 History
系统 SHALL 将播放状态从 Episode 模型迁移到 PlayHistory 模型

#### Scenario: PlayHistory 扩展字段
- **WHEN** 系统重构播放状态管理
- **THEN** PlayHistory 模型新增字段：`double playProgress`（播放进度比例）
- **AND** PlayHistory 成为播放状态的唯一来源（Single Source of Truth）

#### Scenario: Episode isPlayed 查询改为从 History 查询
- **WHEN** 查询 episode 是否已播放
- **THEN** 从 PlayHistory 表查询 isPlayed 状态，而非 Episode 表的 isPlayed 字段

#### Scenario: Episode 模型保留 isPlayed 字段但不再作为主数据源
- **WHEN** Episode 模型的 isPlayed 字段
- **THEN** 保留该字段用于本地缓存显示，但写入时同步更新 PlayHistory

### Requirement: 同步前置条件
系统 SHALL 在同步前检查前置条件

#### Scenario: 未登录不同步
- **WHEN** 用户未登录
- **THEN** 不执行任何同步操作

#### Scenario: 未付费不同步（暂不实现付费检查）
- **WHEN** 用户已登录但未付费
- **THEN** 暂时允许同步（付费功能后续开发时再限制）

#### Scenario: 登录成功后启动同步
- **WHEN** 用户登录成功
- **THEN** 自动启动同步服务

### Requirement: 增量同步机制
系统 SHALL 实现基于时间戳的增量同步

#### Scenario: 首次同步
- **WHEN** 用户首次登录且本地无同步记录
- **THEN** 执行全量同步，拉取云端所有数据并合并到本地

#### Scenario: 增量同步
- **WHEN** 用户已有同步记录
- **THEN** 仅同步上次同步时间之后变化的数据
- **AND** 使用 updated_at / last_update_time 字段判断数据变化

#### Scenario: 同步冲突解决
- **WHEN** 本地和云端同一记录都有修改
- **THEN** 采用"最后写入胜出"（Last Write Wins）策略，以 updated_at 时间戳较新者为准

### Requirement: 定时后台同步
系统 SHALL 实现定时后台同步

#### Scenario: 同步间隔
- **WHEN** 同步服务启动
- **THEN** 每隔 5 分钟执行一次增量同步

#### Scenario: 后台执行
- **WHEN** 同步执行
- **THEN** 同步在后台 Isolate/Compute 中执行，不阻塞主线程

#### Scenario: 增量 UI 刷新
- **WHEN** 同步过程中每成功同步 N 条数据（N=5）
- **THEN** 通知相关 Provider 刷新 UI，包括 queue、library、history、favorite 页面

### Requirement: 同步数据映射规则
系统 SHALL 按以下规则映射和同步数据

#### Scenario: Podcast 以 iTunes ID 为准
- **WHEN** 同步 Podcast 数据
- **THEN** 相同 itunes_id 视为同一 podcast
- **AND** 没有 itunes_id 的视为新记录

#### Scenario: Episode 以 GUID 为准
- **WHEN** 同步 Episode 数据
- **THEN** 相同 guid 视为同一 episode
- **AND** 没有 guid 的视为新记录

#### Scenario: Podcast 与 Episode 关联
- **WHEN** Episode 关联到 Podcast
- **THEN** 通过 podcast_itunes_id 和 episode 的 guid 建立关联

#### Scenario: 同步字段类型与 Isar 保持一致
- **WHEN** 同步数据到云端
- **THEN** 字段类型与本地 Isar 数据库保持一致（String、List<String>、bool、int、DateTime 等）
- **AND** 数组类型在 Supabase 中使用 PostgreSQL 数组类型（text[]）

#### Scenario: Episode artworkUrl 为 null 时不同步
- **WHEN** Episode 的 artworkUrl 为 null
- **THEN** 跳过该字段的同步，不覆盖云端已有值

### Requirement: 同步服务架构
系统 SHALL 创建同步服务相关类

#### Scenario: RemoteSyncDataSource
- **WHEN** 系统创建远程同步数据源
- **THEN** 封装所有 Supabase REST API 调用，包括 upsert、select、增量查询

#### Scenario: SyncService
- **WHEN** 系统创建同步服务
- **THEN** 编排同步流程：拉取云端变更 → 合并到本地 → 推送本地变更到云端
- **AND** 处理冲突解决逻辑
- **AND** 记录最后同步时间戳

#### Scenario: SyncProvider
- **WHEN** 系统创建同步状态 Provider
- **THEN** 提供同步状态（idle/syncing/error）、最后同步时间、进度信息
- **AND** 在同步完成后通知相关 Provider 刷新

### Requirement: 同步测试
系统 SHALL 生成同步功能的测试

#### Scenario: 测试需求文档
- **WHEN** 开发完成后
- **THEN** 在 `test/docs/` 目录下生成同步测试需求文档

#### Scenario: 同步测试文件
- **WHEN** 开发完成后
- **THEN** 在 `test/` 对应功能结构目录下生成同步测试文件
- **AND** 执行测试验证功能

## MODIFIED Requirements

### Requirement: 播放状态管理重构
**当前**: 播放状态（isPlayed、playProgress）存储在 Episode 模型中
**修改为**: 播放状态以 PlayHistory 为准，PlayHistory 成为播放状态的唯一数据源。Episode 的 isPlayed 字段保留作为缓存，但由 PlayHistory 驱动更新

### Requirement: PlaybackNotifier 适配
**当前**: PlaybackNotifier 直接修改 Episode.isPlayed
**修改为**: PlaybackNotifier 通过 PlayHistoryRepository 更新播放状态，PlayHistory 变更后同步更新 Episode 缓存字段

### Requirement: CloudSyncSettings 页面扩展
**当前**: 仅显示登录/登出状态
**修改为**: 登录后显示同步状态信息（最后同步时间、同步状态指示器）

## REMOVED Requirements

### Requirement: 旧 Supabase 表结构
**Reason**: 现有 podcasts、episodes、playback_history、subscriptions 表结构过于简单，不满足同步字段需求
**Migration**: 删除旧表，创建新表结构，新表包含完整的同步字段
