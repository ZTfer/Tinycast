# 检查清单

## 数据层

- [ ] LocalPodcastDataSource.getUnplayedEpisodes 方法已实现
- [ ] PodcastRepository 接口已添加 getUnplayedEpisodes 方法
- [ ] PodcastRepositoryImpl 已实现 getUnplayedEpisodes 方法
- [ ] 查询结果按发布时间倒序排列

## Domain 层

- [ ] GetUnplayedEpisodesUseCase 已创建
- [ ] 用例返回正确的未播放节目列表

## Presentation 层 - Provider

- [ ] UnplayedEpisodesNotifier 已创建
- [ ] unplayedEpisodesProvider 已创建
- [ ] 加载未播放节目逻辑正常工作
- [ ] 节目状态更新逻辑正常工作

## Presentation 层 - 组件

- [ ] QueueItem 组件支持接收 Episode 数据
- [ ] 封面图展示正常（支持缓存和懒加载）
- [ ] 描述最多显示 3 行
- [ ] 播放按钮点击逻辑正常工作

## Presentation 层 - 页面

- [ ] UpNextQueue 页面连接了 unplayedEpisodesProvider
- [ ] 节目列表展示正常
- [ ] 空状态展示正常
- [ ] 列表项分隔线逻辑正确（最后一项不显示）

## 音频播放服务

- [ ] just_audio 和 audio_service 依赖已添加
- [ ] AudioPlayerService 已创建
- [ ] 后台播放配置正常
- [ ] 媒体通知集成正常

## Playback Provider

- [ ] PlaybackNotifier 已创建
- [ ] playbackProvider 已创建
- [ ] 播放/暂停控制正常工作
- [ ] 跳转 30 秒控制正常工作
- [ ] 播放进度管理正常工作
- [ ] 本地文件优先播放逻辑正常工作
- [ ] 流式播放逻辑正常工作

## Mini Player

- [ ] Mini Player 连接了 playbackProvider
- [ ] 播放/暂停按钮正常工作
- [ ] 前进/后退 30 秒按钮正常工作
- [ ] 进度条展示正常
- [ ] 进度条拖动控制正常工作
- [ ] 当前播放信息展示正常

## 测试

- [ ] LocalPodcastDataSource.getUnplayedEpisodes 测试通过
- [ ] GetUnplayedEpisodesUseCase 测试通过
- [ ] UnplayedEpisodesNotifier 测试通过
- [ ] QueueItem 组件测试通过
- [ ] AudioPlayerService 测试通过
- [ ] PlaybackNotifier 测试通过
