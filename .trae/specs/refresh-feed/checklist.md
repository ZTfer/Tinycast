# 检查清单

## 数据模型扩展
- [ ] Podcast 实体新增 `lastFetchedAt` 字段（DateTime?）
- [ ] Podcast 实体新增 `refreshFailedCount` 字段（int）
- [ ] Podcast Isar 模型新增对应字段
- [ ] PodcastMapper 正确映射新字段
- [ ] build_runner 成功生成新 schema

## 设置扩展
- [ ] FeedRefreshInterval 枚举定义完整（手动、1h、3h、6h、12h、24h）
- [ ] AppSettings 新增 `feedRefreshInterval` 字段
- [ ] AppSettings 新增 `refreshOnCellular` 字段
- [ ] AppSettings 新增 `notifyOnNewEpisodes` 字段
- [ ] AppSettings 新增 `backgroundRefreshEnabled` 字段
- [ ] AppSettingsModel 同步新增对应字段
- [ ] SettingsService 新增读写方法
- [ ] build_runner 成功生成新 schema

## 核心服务
- [ ] FeedRefreshService 类创建
- [ ] FeedRefreshResult 结果类定义（新增数量、错误列表）
- [ ] BatchRefreshResult 批量结果类定义（总新增、失败列表）
- [ ] `refreshSingleFeed` 方法实现增量更新
- [ ] 通过 guid 对比检测新增剧集
- [ ] 仅保存新增剧集，不重复写入
- [ ] 防抖动机制实现（5 分钟冷却）
- [ ] 连续失败降级实现（3 次失败延长间隔）
- [ ] 失败时更新 `lastFetchedAt` 避免频繁重试

## 网络服务
- [ ] NetworkConnectivityService 类创建
- [ ] WiFi/蜂窝/无网络状态检测实现
- [ ] `canRefresh()` 方法根据设置和网络状态判断
- [ ] 网络状态变化监听实现

## 调度器
- [ ] FeedRefreshScheduler 类创建
- [ ] 定时刷新机制实现（基于用户设置频率）
- [ ] 后台刷新开关控制实现
- [ ] 电池状态检查实现（低电量暂停）
- [ ] 调度器启动/停止生命周期管理
- [ ] 应用前后台切换时正确更新调度器状态

## Repository 扩展
- [ ] PodcastRepository 接口新增 `refreshPodcastFeed` 方法
- [ ] PodcastRepository 接口新增 `refreshAllFeeds` 方法
- [ ] PodcastRepositoryImpl 实现调用 FeedRefreshService
- [ ] 批量刷新并发控制（最多 3 个并行）
- [ ] 批量刷新中单个失败不中断整体流程

## 数据源扩展
- [ ] LocalPodcastDataSource 新增 `updateLastFetchedAt` 方法
- [ ] LocalPodcastDataSource 新增 `updateRefreshFailedCount` 方法
- [ ] LocalPodcastDataSource 新增 `getExistingEpisodeGuids` 方法
- [ ] 批量插入新增剧集方法实现（避免重复）

## 状态管理
- [ ] FeedRefreshState 状态类创建
- [ ] feedRefreshProvider 创建
- [ ] `refreshAll` 方法实现
- [ ] `refreshSingle` 方法实现
- [ ] 刷新进度状态管理
- [ ] 刷新结果状态管理

## UI 实现
- [ ] Library 页面添加 RefreshIndicator
- [ ] 下拉刷新连接 feedRefreshProvider
- [ ] 刷新期间显示进度指示器
- [ ] 刷新完成后展示 Toast 提示
- [ ] 刷新失败显示警告图标
- [ ] 新剧集通知功能（可选开关）

## 设置页面
- [ ] 设置页面新增"刷新设置"入口
- [ ] 刷新频率下拉选择实现
- [ ] "仅 WiFi 刷新"开关实现
- [ ] "刷新通知"开关实现
- [ ] "后台刷新"开关实现

## 初始化
- [ ] 应用启动时初始化 FeedRefreshScheduler
- [ ] 根据设置启动定时刷新
- [ ] 处理应用前后台切换

## 代码质量
- [ ] 新增代码遵循项目现有风格
- [ ] Logger 日志记录完整
- [ ] 错误处理完善，无未捕获异常
- [ ] 无硬编码魔法值，使用常量
- [ ] Dart analyzer 无错误或警告
