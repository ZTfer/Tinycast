# Tasks

- [ ] Task 1: 在 AppSettings 中添加睡眠定时器字段
  - [ ] SubTask 1.1: 定义 SleepTimerOption 枚举（off, min5, min10, min15, min30, min45, min60, episodeEnd）
  - [ ] SubTask 1.2: 在 AppSettings 中添加 `sleepTimer` 字段，默认值 off
  - [ ] SubTask 1.3: 在 AppSettings 中添加 `sleepTimerEndTime` 字段（记录设定的到期时间戳）
  - [ ] SubTask 1.4: 更新 copyWith 方法
  - [ ] SubTask 1.5: 更新 toJson/fromJson 方法

- [ ] Task 2: 在 SettingsService 中添加睡眠定时器存储方法
  - [ ] SubTask 2.1: 添加 `setSleepTimer(SleepTimerOption)` 方法
  - [ ] SubTask 2.2: 添加 `setSleepTimerEndTime(DateTime?)` 方法
  - [ ] SubTask 2.3: 在 loadSettings 中加载 sleepTimer 值

- [ ] Task 3: 在 SettingsProvider 中添加睡眠定时器更新方法
  - [ ] SubTask 3.1: 添加 `updateSleepTimer(SleepTimerOption)` 方法
  - [ ] SubTask 3.2: 添加 `clearSleepTimer()` 方法

- [ ] Task 4: 改造 SleepDropdown 连接状态管理
  - [ ] SubTask 4.1: 将 SleepDropdown 改为 ConsumerWidget
  - [ ] SubTask 4.2: 每个选项点击后调用 SettingsProvider.updateSleepTimer
  - [ ] SubTask 4.3: 选择非"关闭"选项时设置 sleepTimerEndTime
  - [ ] SubTask 4.4: 选择"关闭"时清除 sleepTimerEndTime

- [ ] Task 5: 在 PlaybackNotifier 中实现睡眠定时器逻辑
  - [ ] SubTask 5.1: 在 build 方法中检查并启动睡眠定时器
  - [ ] SubTask 5.2: 实现定时器倒计时，到期后暂停播放并清除设置
  - [ ] SubTask 5.3: 实现重新选择时重置计时器逻辑

- [ ] Task 6: 实现单集结束时睡眠定时器优先级
  - [ ] SubTask 6.1: 在 `_onEpisodeCompleted` 中检查睡眠定时器
  - [ ] SubTask 6.2: 如果睡眠定时器为 episodeEnd，暂停播放并清除设置（不执行连续播放）

# Task Dependencies

- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 2]
- [Task 4] depends on [Task 3]
- [Task 5] depends on [Task 3]
- [Task 6] depends on [Task 5]