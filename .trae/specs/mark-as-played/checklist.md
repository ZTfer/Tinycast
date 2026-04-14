# Checklist

## 数据层实现
- [ ] `local_podcast_datasource.dart` 包含 `updateIsPlayed(int episodeId, bool isPlayed)` 方法
- [ ] 该方法使用 Isar 事务正确更新 episode 的 isPlayed 字段
- [ ] PlayHistory 数据源包含更新/创建记录的方法（或已确认存在）
- [ ] PlayHistory 更新逻辑：设置 isPlayed=true, status=completed, lastUpdateTime=now
- [ ] PlayHistory 更新逻辑：**不修改** playedDuration 字段值

## 仓库层实现
- [ ] `podcast_repository.dart` 接口定义了 `updateIsPlayed` 方法
- [ ] `podcast_repository_impl.dart` 正确实现了该方法
- [ ] PlayHistory 仓库（如果需要）正确实现了更新方法

## UI 层实现 - EpisodeDropdown
- [ ] EpisodeDropdown 组件包含 `onMarkAsPlayed` 回调参数
- [ ] 构造函数正确接收该参数
- [ ] "标记为已播放"菜单项的 onPressed 调用 `onMarkAsPlayed?.call()` 和 `_handleItemSelected()`

## UI 层实现 - EpisodeControlBar
- [ ] EpisodeControlBar 导入了所有必要的依赖（providers、toast_utils）
- [ ] 实现了 `_handleMarkAsPlayed()` async 方法
- [ ] 该方法按顺序执行：更新 episode 状态 → 更新 PlayHistory → 移除 queue → 显示 Toast
- [ ] 包含完整的错误处理（try-catch 和错误 Toast）

## 集成与回调传递
- [ ] EpisodeDropdown 使用处传入了 `onMarkAsPassed: _handleMarkAsPlayed`
- [ ] 回调函数能正确访问 widget.episodeId

## 功能验证
- [ ] 点击"标记为已播放"后，episode.isPlayed 在数据库中更新为 true
- [ ] PlayHistory 记录被创建或更新（status=completed, isPlayed=true）
- [ ] PlayHistory.playedDuration 未被修改（保持原值或为 0）
- [ ] 如果该 episode 在 queue 中，被自动移除
- [ ] queue.dart UI 刷新后不再显示该 episode
- [ ] 显示成功 Toast "已标记为已播放"
- [ ] 下拉菜单在操作完成后关闭
