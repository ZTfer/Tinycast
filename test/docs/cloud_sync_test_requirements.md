# TinyCast 云同步功能测试需求文档

## 1. 概述

TinyCast 云同步功能基于 Supabase 实现本地 Isar 数据库与云端的双向数据同步。支持播客订阅、播放历史、收藏、队列等数据的跨设备同步，采用"先拉后推"策略，并通过 `updated_at` 时间戳实现增量同步。

### 核心组件

| 组件 | 路径 | 职责 |
|------|------|------|
| RemoteSyncDataSource | `lib/data/datasources/remote_sync_datasource.dart` | 封装 Supabase 数据库 CRUD 操作 |
| SyncService | `lib/core/services/sync_service.dart` | 同步核心逻辑：拉取、合并、推送、冲突解决 |
| SyncProvider | `lib/core/providers/sync_provider.dart` | Riverpod 状态管理，驱动 UI 状态更新 |

## 2. 测试范围

### 2.1 包含在测试范围内

- RemoteSyncDataSource 的数据转换逻辑（user_id 注入、空数据处理）
- SyncService 的同步流程控制（认证检查、先拉后推顺序）
- SyncService 的数据转换逻辑（本地模型 → 云端 Map）
- SyncService 的时间戳管理（getLastSyncTime、_saveLastSyncTime）
- SyncProvider 的状态管理（状态转换、防重入）
- PlayHistory 重构相关逻辑（playProgress、isPlayed 从历史记录获取）

### 2.2 不包含在测试范围内

- Supabase 服务端行为（由 Supabase SLA 保证）
- Isar 数据库底层存储行为
- 网络层传输可靠性
- UI 渲染逻辑

## 3. 测试分类

### 3.1 单元测试

不依赖外部服务（Supabase/Isar），使用 Fake/Mock 对象隔离依赖。

| 测试文件 | 测试对象 | 依赖处理 |
|----------|----------|----------|
| `test/data/datasources/remote_sync_datasource_test.dart` | RemoteSyncDataSource | FakeRemoteSyncDataSource 模拟 Supabase 行为 |
| `test/core/services/sync_service_test.dart` | SyncService | MockRemoteSyncDataSource + SharedPreferences mock |
| `test/core/providers/sync_provider_test.dart` | SyncNotifier / SyncState | 直接测试状态逻辑 |

### 3.2 集成测试

需要真实 Supabase/Isar 环境，标记为 `integration` 并在单元测试运行时跳过。

| 测试场景 | 依赖 | 跳过原因 |
|----------|------|----------|
| RemoteSyncDataSource 实际 Supabase 读写 | Supabase 实例 | 需要真实后端 |
| SyncService 完整同步流程 | Supabase + Isar | 需要完整环境 |
| SyncNotifier 与 SyncService 集成 | Supabase + Isar + Riverpod | 需要完整环境 |

## 4. 测试用例

### 4.1 RemoteSyncDataSource

#### 4.1.1 upsertPodcasts

| 用例 ID | 描述 | 输入 | 预期结果 |
|---------|------|------|----------|
| RSD-001 | 正确插入播客数据 | 包含 title/author/itunes_id 的 Map 列表 | 返回带 id 的记录列表 |
| RSD-002 | 空列表时返回空列表 | `[]` | 返回 `[]` |
| RSD-003 | 冲突时更新已有记录 | itunes_id 相同的记录 | 更新而非重复插入 |

#### 4.1.2 fetchPodcastsUpdatedAfter

| 用例 ID | 描述 | 输入 | 预期结果 |
|---------|------|------|----------|
| RSD-004 | 无时间戳时返回所有播客 | `null` | 返回全部播客列表 |
| RSD-005 | 有时间戳时只返回更新的播客 | `DateTime` | 只返回 updated_at > since 的记录 |

#### 4.1.3 upsertEpisodes

| 用例 ID | 描述 | 输入 | 预期结果 |
|---------|------|------|----------|
| RSD-006 | 正确插入节目数据 | 包含 title/guid/podcast_id 的 Map 列表 | 返回带 id 的记录列表 |
| RSD-007 | 空列表时返回空列表 | `[]` | 返回 `[]` |

#### 4.1.4 upsertUserPodcastSubscriptions

| 用例 ID | 描述 | 输入 | 预期结果 |
|---------|------|------|----------|
| RSD-008 | 自动注入 user_id | 不含 user_id 的订阅列表 | 每条记录包含 user_id |
| RSD-009 | 未认证时抛出 StateError | userId = null | 抛出 `StateError('User is not authenticated')` |
| RSD-010 | 空列表时返回空列表 | `[]` | 返回 `[]` |

#### 4.1.5 upsertPlaybackHistory

| 用例 ID | 描述 | 输入 | 预期结果 |
|---------|------|------|----------|
| RSD-011 | 自动注入 user_id | 不含 user_id 的历史列表 | 每条记录包含 user_id |
| RSD-012 | 未认证时抛出 StateError | userId = null | 抛出 `StateError` |

#### 4.1.6 upsertFavorites

| 用例 ID | 描述 | 输入 | 预期结果 |
|---------|------|------|----------|
| RSD-013 | 自动注入 user_id | 不含 user_id 的收藏列表 | 每条记录包含 user_id |
| RSD-014 | 未认证时抛出 StateError | userId = null | 抛出 `StateError` |

#### 4.1.7 upsertQueueItems

| 用例 ID | 描述 | 输入 | 预期结果 |
|---------|------|------|----------|
| RSD-015 | 自动注入 user_id | 不含 user_id 的队列列表 | 每条记录包含 user_id |
| RSD-016 | 未认证时抛出 StateError | userId = null | 抛出 `StateError` |

#### 4.1.8 _ensureUserId

| 用例 ID | 描述 | 输入 | 预期结果 |
|---------|------|------|----------|
| RSD-017 | 用户已认证时不抛出异常 | userId = "test-uid" | 正常执行 |
| RSD-018 | 用户未认证时抛出 StateError | userId = null | 抛出 `StateError('User is not authenticated')` |

### 4.2 SyncService

#### 4.2.1 sync() 流程控制

| 用例 ID | 描述 | 前置条件 | 预期结果 |
|---------|------|----------|----------|
| SS-001 | 用户未认证时跳过同步 | canSync = false | 不调用任何数据源方法 |
| SS-002 | 先拉取后推送 | canSync = true | 调用顺序：pull → push |
| SS-003 | 同步完成后保存时间戳 | 同步成功 | SharedPreferences 中存储时间戳 |

#### 4.2.2 数据转换逻辑

| 用例 ID | 描述 | 输入 | 预期结果 |
|---------|------|------|----------|
| SS-004 | podcastToCloudMap 正确转换 | Podcast 对象 | 包含 title/author/description/itunes_id 等字段 |
| SS-005 | episodeToCloudMap 正确转换 | Episode 对象 | 包含 title/guid/audio_url/pub_date 等字段 |
| SS-006 | playHistoryToCloudMap 正确转换 | PlayHistory 对象 | 包含 is_played/last_played_position_ms/play_progress 等字段 |
| SS-007 | favoriteToCloudMap 正确转换 | Favorite 对象 | 包含 episode_guid/episode_itunes_id 等字段 |
| SS-008 | queueItemToCloudMap 正确转换 | Queue 对象 | 包含 position/added_at 等字段 |

#### 4.2.3 时间戳管理

| 用例 ID | 描述 | 前置条件 | 预期结果 |
|---------|------|----------|----------|
| SS-009 | 无上次同步时间时返回 null | SharedPreferences 无记录 | 返回 `null` |
| SS-010 | 有上次同步时间时返回正确时间 | SharedPreferences 有记录 | 返回对应 DateTime |
| SS-011 | 保存时间戳后可读取 | 调用 _saveLastSyncTime | getLastSyncTime 返回相同时间 |

#### 4.2.4 进度回调

| 用例 ID | 描述 | 前置条件 | 预期结果 |
|---------|------|----------|----------|
| SS-012 | 同步过程中触发进度回调 | 设置 onProgressChanged | 回调被调用，包含 currentTable 信息 |

### 4.3 SyncProvider

#### 4.3.1 SyncState

| 用例 ID | 描述 | 预期结果 |
|---------|------|----------|
| SP-001 | 初始状态为 idle | `SyncState().status == SyncStatus.idle` |
| SP-002 | 初始 lastSyncTime 为 null | `SyncState().lastSyncTime == null` |
| SP-003 | copyWith 正确更新状态 | 仅更新指定字段 |

#### 4.3.2 SyncNotifier

| 用例 ID | 描述 | 前置条件 | 预期结果 |
|---------|------|----------|----------|
| SP-004 | 初始状态为 idle | 新建 SyncNotifier | `state.status == SyncStatus.idle` |
| SP-005 | syncNow() 将状态改为 syncing | 当前状态为 idle | `state.status == SyncStatus.syncing` |
| SP-006 | syncNow() 完成后状态回到 idle | 同步成功 | `state.status == SyncStatus.idle` |
| SP-007 | syncNow() 在 syncing 状态时不重复执行 | 当前状态为 syncing | 不触发新的同步 |
| SP-008 | syncNow() 失败时状态为 error | 同步抛出异常 | `state.status == SyncStatus.error` |

### 4.4 PlayHistory 重构

| 用例 ID | 描述 | 输入 | 预期结果 |
|---------|------|------|----------|
| PH-001 | playProgress 从 PlayHistory 获取 | PlayHistory.playProgress = 0.5 | Episode.playProgress = 0.5 |
| PH-002 | isPlayed 从 PlayHistory 获取 | PlayHistory.isPlayed = true | Episode.isPlayed = true |
| PH-003 | 无 PlayHistory 时使用默认值 | 无对应 PlayHistory | Episode.playProgress = 0.0, isPlayed = false |

## 5. 测试环境要求

### 5.1 单元测试环境

- Dart SDK >= 3.9.2
- Flutter 测试框架
- mockito ^5.6.4（Mock 对象生成）
- build_runner ^2.13.1（Mock 代码生成）
- shared_preferences（通过 `SharedPreferences.setMockInitialValues` 模拟）

### 5.2 集成测试环境

- 完整的 Supabase 项目（含认证和数据库表）
- Isar 数据库初始化
- Flutter 应用完整运行环境

### 5.3 运行命令

```bash
# 仅运行单元测试
dart test test/data/datasources/remote_sync_datasource_test.dart \
         test/core/services/sync_service_test.dart \
         test/core/providers/sync_provider_test.dart

# 生成 Mock 文件
dart run build_runner build --delete-conflicting-outputs
```

## 6. 已知限制

1. **Supabase 链式 API 难以 Mock**：SupabaseClient 的查询构建器采用链式调用（`_client.from().upsert().select()`），mockito 无法有效模拟。因此使用 FakeRemoteSyncDataSource 替代。
2. **Isar 单例难以替换**：IsarService 采用全局单例模式，无法在单元测试中注入 Mock。涉及 Isar 的测试标记为集成测试。
3. ~~**私有方法无法直接测试**~~ **已解决**：SyncService 的转换方法已提取为 `lib/core/services/sync_mappers.dart` 中的公开顶层函数（`podcastToCloudMap` 等），测试直接调用生产代码路径，不再使用测试内副本。
4. **SyncNotifier 内部创建 SyncService**：SyncNotifier 在 `syncNow()` 中直接创建 SyncService 实例，无法注入 Mock。状态转换测试依赖完整环境。

## 7. 集成测试执行环境

以下 8 个集成用例当前标记为 `skip`，其阻塞根因与可执行环境如下：

### SyncService 集成测试（4 个 skip）

| 用例 ID | 阻塞根因 | 可执行环境 |
|---------|----------|------------|
| SS-001 | `canSync` 依赖 `SupabaseService().isInitialized` 全局单例 | 配置真实 Supabase 项目（未认证状态） |
| SS-002 | `sync()` 调用 `_ensureUserProfile()`（SupabaseService.client）及 `_pullAndMergeCloudChanges`/`_pushLocalChanges`（IsarService.instance） | 配置真实 Supabase + 初始化 Isar |
| SS-003 | 同 SS-002 | 同上 |
| SS-012 | 同 SS-002 | 同上 |

### SyncNotifier 集成测试（4 个 skip）

| 用例 ID | 阻塞根因 | 可执行环境 |
|---------|----------|------------|
| SP-004 | `SyncNotifier.build()` 监听 `authStateProvider`，需 ProviderContainer | Riverpod ProviderContainer + Auth 环境 |
| SP-005 | `syncNow()` 硬编码创建 `SyncService()`，无法注入 Mock | 重构 SyncNotifier 为可注入 SyncService，或使用完整环境 |
| SP-007 | 同 SP-005 | 同上 |
| Auth 触发 | 需 `authStateProvider` 状态变化 + SyncNotifier 完整环境 | Riverpod + Auth + Supabase/Isar 完整环境 |

### 解除 skip 的路径

1. **SyncService 集成测试**：待 `SupabaseService` 和 `IsarService` 重构为可注入依赖（如通过构造函数参数或 Provider 注入）后，可使用 Mock 在单元测试中覆盖 SS-001 ~ SS-012。
2. **SyncNotifier 集成测试**：待 `SyncNotifier` 重构为通过构造函数或 Provider 接收 `SyncService` 实例后，可使用 Mock 在单元测试中覆盖 SP-004 ~ SP-008。
3. **真实集成测试环境**：配置真实 Supabase 项目 + 初始化 Isar 数据库后，可运行 `flutter test --tags integration` 执行这些用例（需补充 `integration` tag）。
