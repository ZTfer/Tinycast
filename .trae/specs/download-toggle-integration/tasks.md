# Tasks

- [ ] Task 1: 改造 EpisodeDropdown — 新增 isDownloaded 参数和 onToggleDownload 回调，动态渲染下载/移除下载菜单项
  - [ ] 在 EpisodeDropdown 中新增 `isDownloaded: bool` 参数（默认 false）
  - [ ] 新增 `onToggleDownload: VoidCallback?` 回调
  - [ ] 将原静态"移除下载"菜单项（L133-137）改为条件渲染：isDownloaded=true 时展示"移除下载"(trash2)，isDownloaded=false 时展示"下载"(arrowDown)
  - [ ] 点击时调用 `onToggleDownload` 并触发 `_handleItemSelected()`

- [ ] Task 2: 改造 DownloadStatusIcon — 支持已下载/下载中两种视觉状态
  - [ ] 新增 `progress` 可选参数（double?，0.0~1.0）
  - [ ] 当 progress 为 null 时：保持当前灰底+arrowDown 图标样式（已下载状态）
  - [ ] 当 progress 非空时：展示圆环 CircularProgressIndicator，strokeWidth=1.5，size=12，value=progress

- [ ] Task 3: 扩展 EpisodeControlBar — 新增 episode 参数和下载/移除逻辑
  - [ ] 新增 `episode: Episode` 必填参数
  - [ ] 将 isDownloaded 和 episode 传递给 EpisodeDropdown
  - [ ] 新增 `onToggleDownload` 回调传递给 EpisodeDropdown
  - [ ] 实现 `_handleDownload()` 方法：调用 AudioDownloadService.instance.downloadEpisode(episode)
  - [ ] 实现 `_handleRemoveDownload()` 方法：调用 AudioDownloadService.instance.deleteDownloadedEpisode(episodeId.toString())，成功后 invalidate downloadedEpisodesNotifierProvider
  - [ ] 修改 DownloadStatusIcon 渲染逻辑：从 downloadNotifierProvider 监听该 episode 的下载状态和进度，下载中时传 progress 给 DownloadStatusIcon
  - [ ] 未下载且不在下载中时：不展示 DownloadStatusIcon（保持现有 if (widget.isDownloaded) 逻辑的扩展）

- [ ] Task 4: 改造 EpisodeInfo — 将 Episode 对象透传给 EpisodeControlBar
  - [ ] 调用 EpisodeControlBar 时新增 `episode: widget.episode` 参数

- [ ] Task 5: 确保 Downloads 页面自动刷新
  - [ ] 确认 downloadedEpisodesNotifierProvider 已有 refresh 方法或可通过 invalidate 触发刷新
  - [ ] 验证删除/完成后 downloads.dart 页面通过 Riverpod 自动更新 UI
