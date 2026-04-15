# Tasks

- [x] Task 1: 改造 EpisodeDropdown — 新增 isDownloaded 参数和 onToggleDownload 回调，动态渲染下载/移除下载菜单项
  - [x] 在 EpisodeDropdown 中新增 `isDownloaded: bool` 参数（默认 false）
  - [x] 新增 `onToggleDownload: VoidCallback?` 回调
  - [x] 将原静态"移除下载"菜单项改为条件渲染：isDownloaded=true 时展示"移除下载"(trash2)，isDownloaded=false 时展示"下载"(arrowDown)
  - [x] 点击时调用 `onToggleDownload` 并触发 `_handleItemSelected()`

- [x] Task 2: 改造 DownloadStatusIcon — 支持已下载/下载中两种视觉状态
  - [x] 新增 `progress` 可选参数（double?，0.0~1.0）
  - [x] 当 progress 为 null 时：保持当前灰底+arrowDown 图标样式（已下载状态）
  - [x] 当 progress 非空时：展示圆环 CircularProgressIndicator，strokeWidth=1.5，size=12，value=progress

- [x] Task 3: 扩展 EpisodeControlBar — 新增下载/移除逻辑
  - [x] 新增 download_provider / downloaded_episodes_provider 导入
  - [x] 将 isDownloaded 和 onToggleDownload 传递给 EpisodeDropdown
  - [x] 实现 `_handleDownload()` 方法：调用 AudioDownloadService.instance.downloadEpisodeById(episodeId)
  - [x] 实现 `_handleRemoveDownload()` 方法：调用 AudioDownloadService.instance.deleteDownloadedEpisode(episodeId.toString())，成功后 invalidate downloadedEpisodesNotifierProvider
  - [x] 修改 DownloadStatusIcon 渲染逻辑：从 downloadNotifierProvider 监听该 episode 的下载状态和进度，下载中时传 progress 给 DownloadStatusIcon
  - [x] 展示条件扩展为：isDownloaded==true 或 isDownloading==true 时展示图标

- [x] Task 4: 改造 EpisodeInfo — 确认向 EpisodeControlBar 传递了 isDownloaded 参数

- [x] Task 5: 确保 Downloads 页面自动刷新 + flutter analyze 无错误
  - [x] downloadedEpisodesNotifierProvider 通过 ref.invalidate 触发刷新
  - [x] flutter analyze 5 个文件均无错误
