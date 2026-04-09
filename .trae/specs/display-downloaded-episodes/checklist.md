# 检查清单

- [ ] `podcast_repository.dart` 中新增 `getDownloadedEpisodes()` 方法签名
- [ ] `podcast_repository_impl.dart` 中实现 `getDownloadedEpisodes()` 方法（筛选 isDownloaded == true，按 pubDate 降序）
- [ ] `get_downloaded_episodes_usecase.dart` 已创建并正确调用 repository 方法
- [ ] `downloaded_episodes_provider.dart` 已创建（包含 State、Notifier、downloadedEpisodesProvider、downloadedEpisodesLoadingProvider）
- [ ] `downloads.dart` 已重构为 ConsumerWidget
- [ ] `downloads.dart` 不再依赖 `downloads_list_item` 组件，改用 `EpisodeItem`
- [ ] `downloads.dart` 正确显示加载状态（CircularProgressIndicator）
- [ ] `downloads.dart` 正确显示空状态
- [ ] `downloads.dart` 使用 ListView.builder 展示已下载 episode 列表
- [ ] 播放按钮点击回调正常工作（调用 playEpisode）
- [ ] Episode 点击回调正常工作（跳转到详情页）
- [ ] 最后一项不显示分隔线（showDivider: false）
