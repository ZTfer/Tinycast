# 队列播放控制 Spec

## 为什么

用户需要在播放队列中控制每个音频的播放和暂停。播放按钮应根据当前音频的播放状态显示不同的图标（播放/暂停），而不是所有音频的状态都同步变化。

## 变更内容

- 增强 QueuePlayPauseButton 组件，根据当前播放音频的状态显示播放/暂停图标
- 确保只有当前正在播放的音频显示暂停图标，其他音频显示播放图标
- 点击播放按钮时调用 playbackProvider 的播放控制方法

## 影响

- 受影响的规格：audio-playback, mini-player-enhancement
- 受影响的代码：
  - `lib/presentation/widgets/atoms/buttons/queue_play_pause_button.dart`
  - `lib/presentation/pages/up_next_queue/queue_control_bar/queue_control_bar.dart`
  - `lib/presentation/pages/up_next_queue/queue_item/queue_item.dart`

## 新增需求

### 需求：队列播放按钮状态显示

系统应根据当前播放音频的状态在队列中显示正确的播放/暂停图标。

#### 场景：当前播放的音频

- **当** 队列中的音频是当前正在播放的音频
- **则** 如果正在播放，显示暂停图标（LucideIcons.pause）
- **并且** 如果暂停，显示播放图标（LucideIcons.play）

#### 场景：非当前播放的音频

- **当** 队列中的音频不是当前正在播放的音频
- **则** 始终显示播放图标（LucideIcons.play）

### 需求：队列播放按钮点击行为

系统应在用户点击播放按钮时正确控制播放。

#### 场景：点击当前播放的音频

- **当** 用户点击当前正在播放的音频的播放按钮
- **则** 调用 playbackProvider.pause() 暂停播放

#### 场景：点击非当前播放的音频

- **当** 用户点击非当前播放的音频的播放按钮
- **则** 调用 playbackProvider.playEpisode() 开始播放该音频

## 修改的需求

无

## 移除的需求

无
