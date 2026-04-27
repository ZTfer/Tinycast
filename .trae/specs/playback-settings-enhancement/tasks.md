# Tasks

- [ ] 任务 1：修改 SkipTimeDropdown 添加选中状态支持
  - [ ] 子任务 1.1：添加 `selectedTime` 参数到 SkipTimeDropdown
  - [ ] 子任务 1.2：根据 selectedTime 显示 check 图标

- [ ] 任务 2：修改 SkipTimeSettings 集成 SettingsProvider
  - [ ] 子任务 2.1：添加 ConsumerWidget 导入
  - [ ] 子任务 2.2：使用 ref.watch(settingsProvider) 读取设置
  - [ ] 子任务 2.3：更新按钮 label 显示当前设置值
  - [ ] 子任务 2.4：在选择时调用 settingsProvider.updateSkipForwardTime/updateSkipBackwardTime
  - [ ] 子任务 2.5：传递 selectedTime 到 SkipTimeDropdown

- [ ] 任务 3：修改 ContinuousPlaySettings 集成 SettingsProvider
  - [ ] 子任务 3.1：添加 ConsumerWidget 和 SettingsProvider 导入
  - [ ] 子任务 3.2：使用 ref.watch(settingsProvider) 读取设置
  - [ ] 子任务 3.3：在选择时调用 settingsProvider.updateContinuousPlay

- [ ] 任务 4：验证 AudioPlayerService 使用设置的跳过时间
  - [ ] 子任务 4.1：检查 _seekForward 和 _seekBackward 方法
  - [ ] 子任务 4.2：确认使用 settingsProvider 或 SettingsService 获取时间值

- [ ] 任务 5：验证连续播放逻辑实现
  - [ ] 子任务 5.1：检查 _playNextInQueue 方法
  - [ ] 子任务 5.2：确认根据 continuousPlay 设置决定是否自动播放

## 任务依赖关系

- [任务 2] 依赖于 [任务 1]
- [任务 4] 和 [任务 5] 可独立并行执行
