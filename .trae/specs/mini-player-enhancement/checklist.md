# 检查清单

## EpisodeInfo 组件

- [x] EpisodeInfo 组件展示播客标题
- [x] 播客标题为空时显示"未知播客"
- [x] 组件布局和样式正确

## EpisodeProgress 组件

- [x] EpisodeProgress 组件展示播放进度条
- [x] 左侧展示已播放时长
- [x] 右侧展示总时长
- [x] 时长格式正确（mm:ss 或 HH:mm:ss）
- [x] 拖动进度条功能正常

## EpisodeControlBar 播放/暂停按钮

- [x] 播放状态时显示 LucideIcons.pause 图标
- [x] 暂停状态时显示 LucideIcons.play 图标
- [x] 图标切换逻辑正确

## VolumeControlBar 音量控制

- [x] VolumeControlBar 集成 just_audio SDK
- [x] 音量调整调用 setVolume 方法
- [x] 音量值转换正确（0-100 到 0.0-1.0）
- [x] 音量控制条显示当前音量
- [x] 音量控制功能正常

## EpisodeControlBar 播放速度控制

- [x] EpisodeControlBar 集成 just_audio SDK
- [x] 播放速度调整调用 setSpeed 方法
- [x] 速度按钮显示当前播放速度
- [x] 速度选项包括：0.5x、0.75x、1x、1.25x、1.5x、2x
- [x] 播放速度控制功能正常

## 组件测试

- [x] EpisodeInfo 组件测试通过
- [x] EpisodeProgress 组件测试通过
- [x] VolumeControlBar 组件测试通过
- [x] EpisodeControlBar 组件测试通过
