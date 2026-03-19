# 检查清单

## just_audio 集成

- [ ] just_audio 依赖已添加
- [ ] AudioPlayerService 类已创建
- [ ] AudioPlayer 实例已初始化
- [ ] 播放器参数已配置
- [ ] 播放器状态变化已处理

## audio_service 集成

- [ ] audio_service 依赖已添加
- [ ] AudioHandler 类已创建
- [ ] 后台播放已配置
- [ ] 媒体通知已配置
- [ ] 锁屏控制已实现

## 播放控制

- [ ] play 方法正常工作
- [ ] pause 方法正常工作
- [ ] stop 方法正常工作
- [ ] seek 方法正常工作
- [ ] skipForward 方法正常工作
- [ ] skipBackward 方法正常工作
- [ ] setSpeed 方法正常工作
- [ ] setVolume 方法正常工作

## 播放状态管理

- [ ] PlaybackState 类已创建
- [ ] PlaybackNotifier 类已创建
- [ ] playbackProvider 已创建
- [ ] 播放状态流正常工作
- [ ] 播放进度流正常工作
- [ ] 错误状态管理正常工作

## 播放位置持久化

- [ ] Episode 模型已添加 playbackPosition 字段
- [ ] 保存播放位置方法正常工作
- [ ] 加载播放位置方法正常工作
- [ ] 定期保存逻辑正常工作
- [ ] 应用启动时恢复逻辑正常工作

## 播放完成处理

- [ ] 播放完成事件已监听
- [ ] 节目标记为已播放正常工作
- [ ] 自动播放下一集逻辑正常工作
- [ ] 队列管理已集成

## 迷你播放器

- [ ] PlaybackProvider 连接正常
- [ ] 当前播放节目信息显示正常
- [ ] 播放/暂停按钮正常工作
- [ ] 快进/快退按钮正常工作
- [ ] 播放进度条正常工作
- [ ] 播放速度下拉菜单正常工作
- [ ] 音量控制正常工作

## 错误处理

- [ ] 播放错误处理正常
- [ ] 网络错误处理正常
- [ ] 错误提示显示正常
- [ ] 重试机制正常工作
- [ ] 错误日志记录正常

## 用例

- [ ] PlayEpisodeUseCase 已创建
- [ ] PauseEpisodeUseCase 已创建
- [ ] SeekEpisodeUseCase 已创建
- [ ] SetPlaybackSpeedUseCase 已创建
- [ ] SetVolumeUseCase 已创建

## 单元测试

- [ ] AudioPlayerService 测试通过
- [ ] AudioHandler 测试通过
- [ ] 播放控制方法测试通过
- [ ] 播放状态管理测试通过
- [ ] 播放位置持久化测试通过

## 组件测试

- [ ] MiniPlayer 组件测试通过
- [ ] 播放控制按钮测试通过
- [ ] 进度条组件测试通过
- [ ] 播放速度下拉菜单测试通过

## 集成测试

- [ ] 完整播放流程测试通过
- [ ] 后台播放测试通过
- [ ] 播放位置恢复测试通过
- [ ] 播放完成处理测试通过
