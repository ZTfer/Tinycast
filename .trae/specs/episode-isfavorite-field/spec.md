# Episode 收藏字段（isFavorite）Spec

## Why
当前 EpisodeDropdown 中的收藏按钮是静态的，始终显示"收藏"文本和 star 图标，无法根据 episode 的实际收藏状态切换显示。需要在 Episode 数据模型中添加 `isFavorite` 字段，使 UI 能根据收藏状态动态展示不同的文本、图标和行为。

## What Changes
- 在 Isar Episode 模型（`episode_model.dart`）中添加 `late bool isFavorite` 字段
- 在 Domain 层 Episode 实体（`episode.dart`）中添加 `final bool isFavorite` 字段
- 重新生成 Isar 代码（`episode_model.g.dart`）
- 重构 `EpisodeDropdown` 组件：接收 episode 参数，根据 `isFavorite` 状态动态展示收藏/取消收藏
- 添加 `onToggleFavorite` 回调，点击时切换收藏状态

## Impact
- Affected specs: 无
- Affected code:
  - `lib/data/models/episode_model.dart` — 添加 isFavorite 字段
  - `lib/data/models/episode_model.g.dart` — 重新生成
  - `lib/domain/entities/episode.dart` — 添加 isFavorite 字段
  - `lib/presentation/widgets/organisms/episode_dropdown/episode_dropdown.dart` — 动态收藏状态 UI
  - 所有使用 Episode 实体或模型的构造函数调用处（需要传入 isFavorite 默认值）

## ADDED Requirements

### Requirement: Episode isFavorite 字段
系统 SHALL 在 Episode 数据模型和实体中提供 `isFavorite` 布尔字段，用于标识该 episode 是否已被用户收藏。

#### Scenario: 未收藏状态展示
- **WHEN** episode 的 `isFavorite` 为 false
- **THEN** EpisodeDropdown 展示文本"收藏"，图标为 `LucideIcons.star`
- **AND** 点击后触发 `onToggleFavorite` 回调将 episode 标记为收藏

#### Scenario: 已收藏状态展示
- **WHEN** episode 的 `isFavorite` 为 true
- **THEN** EpisodeDropdown 展示文本"取消收藏"，图标为 `LucideIcons.starOff`
- **AND** 点击后触发 `onToggleFavorite` 回调取消收藏

### Requirement: EpisodeDropdown 动态收藏项
EpisodeDropdown 组件 SHALL 接收当前 episode 对象，并根据其 `isFavorite` 状态渲染对应的收藏菜单项。

#### Scenario: 收藏状态切换
- **WHEN** 用户点击收藏/取消收藏菜单项
- **THEN** 调用 `onToggleFavorite` 回调通知父组件执行收藏状态切换
