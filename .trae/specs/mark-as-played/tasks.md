# Tasks

- [x] Task 1: 在数据源层添加更新 episode.isPlayed 的方法
  - [x] 在 `local_podcast_datasource.dart` 中添加 `updateIsPlayed(int episodeId, bool isPlayed)` 方法
  - [x] 使用 Isar 查询并更新对应 episode 的 isPlayed 字段
  - [x] 在事务中执行更新操作

- [x] Task 2: 在仓库层添加接口和实现
  - [x] 在 `podcast_repository.dart` 接口中添加 `Future<void> updateIsPlayed(int episodeId, bool isPlayed)` 方法
  - [x] 在 `podcast_repository_impl.dart` 中实现该方法，调用数据源

- [x] Task 3: 创建/更新 PlayHistory 数据源方法（如果不存在）
  - [x] 检查是否存在 PlayHistory 数据源文件
  - [x] 如果不存在，在 `local_podcast_datasource.dart` 或新建文件中添加 PlayHistory 操作方法
  - [x] 实现 `updateOrCreatePlayHistoryAsCompleted(int episodeId)` 方法：
    - 查询是否已存在该 episodeId 的记录
    - 如果存在：更新 isPlayed=true, status=completed, lastUpdateTime=now（不修改 playedDuration）
    - 如果不存在：创建新记录，playedDuration=0, status=completed

- [x] Task 4: 在 EpisodeDropdown 中添加 onMarkAsPlayed 回调参数
  - [x] 添加 `final VoidCallback? onMarkAsPlayed;` 字段
  - [x] 在构造函数中添加参数
  - [x] 更新"标记为已播放"菜单项的 onPressed：
    ```dart
    onPressed: () {
      onMarkAsPlayed?.call();
      _handleItemSelected();
    },
    ```

- [x] Task 5: 在 EpisodeControlBar 中实现标记已播放业务逻辑
  - [x] 导入必要的 provider 和工具类
  - [x] 实现 `_handleMarkAsPlayed()` async 方法：
    1. 调用 podcastRepository.updateIsPlayed(episodeId, true)
    2. 调用 playHistory 数据源的 updateOrCreatePlayHistoryAsCompleted(episodeId)
    3. 调用 queueNotifierProvider.notifier.removeFromQueue(episodeId)（如果存在）
    4. 显示 ToastUtils.showSuccessToast(context, message: '已标记为已播放')
    5. 错误处理：catch 异常并显示错误 Toast

- [x] Task 6: 集成到 EpisodeControlBar 并传递回调
  - [x] 在 EpisodeDropdown 组件使用处传入 `onMarkAsPlayed: _handleMarkAsPlayed`
  - [x] 确保导入所有必要的依赖

- [x] Task 7: 验证功能完整性
  - [x] 测试标记已播放后 episode.isPlayed 是否更新
  - [x] 测试 PlayHistory 记录是否正确创建/更新（status=completed）
  - [x] 测试 playedDuration 是否未被修改
  - [x] 测试如果在 queue 中是否被自动移除
  - [x] 测试 queue UI 是否刷新
  - [x] 测试 Toast 是否正确显示

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 4] can be done in parallel with [Task 1, 2, 3]
- [Task 5] depends on [Task 1, 2, 3, 4]
- [Task 6] depends on [Task 5]
- [Task 7] depends on [Task 6]
