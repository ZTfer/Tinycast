# 云同步调试手册（最小排查）

本文档是云同步域（Supabase 同步）的最小排查手册：先确认前置条件，
再按日志序列定位失败步骤。Supabase 凭据配置与初始化问题见
[supabase_setup.md](supabase_setup.md)；文件日志的位置与读取方式见
[download_debug_guide.md](download_debug_guide.md) 的
「📄 文件日志位置与读取方式」章节——同步日志同样写入该文件，
可用 `grep '\[SYNC\]' <日志文件>` 检索。

## 🚦 前置条件

同步只在以下条件全部满足时才会执行（`SyncService.canSync`）：

1. `.env` 配置了真实的 `SUPABASE_URL` / `SUPABASE_ANON_KEY`；使用占位符
   时启动日志为 `ℹ️ Supabase 未配置（使用占位符），跳过初始化`
2. 用户已登录（设置 → 云同步）

条件不满足时同步被直接跳过，日志只有一行：

```text
[WARNING] [TinyCast] Sync skipped: user not authenticated
```

## ⏰ 同步何时触发

| 触发点 | 行为 |
| ------ | ------ |
| 登录成功 | 立即同步一次，并启动每 5 分钟的周期同步 |
| 播放进度 / 收藏 / 队列等本地变更 | `requestSync()`，10 秒防抖后同步 |
| 设置 → 云同步 → 已登录页 | 点击同步按钮手动触发 `syncNow()` |
| 登出 | 停止周期同步，清理该用户的同步状态 |

对应日志：`Periodic sync started (every 5 minutes)` /
`Periodic sync stopped`。

## 🔍 日志速查

同步域日志大多带 `[SYNC]` 标记（远程数据源错误除外，见下文），
并用 emoji 区分阶段：

- `🔄 [SYNC]` - 同步开始 / 进度
- `✅ [SYNC]` - 同步完成
- `⚠️ [SYNC]` - 部分步骤失败（lastSyncTime 不推进）
- `❌ [SYNC]` - 步骤失败或整体失败

一次成功同步的日志序列：

```text
[INFO] 🔄 [SYNC] Starting sync...
[INFO] 🔄 [SYNC] First sync: false, last sync: 2026-08-25 14:00:00.000
[INFO] ✅ [SYNC] Sync completed at 2026-08-25 14:05:00.000
[INFO] Sync completed successfully
```

### 步骤名一览

单个步骤失败时输出
`❌ [SYNC] Step "<step>" failed, continuing with remaining steps`，
步骤名与进度回调的 `currentTable` 对应：

| 阶段 | 步骤名 |
| ------ | ------ |
| 拉取 | `pull_podcasts` / `pull_episodes` / `pull_subscriptions` / `pull_playback_history` / `pull_favorites` / `pull_queue_items` |
| 推送 | `push_podcasts` / `push_episodes` / `push_subscriptions` / `push_playback_history` / `push_favorites` / `push_queue_items` |

远程数据源（`RemoteSyncDataSource`）的错误日志**不带** `[SYNC]`
前缀，消息形如 `upsertPodcasts failed`、`fetchFavorites failed`，
级别为 ERROR 并附完整堆栈。同步涉及的六张表：`podcasts`、
`episodes`、`user_podcast_subscriptions`、`playback_history`、
`favorites`、`queue_items`。

## 🔧 常见问题排查

### 问题1：同步完全没有发生

**症状**：日志中搜索不到 `🔄 [SYNC] Starting sync...`

**排查步骤**：

1. 检查启动日志是否有 `✅ Supabase 客户端初始化完成`；若为
   `ℹ️ Supabase 未配置（使用占位符）`，先按 supabase_setup.md 配置凭据
2. 确认已登录；未登录时只有
   `Sync skipped: user not authenticated`
3. 确认存在 `Periodic sync started (every 5 minutes)`；没有则说明
   `SyncNotifier` 未进入登录分支，检查登录态 Provider

### 问题2：部分步骤失败

**症状**：`⚠️ [SYNC] Sync finished with step failures; lastSyncTime not advanced`

**排查步骤**：

1. 向上搜索最近的 `❌ [SYNC] Step "<step>" failed`，确定失败步骤
2. 紧跟其后的 `Error:` / `StackTrace:` 行给出根因；若是
   `upsertXxx failed` / `fetchXxx failed`，转问题3
3. `lastSyncTime` 不推进是预期行为：下次同步仍按旧时间增量拉取，
   修复后重跑一次即可补齐

### 问题3：远端读写失败

**症状**：`upsertPodcasts failed` /
`fetchPlaybackHistoryUpdatedAfter failed` 等 ERROR

**排查步骤**：

1. 检查网络连通性
2. 检查 Supabase 凭据是否有效（见 supabase_setup.md）
3. 检查 Supabase 侧六张表的表结构与 RLS 策略是否允许当前用户读写

### 问题4：删除没有传播到其他设备

**症状**：本机取消订阅 / 取消收藏 / 移出队列后，其他设备同步后仍存在

**排查步骤**：

1. 搜索 `Deleted cloud subscription for podcast_id=` /
   `Deleted cloud favorite for episode_id=` /
   `Deleted cloud queue item for episode_id=`，确认删除已推送云端
2. 若有 `Failed to delete cloud ...`，该次同步会以步骤失败告终
   （见问题2），删除记录保留在墓碑中，下次同步自动重试
3. 对端设备上的传播日志为
   `Unsubscribing local podcast (not in cloud)` /
   `Removing local favorite (not in cloud)` /
   `Removing local queue item (not in cloud)`

### 问题5：需要强制全量同步

`lastSyncTime` 存于 `shared_preferences`，键为
`last_sync_timestamp_<userId>`，墓碑（待删除记录）存于
`sync_tombstone_*_<userId>` 系列键：

- 用户路径：登出再登录。登出会自动清理该用户的 `lastSyncTime`
  与墓碑，下次登录后首次同步即为全量
- 开发者路径：删除上述键后触发一次同步，日志中应出现
  `First sync: true`

## 🔗 相关文件

- `lib/core/services/sync_service.dart` - 同步核心（拉取 / 推送 / 合并 / 墓碑）
- `lib/core/providers/sync_provider.dart` - 触发时机、周期同步与状态管理
- `lib/data/datasources/remote_sync_datasource.dart` - Supabase 表读写
- `lib/core/services/sync_tombstone_store.dart` - 待删除墓碑存储
- `lib/core/utils/logger.dart` - 日志工具类
