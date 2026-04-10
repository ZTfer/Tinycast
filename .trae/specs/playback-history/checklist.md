# Checklist

## 数据模型验证
- [ ] PlayHistory 模型包含所有必需字段（id, episodeId, podcastId, title, artworkUrl, lastPlayedPositionMs, isPlayed, playedDuration, status, lastUpdateTime, createdAt, isDeleted）
- [ ] PlayHistoryStatus 枚举定义正确（playing, completed, skipped）
- [ ] Isar schema 生成成功（.g.dart 文件存在）
- [ ] 字段索引配置合理（episodeId, lastUpdateTime 等常用查询字段）

## 数据库集成验证
- [ ] IsarService 成功注册 PlayHistorySchema
- [ ] 应用启动无数据库初始化错误
- [ ] 数据库版本管理正确

## 路由配置验证
- [ ] AppRoutes.history 常量定义正确（'/history'）
- [ ] AppRouter 正确映射 history 路由到 History 页面
- [ ] Sidebar History 按钮路由指向 AppRoutes.history（而非 favorite）

## Repository 层验证
- [ ] getCompletedHistories() 返回已完成记录且按 lastUpdateTime 倒序
- [ ] getLatestPlayingHistory() 返回最新的未完成/播放中记录
- [ ] saveOrUpdate() 能正确创建新记录或更新已有记录
- [ ] updateProgress() 能更新进度字段和 lastUpdateTime
- [ ] markAsCompleted() 能正确设置 isPlayed=true 和 status=completed

## Provider 层验证
- [ ] completedHistoriesProvider 返回正确的数据流
- [ ] latestPlayingHistoryProvider 返回最新播放记录或 null
- [ ] PlayHistoryNotifier 状态管理正常工作

## UI 页面验证
- [ ] History 页面正确显示已完成播放列表
- [ ] 列表按时间倒序排列（最新在前）
- [ ] 列表项显示信息完整（封面、标题、播客名、时间）
- [ ] 空状态页面展示正常（无历史记录时）
- [ ] 点击列表项能重新播放对应 episode
- [ ] 页面样式与 Favorite 页面保持一致

## 播放进度保存验证
- [ ] 开始播放时自动创建/更新 PlayHistory 记录
- [ ] 播放过程中进度定期自动保存（10秒或5%触发）
- [ ] 应用进入后台时立即保存当前进度
- [ ] 切换 episode 时上一条记录状态正确更新
- [ ] 调用 stop() 时记录状态正确保存

## MiniPlayer 启动恢复验证
- [ ] 应用启动时自动查询最新播放记录
- [ ] 找到记录时 MiniPlayer 显示正确的 episode 信息
- [ ] 播放进度从 lastPlayedPositionMs 正确恢复
- [ ] 无记录时 MiniPlayer 保持空状态
- [ ] 恢复后用户可以继续播放

## 边界情况验证
- [ ] Episode 被删除后 PlayHistory 记录仍保留（软删除）
- [ ] 多次快速切换 episode 时数据一致性
- [ ] 数据库操作异常时的错误处理
- [ ] 大量历史记录时的性能表现
