# Tasks

- [ ] Task 1: 在 AppSettings 中添加 volume 字段
  - [ ] SubTask 1.1: 在 AppSettings 类中添加 `volume` 字段，默认值 0.3
  - [ ] SubTask 1.2: 更新 copyWith 方法
  - [ ] SubTask 1.3: 更新 toJson/fromJson 方法

- [ ] Task 2: 在 SettingsService 中添加音量存储方法
  - [ ] SubTask 2.1: 添加 `setVolume(double)` 方法
  - [ ] SubTask 2.2: 添加 `getVolume()` 方法
  - [ ] SubTask 2.3: 在 loadSettings 中加载 volume 值

- [ ] Task 3: 在 SettingsProvider 中添加音量更新方法
  - [ ] SubTask 3.1: 添加 `updateVolume(double)` 方法

- [ ] Task 4: 在 EpisodeControlBar 中保存速度选择
  - [ ] SubTask 4.1: 修改 SpeedDropdown 的 onSpeedChanged 回调，调用 SettingsProvider.updatePlaybackSpeed

- [ ] Task 5: 在 VolumeControlPopup 中保存音量调整
  - [ ] SubTask 5.1: 修改 VolumeControlBar 的 onVolumeChanged 回调，调用 SettingsProvider.updateVolume

- [ ] Task 6: 在 PlaybackNotifier 初始化时恢复速度和音量
  - [ ] SubTask 6.1: 在 build 方法中加载 SettingsService 的速度和音量
  - [ ] SubTask 6.2: 使用加载的值初始化 AudioPlayerService

# Task Dependencies

- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 2]
- [Task 4] depends on [Task 3]
- [Task 5] depends on [Task 3]
- [Task 6] depends on [Task 1, Task 2]