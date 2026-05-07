# Tasks

- [ ] Task 1: 重建 Supabase 数据库表结构
  - [ ] SubTask 1.1: 删除旧的 podcasts、episodes、playback_history、subscriptions 表
  - [ ] SubTask 1.2: 创建 podcasts 表（含完整同步字段：itunes_id UNIQUE, rss_urls text[], itunes_genre_ids text[], itunes_genres text[], keywords text[] 等）
  - [ ] SubTask 1.3: 创建 episodes 表（含完整同步字段：guid, podcast_itunes_id, (guid, podcast_id) UNIQUE 等）
  - [ ] SubTask 1.4: 创建 user_podcast_subscriptions 表（user_id FK, podcast_id FK, UNIQUE(user_id, podcast_id)）
  - [ ] SubTask 1.5: 创建 playback_history 表（含完整同步字段：episode_guid, episode_itunes_id, is_played, last_played_position_ms, played_duration, status, UNIQUE(user_id, episode_id)）
  - [ ] SubTask 1.6: 创建 favorites 表（episode_guid, episode_itunes_id, UNIQUE(user_id, episode_id)）
  - [ ] SubTask 1.7: 创建 queue_items 表（episode_guid, episode_itunes_id, podcast_guid, podcast_itunes_id, position, UNIQUE(user_id, episode_id)）
  - [ ] SubTask 1.8: 为所有表启用 RLS 策略（用户只能访问自己的数据，podcasts/episodes 为公共只读+认证用户可写）
  - [ ] SubTask 1.9: 运行 Supabase advisors 检查安全与性能问题

- [ ] Task 2: 本地 Isar 模型添加 supabaseId 字段
  - [ ] SubTask 2.1: Podcast 模型添加 `String? supabaseId` 字段
  - [ ] SubTask 2.2: Episode 模型添加 `String? supabaseId` 字段
  - [ ] SubTask 2.3: PlayHistory 模型添加 `String? supabaseId` 和 `double playProgress` 字段
  - [ ] SubTask 2.4: Favorite 模型添加 `String? supabaseId` 字段
  - [ ] SubTask 2.5: Queue 模型添加 `String? supabaseId` 字段
  - [ ] SubTask 2.6: 运行 `dart run build_runner build` 重新生成 Isar 代码

- [ ] Task 3: 重构播放状态管理（Episode → PlayHistory）
  - [ ] SubTask 3.1: 修改 PlayHistoryRepository，新增 playProgress 字段的读写方法
  - [ ] SubTask 3.2: 修改 PlaybackNotifier，播放进度和 isPlayed 状态写入 PlayHistory 而非直接修改 Episode
  - [ ] SubTask 3.3: 修改 PlaybackNotifier._markEpisodeAsPlayed，同步更新 PlayHistory 和 Episode 缓存
  - [ ] SubTask 3.4: 修改 PlaybackNotifier._saveCurrentProgress，将 playProgress 写入 PlayHistory
  - [ ] SubTask 3.5: 修改 PlaybackNotifier._restoreLastPlaybackState，从 PlayHistory 恢复播放进度
  - [ ] SubTask 3.6: 修改 unplayed_episodes_provider 和相关查询，从 PlayHistory 判断 isPlayed
  - [ ] SubTask 3.7: 修改 episode_item 等展示组件，从 PlayHistory 获取播放状态

- [ ] Task 4: 创建 RemoteSyncDataSource
  - [ ] SubTask 4.1: 创建 `lib/data/datasources/remote_sync_datasource.dart`
  - [ ] SubTask 4.2: 实现云端 Podcast 的 upsert 和增量查询方法
  - [ ] SubTask 4.3: 实现云端 Episode 的 upsert 和增量查询方法
  - [ ] SubTask 4.4: 实现云端 UserPodcastSubscription 的 upsert 和增量查询方法
  - [ ] SubTask 4.5: 实现云端 PlaybackHistory 的 upsert 和增量查询方法
  - [ ] SubTask 4.6: 实现云端 Favorite 的 upsert 和增量查询方法
  - [ ] SubTask 4.7: 实现云端 QueueItem 的 upsert 和增量查询方法

- [ ] Task 5: 创建 SyncService 同步服务
  - [ ] SubTask 5.1: 创建 `lib/core/services/sync_service.dart`
  - [ ] SubTask 5.2: 实现同步前置条件检查（登录状态、付费状态）
  - [ ] SubTask 5.3: 实现全量同步逻辑（首次同步）
  - [ ] SubTask 5.4: 实现增量同步逻辑（基于 updated_at 时间戳）
  - [ ] SubTask 5.5: 实现冲突解决逻辑（Last Write Wins）
  - [ ] SubTask 5.6: 实现本地→云端推送逻辑（upsert 本地变更到云端）
  - [ ] SubTask 5.7: 实现云端→本地拉取逻辑（合并云端变更到本地 Isar）
  - [ ] SubTask 5.8: 实现同步后更新本地 Isar 记录的 supabaseId
  - [ ] SubTask 5.9: 实现同步进度回调（每 N 条数据后通知 UI 刷新）

- [ ] Task 6: 创建 SyncProvider 和定时同步机制
  - [ ] SubTask 6.1: 创建 `lib/core/providers/sync_provider.dart`
  - [ ] SubTask 6.2: 实现 SyncNotifier，管理同步状态（idle/syncing/error）、最后同步时间、进度
  - [ ] SubTask 6.3: 实现定时同步（5 分钟间隔），使用 Timer 在后台执行
  - [ ] SubTask 6.4: 实现同步完成后通知相关 Provider 刷新（queue、library、history、favorite）
  - [ ] SubTask 6.5: 实现登录状态变化时自动启动/停止同步服务
  - [ ] SubTask 6.6: 在 main.dart 中初始化同步服务

- [ ] Task 7: CloudSyncSettings 页面扩展
  - [ ] SubTask 7.1: 在 LoginSuccessPage 中添加同步状态信息（最后同步时间、同步状态指示器）
  - [ ] SubTask 7.2: 添加手动触发同步按钮
  - [ ] SubTask 7.3: 显示同步进度信息

- [ ] Task 8: 生成测试文档和测试文件
  - [ ] SubTask 8.1: 在 `test/docs/` 目录下生成同步测试需求文档
  - [ ] SubTask 8.2: 创建 `test/data/datasources/remote_sync_datasource_test.dart`
  - [ ] SubTask 8.3: 创建 `test/core/services/sync_service_test.dart`
  - [ ] SubTask 8.4: 创建 `test/core/providers/sync_provider_test.dart`
  - [ ] SubTask 8.5: 执行所有测试，验证功能正确性

# Task Dependencies
- [Task 2] depends on [Task 1]（需要云端表结构确定后才能对齐本地模型）
- [Task 3] depends on [Task 2]（需要 Isar 模型更新后才能重构播放状态）
- [Task 4] depends on [Task 1]（需要云端表结构确定后才能创建远程数据源）
- [Task 5] depends on [Task 2, Task 3, Task 4]（需要本地模型、播放状态重构、远程数据源都完成后才能创建同步服务）
- [Task 6] depends on [Task 5]（需要同步服务完成后才能创建 Provider）
- [Task 7] depends on [Task 6]（需要 Provider 完成后才能更新 UI）
- [Task 8] depends on [Task 5, Task 6]（需要核心功能完成后才能编写测试）
