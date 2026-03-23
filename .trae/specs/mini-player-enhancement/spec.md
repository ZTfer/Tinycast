# 迷你播放器增强 Spec

## 为什么

迷你播放器需要更好地展示播放信息和提供更完善的控制功能。用户需要能够查看播客标题、播放进度、控制音量和播放速度。

## 变更内容

- 增强 EpisodeInfo 组件，展示播客标题（无标题时显示"未知播客"）
- 增强 EpisodeProgress 组件，展示已播放时长和总时长
- 增强 EpisodeControlBar 组件，正确显示播放/暂停图标
- 增强 VolumeControlBar 组件，通过 just_audio SDK 控制音量
- 增强 EpisodeControlBar 组件，通过 just_audio SDK 控制播放速度并显示当前速度

## 影响

- 受影响的规格：audio-playback
- 受影响的代码：
  - `lib/presentation/widgets/molecules/mini_player/episode_info.dart`
  - `lib/presentation/widgets/molecules/mini_player/mini_player.dart`
  - `lib/presentation/widgets/molecules/mini_player/episode_control_bar/episode_control_bar.dart`
  - `lib/presentation/widgets/molecules/mini_player/volume_control_bar/volume_control_bar.dart`

## 新增需求

### 需求：播客标题展示

系统应在 EpisodeInfo 组件中展示播客标题。

#### 场景：展示播客标题

- **当** EpisodeInfo 组件渲染时
- **则** 应展示当前播放节目的播客标题
- **并且** 如果播客标题为空或 null，则展示"未知播客"

### 需求：播放进度展示

系统应在 EpisodeProgress 组件中展示播放进度和时长。

#### 场景：展示播放进度

- **当** EpisodeProgress 组件渲染时
- **则** 应展示当前播放进度条
- **并且** 左侧展示已播放时长（格式：mm:ss 或 HH:mm:ss）
- **并且** 右侧展示总时长（格式：mm:ss 或 HH:mm:ss）
- **并且** 支持用户拖动进度条进行播放位置跳转

### 需求：播放/暂停按钮

系统应在 EpisodeControlBar 组件中正确显示播放/暂停按钮图标。

#### 场景：显示播放按钮

- **当** 当前处于未播放状态
- **则** 应显示 LucideIcons.play 图标

#### 场景：显示暂停按钮

- **当** 当前处于播放状态
- **则** 应显示 LucideIcons.pause 图标

### 需求：音量控制

系统应通过 just_audio SDK 控制音量。

#### 场景：调整音量

- **当** 用户通过 VolumeControlBar 调整音量
- **则** 应调用 just_audio SDK 的 setVolume 方法
- **并且** 音量值范围应为 0.0 到 1.0
- **并且** 应更新音量控制条的视觉反馈

#### 场景：显示当前音量

- **当** VolumeControlBar 组件渲染时
- **则** 应显示当前播放器的音量值
- **并且** 音量条应反映当前音量比例

### 需求：播放速度控制

系统应通过 just_audio SDK 控制播放速度并显示当前速度。

#### 场景：调整播放速度

- **当** 用户点击速度按钮并选择速度选项
- **则** 应调用 just_audio SDK 的 setSpeed 方法
- **并且** 支持的速度选项应包括：0.5x、0.75x、1x、1.25x、1.5x、2x
- **并且** 应保存用户偏好

#### 场景：显示当前播放速度

- **当** EpisodeControlBar 组件渲染时
- **则** 速度按钮应显示当前播放速度
- **并且** 如果当前速度为 1.0x，应显示为 "1x"
- **并且** 其他速度应显示为 "0.5x"、"0.75x"、"1.25x"、"1.5x"、"2x"

## 修改的需求

无

## 移除的需求

无
