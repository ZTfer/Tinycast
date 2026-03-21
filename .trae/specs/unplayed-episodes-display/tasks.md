# 任务列表

- [ ] 任务 1：实现数据层获取未播放节目功能
  - [ ] 子任务 1.1：在 LocalPodcastDataSource 添加 getUnplayedEpisodes 方法
  - [ ] 子任务 1.2：在 PodcastRepository 接口添加 getUnplayedEpisodes 方法
  - [ ] 子任务 1.3：在 PodcastRepositoryImpl 实现 getUnplayedEpisodes 方法

- [ ] 任务 2：实现 Domain 层用例
  - [ ] 子任务 2.1：创建 GetUnplayedEpisodesUseCase
  - [ ] 子任务 2.2：实现按发布时间倒序排列逻辑

- [ ] 任务 3：创建 Riverpod Provider
  - [ ] 子任务 3.1：创建 UnplayedEpisodesNotifier
  - [ ] 子任务 3.2：创建 unplayedEpisodesProvider
  - [ ] 子任务 3.3：实现加载未播放节目逻辑
  - [ ] 子任务 3.4：实现节目状态更新逻辑

- [ ] 任务 4：更新 QueueItem 组件
  - [ ] 子任务 4.1：更新 QueueItem 支持接收 Episode 数据
  - [ ] 子任务 4.2：实现封面图展示（支持缓存和懒加载）
  - [ ] 子任务 4.3：实现描述最多 3 行显示
  - [ ] 子任务 4.4：实现播放按钮点击逻辑

- [ ] 任务 5：更新 UpNextQueue 页面
  - [ ] 子任务 5.1：连接 unplayedEpisodesProvider
  - [ ] 子任务 5.2：实现节目列表展示
  - [ ] 子任务 5.3：实现空状态展示
  - [ ] 子任务 5.4：实现列表项分隔线逻辑

- [ ] 任务 6：集成 just_audio + audio_service
  - [ ] 子任务 6.1：添加 just_audio 和 audio_service 依赖
  - [ ] 子任务 6.2：创建 AudioPlayerService
  - [ ] 子任务 6.3：实现后台播放配置
  - [ ] 子任务 6.4：实现媒体通知集成

- [ ] 任务 7：创建 PlaybackProvider
  - [ ] 子任务 7.1：创建 PlaybackNotifier
  - [ ] 子任务 7.2：创建 playbackProvider
  - [ ] 子任务 7.3：实现播放/暂停控制
  - [ ] 子任务 7.4：实现跳转 30 秒控制
  - [ ] 子任务 7.5：实现播放进度管理
  - [ ] 子任务 7.6：实现本地文件优先播放逻辑
  - [ ] 子任务 7.7：实现流式播放逻辑

- [ ] 任务 8：更新 Mini Player
  - [ ] 子任务 8.1：连接 playbackProvider
  - [ ] 子任务 8.2：实现播放/暂停按钮
  - [ ] 子任务 8.3：实现前进/后退 30 秒按钮
  - [ ] 子任务 8.4：实现进度条展示
  - [ ] 子任务 8.5：实现进度条拖动控制
  - [ ] 子任务 8.6：实现当前播放信息展示

- [ ] 任务 9：编写测试
  - [ ] 子任务 9.1：测试 LocalPodcastDataSource.getUnplayedEpisodes
  - [ ] 子任务 9.2：测试 GetUnplayedEpisodesUseCase
  - [ ] 子任务 9.3：测试 UnplayedEpisodesNotifier
  - [ ] 子任务 9.4：测试 QueueItem 组件
  - [ ] 子任务 9.5：测试 AudioPlayerService
  - [ ] 子任务 9.6：测试 PlaybackNotifier

## 任务依赖关系说明

- [任务 2] 依赖于 [任务 1]
- [任务 3] 依赖于 [任务 2]
- [任务 4] 无依赖，可并行执行
- [任务 5] 依赖于 [任务 3, 任务 4]
- [任务 6] 无依赖，可并行执行
- [任务 7] 依赖于 [任务 6]
- [任务 8] 依赖于 [任务 7]
- [任务 9] 依赖于 [任务 1, 任务 2, 任务 3, 任务 4, 任务 6, 任务 7]
