# 任务列表

- [ ] 任务 1：在 Repository 层新增获取已下载 Episode 的方法
  - [ ] 在 `lib/domain/repositories/podcast_repository.dart` 中添加 `getDownloadedEpisodes()` 抽象方法
  - [ ] 在 `lib/data/repositories/podcast_repository_impl.dart` 中实现 `getDownloadedEpisodes()` 方法（查询 isDownloaded == true 的 episode，按 pubDate 降序排序）

- [ ] 任务 2：创建 GetDownloadedEpisodesUseCase
  - [ ] 在 `lib/domain/usecases/` 下创建 `get_downloaded_episodes_usecase.dart`
  - [ ] 参考 `get_unplayed_episodes_usecase.dart` 的模式实现

- [ ] 任务 3：创建 downloaded episodes Riverpod Provider
  - [ ] 在 `lib/presentation/features/downloads/` 下创建 `downloaded_episodes_provider.dart`
  - [ ] 参考 `unplayed_episodes_provider.dart` 的模式，包含 State、Notifier、Provider（downloadedEpisodesProvider、downloadedEpisodesLoadingProvider）

- [ ] 任务 4：重构 Downloads 页面
  - [ ] 将 `downloads.dart` 从 `StatelessWidget` 改为 `ConsumerWidget`
  - [ ] 移除对 `downloads_list_item` 的依赖，改用 `EpisodeItem` 组件
  - [ ] 引入 `downloaded_episodes_provider`、`playback_provider`、`podcast_provider`、`navigation_provider`
  - [ ] 实现加载状态显示（CircularProgressIndicator）
  - [ ] 实现空状态显示
  - [ ] 使用 `ListView.builder` + `EpisodeItem` 展示已下载 episode 列表
  - **实现 onPlayPressed 回调**：调用 `playbackProvider.notifier.playEpisode(episode)`
  - **实现 onEpisodeTap 回调**：获取 podcast 并调用 `navigationProvider.notifier.showEpisodeDetail(episode, podcast)`
  - **最后一项 showDivider 设为 false**

## 任务依赖关系

- [任务 2] 依赖于 [任务 1]
- [任务 3] 依赖于 [任务 2]
- [任务 4] 依赖于 [任务 3]
