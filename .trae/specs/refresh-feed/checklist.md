# 检查清单

## 数据模型扩展
- [x] Podcast 实体新增 `lastFetchedAt` 字段（DateTime?）
- [x] Podcast 实体新增 `refreshFailedCount` 字段（int）
- [x] Podcast Isar 模型新增对应字段
- [x] PodcastMapper 正确映射新字段
- [x] build_runner 成功生成新 schema

## 设置扩展
- [x] FeedRefreshInterval 枚举定义完整（手动、1h、3h、6h、12h、24h）
- [x] AppSettings 新增 `feedRefreshInterval` 字段
- [x] AppSettings 新增 `refreshOnCellular` 字段
- [x] AppSettings 新增 `notifyOnNewEpisodes` 字段
- [x] AppSettings 新增 `backgroundRefreshEnabled` 字段
- [x] AppSettingsModel 同步新增对应字段
- [x] SettingsService 新增读写方法
- [x] build_runner 成功生成新 schema

## 核心服务
- [x] FeedRefreshService 类创建
- [x] FeedRefreshResult 结果类定义（新增数量、错误列表）
- [x] BatchRefreshResult 批量结果类定义（总新增、失败列表）
- [x] `refreshSingleFeed` 方法实现增量更新
- [x] 通过 guid 对比检测新增剧集
- [x] 仅保存新增剧集，不重复写入
- [x] 防抖动机制实现（5 分钟冷却）
- [x] 连续失败降级实现（3 次失败延长间隔）
- [x] 失败时更新 `lastFetchedAt` 避免频繁重试

## 网络服务
- [x] NetworkConnectivityService 类创建
- [x] WiFi/蜂窝/无网络状态检测实现
- [x] `canRefresh()` 方法根据设置和网络状态判断
- [x] 网络状态变化监听实现

## 调度器
- [x] FeedRefreshScheduler 类创建
- [x] 定时刷新机制实现（基于用户设置频率）
- [x] 后台刷新开关控制实现
- [x] 电池状态检查实现（低电量暂停）
- [x] 调度器启动/停止生命周期管理
- [x] 应用前后台切换时正确更新调度器状态

## Repository 扩展
- [x] PodcastRepository 接口新增 `refreshPodcastFeed` 方法
- [x] PodcastRepository 接口新增 `refreshAllFeeds` 方法
- [x] PodcastRepositoryImpl 实现调用 FeedRefreshService
- [x] 批量刷新并发控制（最多 3 个并行）
- [x] 批量刷新中单个失败不中断整体流程

## 数据源扩展
- [x] LocalPodcastDataSource 新增 `updateLastFetchedAt` 方法
- [x] LocalPodcastDataSource 新增 `updateRefreshFailedCount` 方法
- [x] LocalPodcastDataSource 新增 `getExistingEpisodeGuids` 方法
- [x] 批量插入新增剧集方法实现（避免重复）

## 状态管理
- [x] FeedRefreshState 状态类创建
- [x] feedRefreshProvider 创建
- [x] `refreshAll` 方法实现
- [x] `refreshSingle` 方法实现
- [x] 刷新进度状态管理
- [x] 刷新结果状态管理

## UI 实现
- [x] Library 页面添加 RefreshIndicator
- [x] 下拉刷新连接 feedRefreshProvider
- [x] 刷新期间显示进度指示器
- [x] 刷新完成后展示 Toast 提示
- [x] 刷新失败显示警告图标
- [x] 新剧集通知功能（可选开关）

## 设置页面
- [x] 设置页面新增"刷新设置"入口
- [x] 刷新频率下拉选择实现
- [x] "仅 WiFi 刷新"开关实现
- [x] "刷新通知"开关实现
- [x] "后台刷新"开关实现

## 初始化
- [x] 应用启动时初始化 FeedRefreshScheduler
- [x] 根据设置启动定时刷新
- [x] 处理应用前后台切换

## 代码质量
- [x] 新增代码遵循项目现有风格
- [x] Logger 日志记录完整
- [x] 错误处理完善，无未捕获异常
- [x] 无硬编码魔法值，使用常量
- [x] Dart analyzer 无错误或警告
