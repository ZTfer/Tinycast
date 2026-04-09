# Episode 收藏功能（Favorite Collection）Spec

## Why
当前 EpisodeDropdown 中的收藏按钮是静态的，无法反映或切换真实的收藏状态。需要创建独立的 Favorite Isar Collection 来管理收藏关系，并让 EpisodeDropdown 根据收藏状态动态展示不同的文本、图标和行为。

## What Changes
- 创建 Favorite Isar 模型（`favorite_model.dart`），包含 episodeId、addedAt 字段
- 在 IsarService 中注册 FavoriteSchema
- 重构 `EpisodeDropdown`：接收 `isFavorite` 状态参数，动态展示收藏/取消收藏
- 添加 `onToggleFavorite` 回调

## Impact
- Affected specs: favorite-management（已有但未实现，本 spec 聚焦于数据模型 + EpisodeDropdown）
- Affected code:
  - 新建 `lib/data/models/favorite_model.dart` — Favorite Isar 模型
  - 新建 `lib/data/models/favorite_model.g.dart` — Isar 生成代码
  - 修改 `lib/data/database/isar_service.dart` — 注册 FavoriteSchema
  - 修改 `lib/presentation/widgets/organisms/episode_dropdown/episode_dropdown.dart` — 动态收藏状态 UI

## ADDED Requirements

### Requirement: Favorite 数据模型
系统 SHALL 提供独立的 Favorite Isar Collection，用于存储 episode 收藏关系。

#### Scenario: Favorite 模型结构
- **WHEN** 定义 Favorite 模型
- **THEN** 模型包含以下字段：
  - `Id id` — Isar 自增主键
  - `late int episodeId` — 关联的 Episode ID（**带索引**）
  - `final DateTime createdAt` — 收藏时间，默认 `DateTime.now()`

### Requirement: EpisodeDropdown 动态收藏项
EpisodeDropdown 组件 SHALL 接收收藏状态参数，并根据状态渲染对应的菜单项。

#### Scenario: 未收藏状态展示
- **WHEN** `isFavorite` 为 false 或 null
- **THEN** 展示文本"收藏"，图标为 `LucideIcons.star`
- **AND** 点击后调用 `onToggleFavorite` 回调通知父组件执行收藏

#### Scenario: 已收藏状态展示
- **WHEN** `isFavorite` 为 true
- **THEN** 展示文本"取消收藏"，图标为 `LucideIcons.starOff`
- **AND** 点击后调用 `onToggleFavorite` 回调通知父组件取消收藏
