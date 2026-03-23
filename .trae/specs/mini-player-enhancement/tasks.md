# 任务列表

- [x] 任务 1：增强 EpisodeInfo 组件展示播客标题
  - [x] 子任务 1.1：读取当前 EpisodeInfo 组件代码
  - [x] 子任务 1.2：添加播客标题展示逻辑
  - [x] 子任务 1.3：实现空标题时显示"未知播客"的 fallback 逻辑
  - [x] 子任务 1.4：验证组件显示效果

- [x] 任务 2：增强 EpisodeProgress 组件展示播放时长
  - [x] 子任务 2.1：读取当前 EpisodeProgress 组件代码
  - [x] 子任务 2.2：添加已播放时长显示（左侧）
  - [x] 子任务 2.3：添加总时长显示（右侧）
  - [x] 子任务 2.4：实现时长格式化（mm:ss 或 HH:mm:ss）
  - [x] 子任务 2.5：验证拖动进度条功能

- [x] 任务 3：验证 EpisodeControlBar 播放/暂停按钮图标
  - [x] 子任务 3.1：读取当前 EpisodeControlBar 组件代码
  - [x] 子任务 3.2：验证播放状态时显示 LucideIcons.pause 图标
  - [x] 子任务 3.3：验证暂停状态时显示 LucideIcons.play 图标
  - [x] 子任务 3.4：验证图标切换逻辑

- [x] 任务 4：增强 VolumeControlBar 集成 just_audio SDK
  - [x] 子任务 4.1：读取当前 VolumeControlBar 组件代码
  - [x] 子任务 4.2：获取 playbackProvider 的音量状态
  - [x] 子任务 4.3：实现音量调整时调用 just_audio SDK 的 setVolume 方法
  - [x] 子任务 4.4：实现音量值转换（0-100 到 0.0-1.0）
  - [x] 子任务 4.5：验证音量控制功能

- [x] 任务 5：增强 EpisodeControlBar 播放速度控制
  - [x] 子任务 5.1：读取当前 EpisodeControlBar 组件代码
  - [x] 子任务 5.2：获取 playbackProvider 的播放速度状态
  - [x] 子任务 5.3：实现播放速度调整时调用 just_audio SDK 的 setSpeed 方法
  - [x] 子任务 5.4：实现播放速度显示（速度按钮上显示当前速度）
  - [x] 子任务 5.5：验证播放速度控制功能

- [x] 任务 6：编写组件测试
  - [x] 子任务 6.1：测试 EpisodeInfo 组件播客标题展示
  - [x] 子任务 6.2：测试 EpisodeProgress 组件时长显示
  - [x] 子任务 6.3：测试 VolumeControlBar 音量控制
  - [x] 子任务 6.4：测试 EpisodeControlBar 播放速度控制

## 任务依赖关系

- [任务 4] 依赖于 [任务 3]
- [任务 5] 依赖于 [任务 3]
- [任务 6] 依赖于 [任务 1, 任务 2, 任务 3, 任务 4, 任务 5]
