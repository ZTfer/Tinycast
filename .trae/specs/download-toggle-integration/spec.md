# 下载/移除下载联动功能 Spec

## Why

当前 `EpisodeDropdown` 的"移除下载"菜单项是静态展示的，没有实际的删除逻辑；同时未下载的 episode 缺少"下载"入口。需要实现完整的下载/移除下载交互闭环：下拉菜单根据 `isDownloaded` 状态动态切换选项，点击后执行对应操作，并联动更新 `DownloadStatusIcon`、`downloads` 页面及所有使用 `EpisodeItem` 的 UI。

## What Changes

- **EpisodeDropdown**: 新增 `isDownloaded` 参数和 `onToggleDownload` 回调，根据下载状态动态渲染"下载"(arrowDown) / "移除下载"(trash2) 菜单项
- **EpisodeControlBar**: 将 `isDownloaded` 传递给 `EpisodeDropdown`，新增 `_handleRemoveDownload` 和 `_handleDownload` 方法，分别调用 `AudioDownloadService.deleteDownloadedEpisode()` 和 `AudioDownloadService.downloadEpisode()`
- **EpisodeInfo**: 需要传入完整 `Episode` 对象（或 audioUrl）给 `EpisodeControlBar` 以支持下载操作
- **DownloadStatusIcon**: 支持三种状态——已下载（箭头图标）、下载中（圆环进度）、隐藏（未下载）
- **Downloads 页面**: 通过 `ref.invalidate(downloadedEpisodesNotifierProvider)` 自动刷新
- **所有 EpisodeItem 使用处**: 通过 Riverpod provider 自动响应 isDownloaded 变化

## Impact

- Affected specs: download-management
- Affected code:
  - `episode_dropdown.dart` — 动态菜单项
  - `episode_control_bar.dart` — 下载/删除逻辑 + DownloadStatusIcon 状态
  - `download_status_icon.dart` — 三态图标（已下载/下载中/隐藏）
  - `episode_info.dart` — 传递 Episode 数据
  - `episode_item.dart` — 无需改动（自动通过 provider 刷新）
  - `downloads.dart` — 无需改动（自动通过 provider 刷新）
  - `downloaded_episodes_provider.dart` — 可能需新增 refresh 暴露

## ADDED Requirements

### Requirement: 下拉菜单下载状态联动

系统 SHALL 根据 episode 的 `isDownloaded` 字段在下拉菜单中展示不同的下载选项。

#### Scenario: 已下载时展示移除下载选项

- **WHEN** episode 的 `isDownloaded` 为 true
- **THEN** 下拉菜单展示 icon=trash2、text="移除下载" 的菜单项
- **AND** 点击后调用删除逻辑，删除本地文件，将 `isDownloaded` 设为 false
- **AND** 关闭下拉菜单，显示成功 Toast
- **AND** Downloads 页面不再展示该条目
- **AND** 所有使用 EpisodeItem 的 UI 不再展示 DownloadStatusIcon

#### Scenario: 未下载时展示下载选项

- **WHEN** episode 的 `isDownloaded` 为 false
- **THEN** 下拉菜单展示 icon=arrowDown、text="下载" 的菜单项
- **AND** 点击后调用 `AudioDownloadService.downloadEpisode(episode)` 开始下载
- **AND** 关闭下拉菜单
- **AND** DownloadStatusIcon 变为圆环进度动画，实时反映下载进度

#### Scenario: 下载进行中

- **WHEN** episode 正在下载中
- **THEN** DownloadStatusIcon 展示为圆环形状的进度指示器
- **AND** 进度值从 `downloadNotifierProvider` 实时获取
- **AND** 圆环填充比例对应当前下载进度

#### Scenario: 下载完成

- **WHEN** 下载完成（DownloadStatus.completed）
- **THEN** `AudioDownloadService` 自动将数据库中 `isDownloaded` 更新为 true
- **AND** DownloadStatusIcon 从进度圆环切换为已下载箭头图标
- **AND** Downloads 页面自动出现该条目
- **AND** 所有使用 EpisodeItem 的 UI 展示 DownloadStatusIcon
- **AND** 下拉菜单选项从"下载"切换为"移除下载"

### Requirement: 移除下载完整流程

系统 SHALL 提供完整的移除下载能力。

#### Scenario: 用户点击移除下载

- **WHEN** 用户在已下载 episode 的下拉菜单中点击"移除下载"
- **THEN** 调用 `AudioDownloadService.deleteDownloadedEpisode(episodeId)`
- **AND** 该方法删除本地音频文件 + 更新数据库 `isDownloaded=false`
- **AND** 调用 `ref.invalidate(downloadedEpisodesNotifierProvider)` 刷新 Downloads 页面
- **AND** 显示 Toast 提示"已移除下载"
- **AND** 若失败则显示错误 Toast

## MODIFIED Requirements

### Requirement: DownloadStatusIcon 多态展示

`DownloadStatusIcon` SHALL 支持三种视觉状态：

| 状态 | 条件 | 视觉 |
|------|------|------|
| 已下载 | `isDownloaded == true` 且不在下载中 | 灰底圆角容器 + arrowDown 图标（当前样式） |
| 下载中 | `downloadNotifierProvider` 中该 episode 状态为 downloading | 圆环 CircularProgressIndicator |
| 隐藏 | `isDownloaded == false` 且不在下载中 | 不渲染（由父级 if 控制） |

### Requirement: EpisodeControlBar 下载参数扩展

`EpisodeControlBar` 除已有的 `isDownloaded: bool` 外，还需接收：

- `episode`: 完整 `Episode` 对象（用于下载时获取 `audioUrl` 等信息）或至少 `audioUrl: String`

### Requirement: EpisodeInfo 数据透传

`EpisodeInfo` → `EpisodeControlBar` 的调用链中，需将 `Episode` 对象或其必要字段（`audioUrl`, `isDownloaded` 等）向下传递。

## REMOVED Requirements

### Requirement: 静态移除下载菜单项

**Reason**: 原"移除下载"菜单项为静态展示，无实际功能，现改为动态联动的下载/移除下载双向操作。
**Migration**: 替换为基于 `isDownloaded` 状态的条件渲染菜单项。
