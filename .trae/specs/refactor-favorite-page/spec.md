# 重构 Favorite 页面展示已收藏 Episode Spec

## Why
当前的 Favorite 页面使用硬编码的示例数据和自定义组件（favorite_control_bar、favorite_episode_dropdown 等），需要重构为动态加载真实收藏数据，并复用通用的 EpisodeItem 组件，与 Queue 页面保持一致的设计模式。

## What Changes
- 修改 `favorite.dart` 从 StatelessWidget 改为 ConsumerWidget，监听收藏数据
- 创建 `favorite_episodes_provider.dart` 提供收藏 episodes 数据源
- 创建 `GetFavoriteEpisodesUseCase` 获取所有已收藏的 episode 完整对象
- 创建 `favorite_empty_page` 目录及相关组件（空状态页面）
- 移除对自定义组件（favorite_control_bar、favorite_episode_dropdown、favorite_episode_info、favorite_list_item）的依赖
- 使用通用 `EpisodeItem` 组件展示收藏列表

## Impact
- Affected specs: 无直接影响其他 spec
- Affected code:
  - `/lib/presentation/features/favorite/favorite.dart` (重构)
  - `/lib/presentation/providers/favorite_provider.dart` (扩展)
  - 新增: `/lib/presentation/features/favorite/favorite_episodes_provider.dart`
  - 新增: `/lib/domain/usecases/get_favorite_episodes_usecase.dart`
  - 新增: `/lib/presentation/features/favorite/favorite_empty_page/` (目录及组件)

## ADDED Requirements

### Requirement: 收藏 Episodes 数据 Provider
系统 SHALL 提供 `favoriteEpisodesProvider` 返回所有已收藏的 Episode 对象列表。

#### Scenario: 成功获取收藏列表
- **WHEN** 用户进入 Favorite 页面
- **THEN** 系统自动加载所有标记为 isFavorite=true 的 Episode 并按发布时间倒序显示

#### Scenario: 加载中状态
- **WHEN** 正在加载收藏数据
- **THEN** 显示 CircularProgressIndicator 加载指示器

#### Scenario: 空收藏状态
- **WHEN** 没有任何收藏内容时
- **THEN** 显示 FavoriteEmptyPage 空状态页面

### Requirement: Favorite 页面 UI
Favorite 页面 SHALL 使用通用 EpisodeItem 组件展示每个收藏项，支持：
- 显示 episode 封面图、标题、描述、时长
- 点击播放按钮播放该 episode
- 点击 episode 打开详情页
- 最后一个 item 不显示分隔线

### Requirement: FavoriteEmptyPage 空状态组件
空状态页面 SHALL 包含：
- 占位图标/插图区域
- 提示文字："No favorites yet" / "Add episodes to your favorites to find them here"
- 可选的操作按钮区域（预留）

## MODIFIED Requirements

### Requirement: Favorite Provider 扩展
在现有 `favorite_provider.dart` 基础上，新增通过 episode IDs 获取完整 Episode 对象的能力。

## REMOVED Requirements

### Requirement: 自定义 Favorite 组件
**Reason**: 用户明确要求不使用 custom components（favorite_control_bar、favorite_episode_dropdown、favorite_episode_info、favorite_list_item），改用通用 EpisodeItem 组件以保持一致性。
**Migration**: 删除对这些组件的 import，替换为 EpisodeItem 组件调用。
