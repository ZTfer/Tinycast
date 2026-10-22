# 云同步调试手册（最小排查）

本文档是云同步域（Supabase 同步）的最小排查手册：先确认前置条件，
再按日志序列定位失败步骤。Supabase 凭据配置与初始化问题见
[supabase_setup.md](../guides/supabase_setup.md)；文件日志的位置与读取方式见
[download_debug_guide.md](download_debug_guide.md#文件日志位置与读取方式)
——同步日志同样写入该文件，可用 `grep '\[SYNC\]' <日志文件>` 检索。

## 🚦 前置条件

同步只在以下条件全部满足时才会执行（`SyncService.canSync`）：

1. Supabase 已用真实凭据初始化：`SupabaseService().isInitialized == true`
   - 启动日志为 `✅ Supabase 客户端初始化完成`
   - 若为 `ℹ️ Supabase 未配置（使用占位符），跳过初始化`，说明
     `run.sh`/`--dart-define` 没有传入有效值，先按 supabase_setup.md 配置
2. 用户已登录（设置 → 云同步）

条件不满足时 `sync()` 直接返回 `skipped`，日志只有一行：

```text
[WARNING] Sync skipped: user not authenticated
```

## ⏰ 同步何时触发

`SyncNotifier`（`lib/presentation/providers/sync_provider.dart`）负责触发：

| 触发点 | 行为 |
| ------ | ------ |
| 已登录状态下启动 / 登录成功 | 立即执行一次同步，并启动每 5 分钟的周期同步 |
| 播放行为（播放、暂停、进度、结束等） | `requestSync()`，10 秒防抖后同步；连续操作只保留最后一次 |
| 周期定时器 | 每 5 分钟 `syncNow()` |
| 设置 → 云同步 → 已登录页 | 点击按钮手动 `syncNow()` |
| 账号切换 | 清空旧账号的本地数据与同步状态，然后为新账号同步 |
| 登出 | 停止周期同步，清理该用户的 `lastSyncTime` 与墓碑 |

对应日志：

```text
Periodic sync started (every 5 minutes)
Periodic sync stopped
[SYNC] 账号已切换，旧账号本地数据已清理
```

**收藏、队列、订阅的本地变更当前不会调用 `requestSync()`**。它们会等待下一次
5 分钟周期同步或手动同步；只有播放相关路径接了 10 秒防抖。

`syncNow()` 在已有同步进行中会直接返回，不会排队执行第二次。

## 🔁 同步顺序与失败语义

一次同步固定按“先拉后推”执行：

1. 读取 `lastSyncTime`；增量拉取的起点是 `lastSyncTime - 2 分钟`
   （覆盖边界时间差，代价是可能重复拉取少量记录）
2. 拉取并合并云端变更
3. 推送本地变更
4. 只有**没有任何失败步骤**时才推进 `lastSyncTime`

失败语义分三类，排查时必须区分：

| 失败类型 | 行为 | 典型日志 |
|----------|------|----------|
| 拉取请求失败 | 立即中止本轮，**跳过推送**，避免用陈旧本地状态覆盖云端 | `[SYNC] Pull step "<step>" failed; aborting pull and push` |
| 拉取合并失败 | 继续后续拉取与推送，但记录失败步骤，`lastSyncTime` 不推进 | `[SYNC] Merge step "<step>" left records unmerged; sync cursor will not advance` |
| 推送步骤失败 | 用 `_safeStep` 捕获，继续执行剩余推送步骤，但 `lastSyncTime` 不推进 | `[SYNC] Step "<step>" failed, continuing with remaining steps` |

拉取请求失败后还会输出：

```text
[WARNING] ⚠️ [SYNC] Pull failed; skipping push to avoid overwriting cloud data
```

Provider 层对应状态：

```text
Sync failed: Bad state: One or more pull steps failed
```

## 🔍 日志速查

同步域日志大多带 `[SYNC]` 标记（远程数据源错误除外，见下文），
并用 emoji 区分阶段：

- `🔄 [SYNC]` - 同步开始 / 进度
- `✅ [SYNC]` - 同步完成
- `⚠️ [SYNC]` - 部分失败或拉取失败
- `❌ [SYNC]` - 未预期的整体异常

### 成功同步

```text
[INFO] 🔄 [SYNC] Starting sync...
[INFO] 🔄 [SYNC] First sync: false, last sync: 2026-08-25 14:00:00.000Z
[INFO] ✅ [SYNC] Sync completed at 2026-08-25 14:05:00.000
[INFO] Sync completed successfully
```

首次同步（没有 `lastSyncTime`）：

```text
[INFO] 🔄 [SYNC] First sync: true, last sync: null
```

### 拉取请求失败（整轮中止）

```text
[INFO] 🔄 [SYNC] Starting sync...
[ERROR] [SYNC] Pull step "pull_favorites" failed; aborting pull and push
  Error: <异常对象>
  StackTrace: <堆栈>
[WARNING] ⚠️ [SYNC] Pull failed; skipping push to avoid overwriting cloud data
[ERROR] Sync failed: Bad state: One or more pull steps failed
```

### 拉取合并失败（继续，但不推进游标）

```text
[ERROR] [SYNC] Merge step "pull_episodes" left records unmerged; sync cursor will not advance
...
[WARNING] ⚠️ [SYNC] Sync finished with step failures (pull_episodes); lastSyncTime not advanced
```

### 推送步骤失败（继续后续推送）

```text
[ERROR] [SYNC] Step "push_favorites" failed, continuing with remaining steps
  Error: <异常对象>
  StackTrace: <堆栈>
...
[WARNING] ⚠️ [SYNC] Sync finished with step failures (push_favorites); lastSyncTime not advanced
[WARNING] Sync finished partially: push_favorites
```

合并失败与推送失败可以同时出现在括号内的失败步骤列表中。

### 未预期异常

```text
[ERROR] ❌ [SYNC] Sync failed
  Error: <异常对象>
  StackTrace: <堆栈>
```

### 步骤名一览

步骤名与进度回调的 `currentTable` 对应：

| 阶段 | 步骤名 |
| ------ | ------ |
| 拉取 | `pull_podcasts` / `pull_episodes` / `pull_subscriptions` / `pull_playback_history` / `pull_favorites` / `pull_queue_items` |
| 推送 | `push_podcasts` / `push_episodes` / `push_subscriptions` / `push_playback_history` / `push_favorites` / `push_queue_items` |

远程数据源（`RemoteSyncDataSource`）的错误日志**不带** `[SYNC]` 前缀，
消息形如 `upsertPodcasts failed`、`fetchFavorites failed`，级别为 ERROR
并附完整堆栈。同步涉及的六张数据表：`podcasts`、`episodes`、
`user_podcast_subscriptions`、`playback_history`、`favorites`、`queue_items`。
此外 `_ensureUserProfile()` 会单独确保 `profiles` 中存在当前用户记录，其失败
只记录 `[SYNC] Failed to ensure user profile`，不会中止同步。

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
4. 如果只做了收藏/队列/订阅操作，等待周期同步或到设置页手动触发
5. 如果界面一直显示“同步中”，检查是否已有一轮同步尚未结束：
   `syncNow()` 在 `status == syncing` 时会直接返回

### 问题2：部分步骤失败

**症状**：`⚠️ [SYNC] Sync finished with step failures (<steps>); lastSyncTime not advanced`

**排查步骤**：

1. 从括号中读取失败步骤，或向上搜索最近的
   `Step "<step>" failed` / `Merge step "<step>" left records unmerged`
2. 紧跟其后的 `Error:` / `StackTrace:` 行给出根因；若是
   `upsertXxx failed` / `fetchXxx failed`，转问题3
3. `lastSyncTime` 不推进是预期行为：下次同步仍按旧时间增量拉取
   （再减去 2 分钟重叠窗口），修复后重跑一次即可补齐
4. 如果失败步骤是 `pull_*` 的**合并**失败，推送仍可能已经执行；检查本地数据
   是否部分合并，不要只看“最终状态是 error”就认为没有任何写入

### 问题3：远端读写失败

**症状**：`upsertPodcasts failed` /
`fetchPlaybackHistoryUpdatedAfter failed` 等 ERROR

**排查步骤**：

1. 检查网络连通性
2. 检查 Supabase 凭据是否有效（见 supabase_setup.md）
3. 检查 Supabase 侧六张表的表结构与 RLS 策略是否允许当前用户读写
4. 检查 `profiles` 表是否允许当前用户插入/查询

### 问题4：删除没有传播到其他设备

**症状**：本机取消订阅 / 取消收藏 / 移出队列后，其他设备同步后仍存在

**排查步骤**：

1. 搜索 `[SYNC] Deleted cloud subscription <id>` /
   `[SYNC] Deleted cloud favorite <id>` /
   `[SYNC] Deleted cloud queue <id>`，确认删除已推送云端
2. 若有 `[SYNC] Failed to delete cloud ...`，该次同步会以步骤失败告终
   （见问题2），删除记录保留在墓碑中，下次同步自动重试
3. 对端设备上的传播日志为
   `Unsubscribing local podcast (not in cloud)` /
   `Removing local favorite (not in cloud)` /
   `Removing local queue item (not in cloud)`
4. 订阅的删除传播受“最后一次成功推送快照”保护：只有本机成功推送过的订阅，
   才会因云端列表缺失而被取消；从未推送成功的订阅不会被云端反向清除

### 问题5：需要强制全量同步

`lastSyncTime` 存于 `shared_preferences`，键为
`last_sync_timestamp_<userId>`（值为 UTC ISO-8601 字符串）。墓碑与推送快照的键：

| 键 | 内容 |
|----|------|
| `sync_tombstone_subscriptions_<userId>` | 待删除的云端订阅 ID |
| `sync_tombstone_favorites_<userId>` | 待删除的云端收藏 ID |
| `sync_tombstone_queue_<userId>` | 待删除的云端队列项 ID |
| `sync_pushed_subscription_ids_<userId>` | 最后一次成功推送的订阅快照 |

旧版本还有不带用户后缀的 `last_sync_timestamp`、
`sync_tombstone_subscriptions`、`sync_tombstone_favorites`、
`sync_tombstone_queue`、`sync_pushed_subscription_ids`；登出时会被清理。

- **用户路径**：登出再登录。登出会清理该用户的 `lastSyncTime` 与墓碑，
  下次登录后首次同步即为全量
- **开发者路径**：删除 `last_sync_timestamp_<userId>` 后触发一次同步，
  日志中应出现 `First sync: true`。如果希望连待删除记录一起清空，再删除
  对应的 `sync_tombstone_*_<userId>` 与 `sync_pushed_subscription_ids_<userId>`

## 🔗 相关文件

- `lib/core/services/sync_service.dart` — 同步核心（拉取 / 推送 / 合并 / 墓碑）
- `lib/presentation/providers/sync_provider.dart` — 触发时机、周期同步与状态管理
- `lib/data/datasources/remote_sync_datasource.dart` — Supabase 表读写
- `lib/core/services/sync_tombstone_store.dart` — 待删除墓碑与推送快照存储
- `lib/core/services/supabase_service.dart` — 客户端初始化与 `canSync` 前提
- `lib/core/utils/logger.dart` — 日志工具类
