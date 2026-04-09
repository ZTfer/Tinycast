# 检查清单

- [x] `podcast_repository.dart` 中新增 `getDownloadedEpisodes()` 方法签名
- [x] `podcast_repository_impl.dart` 中实现 `getDownloadedEpisodes()` 方法（筛选 isDownloaded == true，按 pubDate 降序）
- [x] `get_downloaded_episodes_usecase.dart` 已创建并正确调用 repository 方法
- [x] `downloaded_episodes_provider.dart` 已创建（包含 State、Notifier、downloadedEpisodesProvider、downloadedEpisodesLoadingProvider）
- [x] `downloads.dart` 已重构为 ConsumerWidget
- [x] `downloads.dart` 不再依赖 `downloads_list_item` 组件，改用 `EpisodeItem`
- [x] `downloads.dart` 正确显示加载状态（CircularProgressIndicator）
- [x] `downloads.dart` 正确显示空状态
- [x] `downloads.dart` 使用 ListView.builder 展示已下载 episode 列表
- [x] 播放按钮点击回调正常工作（调用 playEpisode）
- [x] Episode 点击回调正常工作（跳转到详情页）
- [x] 最后一项不显示分隔线（showDivider: false）
