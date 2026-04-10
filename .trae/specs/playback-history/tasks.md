# Tasks

- [x] Task 1: 创建 PlayHistory 数据模型和 Isar Schema
  - [x] 1.1 创建 `/lib/data/models/play_history_model.dart`，定义 PlayHistory 类
  - [x] 1.2 定义 PlayHistoryStatus 枚举（playing, completed, skipped）
  - [x] 1.3 添加所有必需字段（参考 spec.md 字段定义）
  - [x] 1.4 运行 `dart run build_runner build` 生成 .g.dart 文件

- [x] Task 2: 注册 PlayHistorySchema 到数据库
  - [x] 2.1 修改 `/lib/data/database/isar_service.dart`
  - [x] 2.2 在 Isar.open() 的 schemas 列表中添加 PlayHistorySchema
  - [x] 2.3 验证数据库正常初始化

- [x] Task 3: 添加 History 路由配置
  - [x] 3.1 在 `/lib/core/router/app_routes.dart` 中添加 `static const String history = '/history'`
  - [x] 3.2 在 `/lib/core/router/app_router.dart` 中配置 history 路由映射到 History 页面

- [x] Task 4: 修正 Sidebar History 按钮路由
  - [x] 4.1 修改 sidebar.dart L53-61，将 route 从 `AppRoutes.favorite` 改为 `AppRoutes.history`

- [x] Task 5: 创建播放历史数据访问层（Repository）
  - [x] 5.1 创建 `/lib/data/repositories/play_history_repository.dart`
  - [x] 5.2 实现 `getCompletedHistories()` 方法（查询 status=completed, 按 lastUpdateTime 倒序）
  - [x] 5.3 实现 `getLatestPlayingHistory()` 方法（查询最新未完成记录用于恢复）
  - [x] 5.4 实现 `saveOrUpdate()` 方法（创建或更新记录）
  - [x] 5.5 实现 `updateProgress()` 方法（更新进度信息）
  - [x] 5.6 实现 `markAsCompleted()` 方法（标记播放完成）

- [x] Task 6: 创建播放历史 Provider 层
  - [x] 6.1 创建 `/lib/presentation/providers/play_history_provider.dart`
  - [x] 6.2 定义 `playHistoryRepositoryProvider`
  - [x] 6.3 定义 `completedHistoriesProvider` （返回已完成历史列表）
  - [x] 6.4 定义 `latestPlayingHistoryProvider` （返回最新播放中记录）
  - [x] 6.5 定义 `PlayHistoryNotifier` 管理历史记录状态变更

- [x] Task 7: 创建播放历史页面 UI
  - [x] 7.1 创建 `/lib/presentation/features/history/` 目录结构
  - [x] 7.2 创建 `history.dart` 主页面（参考 favorite.dart 结构）
  - [x] 7.3 创建 `history_empty_page/` 空状态组件（参考 favorite_empty_page）
  - [x] 7.4 实现列表展示逻辑：显示已完成记录，按时间倒序
  - [x] 7.5 实现列表项点击事件：重新播放对应 episode

- [x] Task 8: 集成播放进度自动保存到 PlaybackNotifier
  - [x] 8.1 修改 `/lib/presentation/providers/playback_provider.dart`
  - [x] 8.2 在 `playEpisode()` 中调用创建/更新 PlayHistory 记录
  - [x] 8.3 添加定时器或监听器实现进度自动保存（每10秒或5%）
  - [x] 8.4 在 episode 切换时保存上一条记录的最终状态
  - [x] 8.5 在 `stop()` 方法中更新当前记录状态

- [x] Task 9: 实现 MiniPlayer 启动恢复功能
  - [x] 9.1 修改 MiniPlayer 或应用初始化逻辑
  - [x] 9.2 启动时查询 latestPlayingHistoryProvider
  - [x] 9.3 如果找到记录，使用 lastPlayedPositionMs 调用 playEpisode(episode, startPosition)
  - [x] 9.4 如果没有记录，保持 MiniPlayer 默认空状态

# Task Dependencies
- [Task 2] depends on [Task 1] (需要先生成 schema)
- [Task 5] depends on [Task 2] (需要数据库注册完成)
- [Task 6] depends on [Task 5] (provider 依赖 repository)
- [Task 7] depends on [Task 3, Task 4, Task 6] (页面依赖路由、provider)
- [Task 8] depends on [Task 5, Task 6] (集成依赖数据层)
- [Task 9] depends on [Task 6, Task 8] (恢复依赖 provider 和保存逻辑)
