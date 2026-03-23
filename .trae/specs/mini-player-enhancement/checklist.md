# 检查清单

## EpisodeInfo 组件

- [ ] EpisodeInfo 组件展示播客标题
- [ ] 播客标题为空时显示"未知播客"
- [ ] 组件布局和样式正确

## EpisodeProgress 组件

- [ ] EpisodeProgress 组件展示播放进度条
- [ ] 左侧展示已播放时长
- [ ] 右侧展示总时长
- [ ] 时长格式正确（mm:ss 或 HH:mm:ss）
- [ ] 拖动进度条功能正常

## EpisodeControlBar 播放/暂停按钮

- [ ] 播放状态时显示 LucideIcons.pause 图标
- [ ] 暂停状态时显示 LucideIcons.play 图标
- [ ] 图标切换逻辑正确

## VolumeControlBar 音量控制

- [ ] VolumeControlBar 集成 just_audio SDK
- [ ] 音量调整调用 setVolume 方法
- [ ] 音量值转换正确（0-100 到 0.0-1.0）
- [ ] 音量控制条显示当前音量
- [ ] 音量控制功能正常

## EpisodeControlBar 播放速度控制

- [ ] EpisodeControlBar 集成 just_audio SDK
- [ ] 播放速度调整调用 setSpeed 方法
- [ ] 速度按钮显示当前播放速度
- [ ] 速度选项包括：0.5x、0.75x、1x、1.25x、1.5x、2x
- [ ] 播放速度控制功能正常

## 组件测试

- [ ] EpisodeInfo 组件测试通过
- [ ] EpisodeProgress 组件测试通过
- [ ] VolumeControlBar 组件测试通过
- [ ] EpisodeControlBar 组件测试通过
