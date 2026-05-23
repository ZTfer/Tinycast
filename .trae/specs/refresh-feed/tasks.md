# 任务列表

- [ ] 任务 1：扩展数据模型 - 新增刷新相关字段
  - [ ] 子任务 1.1：在 Podcast 实体新增 `lastFetchedAt`、`refreshFailedCount` 字段
  - [ ] 子任务 1.2：在 Podcast Isar 模型新增对应字段和索引
  - [ ] 子任务 1.3：运行 build_runner 生成新 schema
  - [ ] 子任务 1.4：更新 PodcastMapper 映射逻辑

- [ ] 任务 2：扩展 AppSettings - 新增刷新偏好设置
  - [ ] 子任务 2.1：定义 FeedRefreshInterval 枚举
  - [ ] 子任务 2.2：在 AppSettings 实体新增刷新相关字段
  - [ ] 子任务 2.3：在 AppSettingsModel 新增对应字段
  - [ ] 子任务 2.4：更新 SettingsService 读写方法
  - [ ] 子任务 2.5：运行 build_runner 生成新 schema

- [ ] 任务 3：创建 FeedRefreshService - 核心增量更新服务
  - [ ] 子任务 3.1：定义 FeedRefreshResult 和 BatchRefreshResult 结果类
  - [ ] 子任务 3.2：实现 `refreshSingleFeed` 方法（单个播客增量更新）
  - [ ] 子任务 3.3：实现 `_detectNewEpisodes` 方法（通过 guid 对比检测新增）
  - [ ] 子任务 3.4：实现 `_saveNewEpisodes` 方法（仅保存新增剧集）
  - [ ] 子任务 3.5：实现防抖动机制（5 分钟冷却时间）
  - [ ] 子任务 3.6：实现连续失败降级逻辑（3 次失败后延长间隔）

- [ ] 任务 4：创建 NetworkConnectivityService - 网络状态检测服务
  - [ ] 子任务 4.1：实现 WiFi/蜂窝/无网络状态检测
  - [ ] 子任务 4.2：实现 `canRefresh()` 方法根据设置和网络状态判断
  - [ ] 子任务 4.3：实现网络状态变化监听

- [ ] 任务 5：创建 FeedRefreshScheduler - 刷新调度器
  - [ ] 子任务 5.1：实现定时刷新机制（基于用户设置的频率）
  - [ ] 子任务 5.2：实现后台刷新开关控制
  - [ ] 子任务 5.3：实现电池状态检查（低电量暂停刷新）
  - [ ] 子任务 5.4：实现调度器的启动/停止生命周期

- [ ] 任务 6：扩展 PodcastRepository - 新增刷新方法
  - [ ] 子任务 6.1：在 PodcastRepository 接口新增 `refreshPodcastFeed` 方法
  - [ ] 子任务 6.2：在 PodcastRepositoryImpl 实现刷新逻辑（调用 FeedRefreshService）
  - [ ] 子任务 6.3：新增 `refreshAllFeeds` 批量刷新方法
  - [ ] 子任务 6.4：实现并发控制（最多 3 个并行任务）

- [ ] 任务 7：扩展 LocalPodcastDataSource - 新增刷新数据操作
  - [ ] 子任务 7.1：新增 `updateLastFetchedAt` 方法
  - [ ] 子任务 7.2：新增 `updateRefreshFailedCount` 方法
  - [ ] 子任务 7.3：新增 `getExistingEpisodeGuids` 方法（用于对比检测新增）
  - [ ] 子任务 7.4：实现批量插入新增剧集方法（避免重复写入）

- [ ] 任务 8：创建 FeedRefreshNotifier - Riverpod 状态管理
  - [ ] 子任务 8.1：创建 FeedRefreshState 状态类
  - [ ] 子任务 8.2：创建 feedRefreshProvider
  - [ ] 子任务 8.3：实现 `refreshAll` 方法（批量刷新）
  - [ ] 子任务 8.4：实现 `refreshSingle` 方法（单个刷新）
  - [ ] 子任务 8.5：实现刷新进度和结果展示状态

- [ ] 任务 9：扩展 Library 页面 - 支持下拉刷新
  - [ ] 子任务 9.1：在 Library 页面添加 RefreshIndicator
  - [ ] 子任务 9.2：连接 feedRefreshProvider 实现下拉刷新逻辑
  - [ ] 子任务 9.3：刷新期间显示进度指示器
  - [ ] 子任务 9.4：刷新完成后展示结果 Toast（新增剧集数量）

- [ ] 任务 10：创建刷新设置页面
  - [ ] 子任务 10.1：在设置页面新增"刷新设置"入口
  - [ ] 子任务 10.2：实现刷新频率下拉选择
  - [ ] 子任务 10.3：实现"仅 WiFi 刷新"开关
  - [ ] 子任务 10.4：实现"刷新通知"开关
  - [ ] 子任务 10.5：实现"后台刷新"开关

- [ ] 任务 11：应用启动时初始化调度器
  - [ ] 子任务 11.1：在 main.dart 或 App 启动时初始化 FeedRefreshScheduler
  - [ ] 子任务 11.2：根据设置启动/停止定时刷新
  - [ ] 子任务 11.3：处理应用前后台切换时的调度器状态

- [ ] 任务 12：错误处理与用户体验优化
  - [ ] 子任务 12.1：实现刷新失败时的 UI 警告图标
  - [ ] 子任务 12.2：实现新剧集通知功能（可选）
  - [ ] 子任务 12.3：实现刷新日志记录

## 任务依赖关系说明

- [任务 2] 依赖于 [任务 1]（模型需要先扩展才能用）
- [任务 3] 依赖于 [任务 1]（需要新字段支持）
- [任务 4] 无依赖（可并行）
- [任务 5] 依赖于 [任务 2, 任务 4]（需要设置和网络状态）
- [任务 6] 依赖于 [任务 3, 任务 7]（需要服务和数据源）
- [任务 7] 依赖于 [任务 1]（需要新字段）
- [任务 8] 依赖于 [任务 6]（需要 Repository 方法）
- [任务 9] 依赖于 [任务 8]（需要 Provider）
- [任务 10] 依赖于 [任务 2]（需要设置支持）
- [任务 11] 依赖于 [任务 5]（需要调度器）
- [任务 12] 依赖于 [任务 8, 任务 9]（需要 UI 状态）

## 并行执行建议

可同时启动的独立任务组：
- 组 A：任务 1, 任务 4（模型扩展和网络检测服务独立）
- 组 B：任务 3, 任务 7（服务和数据源可并行开发，约定接口）
- 组 C：任务 9, 任务 10（UI 相关可并行）