# Tasks

- [ ] Task 1: 创建 GetFavoriteEpisodesUseCase
  - [ ] 在 `/lib/domain/usecases/get_favorite_episodes_usecase.dart` 创建 use case
  - [ ] 实现 call() 方法：从 PodcastRepository 获取所有 episodes，过滤 isFavorite=true 的项
  - [ ] 按发布时间倒序排序返回结果

- [ ] Task 2: 创建 Favorite Episodes Provider
  - [ ] 在 `/lib/presentation/features/favorite/favorite_episodes_provider.dart` 创建 provider
  - [ ] 参考 unplayed_episodes_provider.dart 的模式实现
  - [ ] 包含状态管理（loading/success/error）
  - [ ] 导出 favoriteEpisodesProvider 和 favoriteEpisodesLoadingProvider

- [ ] Task 3: 创建 FavoriteEmptyPage 空状态页面
  - [ ] 创建目录结构: `/lib/presentation/features/favorite/favorite_empty_page/`
  - [ ] 实现 favorite_empty_info.dart（占位图 + 提示文字）
  - [ ] 实现 favorite_empty_page.dart（组合空状态组件）

- [ ] Task 4: 重构 Favorite 主页面
  - [ ] 修改 favorite.dart 从 StatelessWidget 改为 ConsumerWidget
  - [ ] 监听 favoriteEpisodesProvider 和 favoriteEpisodesLoadingProvider
  - [ ] 实现三态逻辑：loading → CircularProgressIndicator, empty → FavoriteEmptyPage, data → ListView.builder + EpisodeItem
  - [ ] 配置 EpisodeItem 回调（onPlayPressed, onEpisodeTap）
  - [ ] 移除所有旧的自定义组件依赖

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 4] depends on [Task 2] and [Task 3]
