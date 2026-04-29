# Tasks

- [x] Task 1: 在 AppSettings 中添加睡眠定时器字段
  - [x] SubTask 1.1: 定义 SleepTimerOption 枚举（off, min5, min10, min15, min30, min45, min60, episodeEnd）
  - [x] SubTask 1.2: 在 AppSettings 中添加 `sleepTimer` 字段，默认值 off
  - [x] SubTask 1.3: 在 AppSettings 中添加 `sleepTimerEndTimeMillis` 字段（记录设定的到期时间戳）
  - [x] SubTask 1.4: 更新 copyWith 方法
  - [x] SubTask 1.5: 更新 toJson/fromJson 方法

- [x] Task 2: 在 SettingsService 中添加睡眠定时器存储方法
  - [x] SubTask 2.1: 添加 `setSleepTimer(SleepTimerOption)` 方法
  - [x] SubTask 2.2: 添加 `setSleepTimerEndTimeMillis(int?)` 方法
  - [x] SubTask 2.3: 添加 `getSleepTimerEndTimeMillis()` 方法
  - [x] SubTask 2.4: 在 loadSettings 中加载 sleepTimer 值

- [x] Task 3: 在 SettingsProvider 中添加睡眠定时器更新方法
  - [x] SubTask 3.1: 添加 `updateSleepTimer(SleepTimerOption, {int? endTimeMillis})` 方法
  - [x] SubTask 3.2: 添加 `clearSleepTimer()` 方法

- [x] Task 4: 改造 SleepDropdown 连接状态管理
  - [x] SubTask 4.1: 将 SleepDropdown 改为 ConsumerWidget
  - [x] SubTask 4.2: 每个选项点击后调用 SettingsProvider.updateSleepTimer 或 clearSleepTimer
  - [x] SubTask 4.3: 选择非"关闭"选项时设置 sleepTimerEndTimeMillis
  - [x] SubTask 4.4: 选择"关闭"时清除 sleepTimerEndTimeMillis

- [x] Task 5: 在 PlaybackNotifier 中实现睡眠定时器逻辑
  - [x] SubTask 5.1: 在 build 方法中添加 _initSleepTimerCheck
  - [x] SubTask 5.2: 实现 _checkSleepTimer 定时器倒计时，到期后暂停播放并清除设置
  - [x] SubTask 5.3: 实现重新选择时重置计时器逻辑（由 SettingsProvider 更新 endTimeMillis 触发）

- [x] Task 6: 实现单集结束时睡眠定时器优先级
  - [x] SubTask 6.1: 在 `_onEpisodeCompleted` 中检查睡眠定时器
  - [x] SubTask 6.2: 如果睡眠定时器为 episodeEnd，暂停播放并清除设置（不执行连续播放）

# Task Dependencies

- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 2]
- [Task 4] depends on [Task 3]
- [Task 5] depends on [Task 3]
- [Task 6] depends on [Task 5]