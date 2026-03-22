# 检查清单

## 数据层

- [x] LocalPodcastDataSource.getUnplayedEpisodes 方法已实现
- [x] PodcastRepository 接口已添加 getUnplayedEpisodes 方法
- [x] PodcastRepositoryImpl 已实现 getUnplayedEpisodes 方法
- [x] 查询结果按发布时间倒序排列

## Domain 层

- [x] GetUnplayedEpisodesUseCase 已创建
- [x] 用例返回正确的未播放节目列表

## Presentation 层 - Provider

- [x] UnplayedEpisodesNotifier 已创建
- [x] unplayedEpisodesProvider 已创建
- [x] 加载未播放节目逻辑正常工作
- [x] 节目状态更新逻辑正常工作

## Presentation 层 - 组件

- [x] QueueItem 组件支持接收 Episode 数据
- [x] 封面图展示正常（支持缓存和懒加载）
- [x] 描述最多显示 3 行
- [x] 播放按钮点击逻辑正常工作

## Presentation 层 - 页面

- [x] UpNextQueue 页面连接了 unplayedEpisodesProvider
- [x] 节目列表展示正常
- [x] 空状态展示正常
- [x] 列表项分隔线逻辑正确（最后一项不显示）

## 音频播放服务

- [x] just_audio 和 audio_service 依赖已添加
- [x] AudioPlayerService 已创建
- [x] 后台播放配置正常
- [x] 媒体通知集成正常

## Playback Provider

- [x] PlaybackNotifier 已创建
- [x] playbackProvider 已创建
- [x] 播放/暂停控制正常工作
- [x] 跳转 30 秒控制正常工作
- [x] 播放进度管理正常工作
- [x] 本地文件优先播放逻辑正常工作
- [x] 流式播放逻辑正常工作

## Mini Player

- [x] Mini Player 连接了 playbackProvider
- [x] 播放/暂停按钮正常工作
- [x] 前进/后退 30 秒按钮正常工作
- [x] 进度条展示正常
- [x] 进度条拖动控制正常工作
- [x] 当前播放信息展示正常

## 测试

- [x] LocalPodcastDataSource.getUnplayedEpisodes 测试通过
- [x] GetUnplayedEpisodesUseCase 测试通过
- [x] UnplayedEpisodesNotifier 测试通过
- [x] QueueItem 组件测试通过
- [x] AudioPlayerService 测试通过
- [x] PlaybackNotifier 测试通过
