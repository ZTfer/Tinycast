# Tasks

- [x] Task 1: 创建 GetFavoriteEpisodesUseCase
  - [x] 在 `/lib/domain/usecases/get_favorite_episodes_usecase.dart` 创建 use case
  - [x] 实现 call() 方法：从 PodcastRepository 获取所有 episodes，过滤 isFavorite=true 的项
  - [x] 按发布时间倒序排序返回结果

- [x] Task 2: 创建 Favorite Episodes Provider
  - [x] 在 `/lib/presentation/features/favorite/favorite_episodes_provider.dart` 创建 provider
  - [x] 参考 unplayed_episodes_provider.dart 的模式实现
  - [x] 包含状态管理（loading/success/error）
  - [x] 导出 favoriteEpisodesProvider 和 favoriteEpisodesLoadingProvider

- [x] Task 3: 创建 FavoriteEmptyPage 空状态页面
  - [x] 创建目录结构: `/lib/presentation/features/favorite/favorite_empty_page/`
  - [x] 实现 favorite_empty_info.dart（占位图 + 提示文字）
  - [x] 实现 favorite_empty_page.dart（组合空状态组件）

- [x] Task 4: 重构 Favorite 主页面
  - [x] 修改 favorite.dart 从 StatelessWidget 改为 ConsumerWidget
  - [x] 监听 favoriteEpisodesProvider 和 favoriteEpisodesLoadingProvider
  - [x] 实现三态逻辑：loading → CircularProgressIndicator, empty → FavoriteEmptyPage, data → ListView.builder + EpisodeItem
  - [x] 配置 EpisodeItem 回调（onPlayPressed, onEpisodeTap）
  - [x] 移除所有旧的自定义组件依赖

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 4] depends on [Task 2] and [Task 3]
