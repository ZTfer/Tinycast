# 播放设置完善 Spec

## 为什么

当前播放设置存在以下问题：
1. **跳过时间设置未与 SettingsProvider 集成**：`SkipTimeSettings` 显示硬编码的 "30 秒" 和 "15 秒"，不反映实际设置值，选择后也不保存
2. **连续播放设置未持久化**：`ContinuousPlaySettings` 只有本地状态，重启后丢失
3. **SkipTimeDropdown 选中状态不正确**：始终选中 15 秒，不反映当前设置
4. **音频播放器未使用设置的跳过时间**：需要确保快进/快退使用用户配置的值

## 变更内容

- 修改 `SkipTimeDropdown` 添加 `selectedTime` 参数
- 修改 `SkipTimeSettings` 集成 `SettingsProvider`
- 修改 `ContinuousPlaySettings` 集成 `SettingsProvider`
- 验证 `AudioPlayerService` 使用设置的跳过时间
- 完善连续播放逻辑实现

## 影响

- 受影响的规格：settings-management
- 受影响的代码：
  - `lib/presentation/features/settings/play_settings/skip_time_settings/skip_time_dropdown.dart`
  - `lib/presentation/features/settings/play_settings/skip_time_settings/skip_time_settings.dart`
  - `lib/presentation/features/settings/play_settings/continuous_play_settings.dart`
  - `lib/data/services/audio_player_service.dart`

## ADDED Requirements

### 需求：跳过时间下拉菜单选中状态
系统应在下拉菜单中正确显示当前选中的时间选项。

#### 场景：显示正确选中状态
- **当**打开快进/快退时间下拉菜单
- **则**当前设置的时间选项应显示 check 图标
- **并且**其他选项不显示 check 图标

### 需求：跳过时间设置与 SettingsProvider 集成
系统应从 SettingsProvider 读取并保存跳过时间设置。

#### 场景：显示当前跳过时间设置
- **当**用户打开播放设置页面
- **则**快进按钮应显示当前配置的快进时间（如 "30 秒"）
- **并且**快退按钮应显示当前配置的快退时间（如 "15 秒"）

#### 场景：更新快进时间
- **当**用户从快进下拉菜单选择新时间
- **则**系统应调用 `settingsProvider.updateSkipForwardTime()` 保存设置
- **并且**按钮显示更新为新时间
- **并且**AudioPlayerService 的快进操作使用新时间

#### 场景：更新快退时间
- **当**用户从快退下拉菜单选择新时间
- **则**系统应调用 `settingsProvider.updateSkipBackwardTime()` 保存设置
- **并且**按钮显示更新为新时间
- **并且**AudioPlayerService 的快退操作使用新时间

### 需求：连续播放设置与 SettingsProvider 集成
系统应从 SettingsProvider 读取并保存连续播放设置。

#### 场景：显示当前连续播放设置
- **当**用户打开播放设置页面
- **则**单选按钮应反映当前配置的连续播放选项

#### 场景：更新连续播放设置
- **当**用户选择"单集结束后继续播放"或"单集结束后停止"
- **则**系统应调用 `settingsProvider.updateContinuousPlay()` 保存设置

### 需求：连续播放逻辑实现
系统应在播放完一集后根据设置决定行为。

#### 场景：连续播放启用 - 有下一集
- **当**当前 episode 播放完成
- **并且**连续播放设置为"继续播放"
- **并且**有待播放的下一集
- **则**自动播放下一集

#### 场景：连续播放启用 - 无下一集
- **当**当前 episode 播放完成
- **并且**连续播放设置为"继续播放"
- **并且**没有待播放的下一集
- **则**停留在当前 episode，不播放

#### 场景：连续播放禁用
- **当**当前 episode 播放完成
- **并且**连续播放设置为"停止"
- **则**切换到下一个 episode（如果有）并暂停播放
- **并且**如果没有下一个 episode，则停留在当前 episode

## MODIFIED Requirements

### 需求：现有跳过时间选项
系统支持的跳过时间选项已从固定的 15/30 秒扩展为 10/15/30/45/60 秒。

默认值：
- 快进：30 秒
- 快退：15 秒

## REMOVED Requirements

无
