# 睡眠定时器 Spec

## Why

用户需要在特定时间后自动暂停播放，支持按固定时间（5/10/15/30/45/60 分钟）或单集结束后暂停。设置需持久化存储，执行完成后自动恢复默认，且优先级高于连续播放设置。

## 变更内容

- 在 `AppSettings` 中添加 `sleepTimer` 和 `sleepTimerEndTime` 字段
- 在 `SettingsService` 中添加睡眠定时器的持久化存储方法
- 在 `SettingsProvider` 中添加睡眠定时器的更新方法
- 改造 `SleepDropdown` 连接状态管理，选择后保存设置并关闭菜单
- 在 `PlaybackNotifier` 中实现睡眠定时器计时逻辑
- 实现单集结束时暂停逻辑（优先级高于连续播放）
- 实现重新选择时重置计时器逻辑

## 影响

- 受影响的规格：settings-storage-rules, playback-settings-enhancement
- 受影响的代码：
  - `lib/domain/entities/app_settings.dart`
  - `lib/data/services/settings_service.dart`
  - `lib/presentation/providers/settings_provider.dart`
  - `lib/presentation/widgets/organisms/home_toolbar/sleep_dropdown.dart`
  - `lib/presentation/providers/playback_provider.dart`
  - `lib/presentation/features/settings/play_settings/continuous_play_settings.dart`

## ADDED Requirements

### 需求：睡眠定时器持久化存储

系统应持久化保存用户设置的睡眠定时器选项。

#### 场景：保存睡眠定时器设置
- **当**用户从睡眠下拉菜单选择选项
- **则**系统应调用 `SettingsService.setSleepTimer()` 保存设置到 `shared_preferences`
- **并且**设置值包括：关闭、5分钟、10分钟、15分钟、30分钟、45分钟、60分钟、单集结束时

#### 场景：加载睡眠定时器设置
- **当**应用启动
- **则**系统应从 `shared_preferences` 加载上次保存的睡眠定时器设置
- **并且**如果未设置，使用默认值"关闭"

### 需求：定时执行后恢复默认

系统应在定时任务执行完成后自动恢复睡眠定时器为默认值。

#### 场景：时间定时执行后恢复
- **当**睡眠定时器倒计时结束
- **则**系统应暂停播放
- **并且**将睡眠定时器设置恢复为"关闭"

#### 场景：单集结束定时执行后恢复
- **当**当前单集播放完成且睡眠定时器为"单集结束时"
- **则**系统应暂停播放
- **并且**将睡眠定时器设置恢复为"关闭"

### 需求：重新选择时重置计时器

系统应在用户重新选择睡眠定时器选项时重置计时器。

#### 场景：重新选择时间选项
- **当**用户在睡眠定时器倒计时期间选择新的时间选项
- **则**系统应取消当前倒计时
- **并且**以新选择的时间重新开始倒计时

#### 场景：选择"关闭"选项
- **当**用户选择"关闭"
- **则**系统应取消当前任何进行中的倒计时

### 需求：睡眠定时器优先级高于连续播放

系统应确保睡眠定时器的行为优先级高于连续播放设置。

#### 场景：单集结束时与连续播放冲突
- **当**当前单集播放完成
- **并且**睡眠定时器设置为"单集结束时"
- **并且**连续播放设置为"继续播放"
- **则**暂停播放（睡眠定时器优先）
- **并且**不自动播放下一集

#### 场景：时间定时与连续播放冲突
- **当**睡眠定时器倒计时结束
- **并且**连续播放设置为"继续播放"
- **则**暂停播放（睡眠定时器优先）
- **并且**不自动播放下一集

## MODIFIED Requirements

### 需求：现有睡眠下拉菜单
`SleepDropdown` 组件当前未连接状态管理，所有选项点击后仅调用 `onItemSelected` 关闭菜单，不保存设置。

## REMOVED Requirements

无