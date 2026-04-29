# 持久化播放速度与音量 Spec

## Why

当前播放速度和音量设置在应用重启后丢失，用户每次重新打开应用都需要重新调整。需要将这些偏好持久化到 `shared_preferences` 中，确保用户体验连续性。

## What Changes

- 在 `AppSettings` 中添加 `volume` 字段
- 在 `SettingsService` 中添加音量的持久化存储方法
- 在 `SettingsProvider` 中添加音量的更新方法
- 修改 `EpisodeControlBar` 中的速度选择逻辑，选择后保存到 SettingsProvider
- 修改 `VolumeControlPopup` 中的音量调整逻辑，调整后保存到 SettingsProvider
- 在 `PlaybackNotifier` 初始化时恢复上次保存的速度和音量

## Impact

- 受影响的规格：mini-player-enhancement, settings-storage-rules
- 受影响的代码：
  - `lib/domain/entities/app_settings.dart`
  - `lib/data/services/settings_service.dart`
  - `lib/presentation/providers/settings_provider.dart`
  - `lib/presentation/widgets/organisms/mini_player/episode_control_bar/episode_control_bar.dart`
  - `lib/presentation/widgets/organisms/mini_player/volume_control_bar/volume_control_popup.dart`
  - `lib/presentation/providers/playback_provider.dart`

## ADDED Requirements

### 需求：音量持久化存储

系统应持久化保存用户设置的音量值。

#### 场景：保存音量设置
- **当**用户调整音量
- **则**系统应调用 `SettingsService.setVolume()` 保存音量值到 `shared_preferences`
- **并且**音量值范围为 0.0 到 1.0

#### 场景：加载音量设置
- **当**应用启动
- **则**系统应从 `shared_preferences` 加载上次保存的音量值
- **并且**如果未设置，使用默认值 0.3

### 需求：速度持久化存储

系统应持久化保存用户设置的播放速度。

#### 场景：保存速度设置
- **当**用户选择新的播放速度
- **则**系统应调用 `SettingsProvider.updatePlaybackSpeed()` 保存速度值
- **并且**速度值应持久化到 `shared_preferences`

#### 场景：加载速度设置
- **当**应用启动
- **则**系统应从 `SettingsService.loadSettings()` 加载上次保存的速度值
- **并且**`PlaybackNotifier` 应使用加载的速度值初始化播放器

## MODIFIED Requirements

### 需求：现有速度设置
`AppSettings`、`SettingsService`、`SettingsProvider` 已包含 `playbackSpeed` 的持久化逻辑，但尚未在 UI 层调用。

## REMOVED Requirements

无