# 已下载Episode列表展示 Spec

## 为什么

当前 Downloads 页面使用硬编码的模拟数据展示，无法反映真实的已下载 episode 状态。需要将其改造为从数据源获取所有已下载的 episode 列表，并复用已有的 `EpisodeItem` 组件，避免在 downloads 目录下维护重复的 UI 组件。

## 变更内容

- 新增 `getDownloadedEpisodesUseCase` 用于获取所有已下载的 episode
- 在 `PodcastRepository` 中新增 `getDownloadedEpisodes()` 方法
- 新增 `downloaded_episodes_provider.dart` 提供者（参考 `unplayed_episodes_provider.dart` 模式）
- 重构 `downloads.dart`：改为 `ConsumerWidget`，使用 `EpisodeItem` 组件展示列表（参考 `up_next_queue.dart` 模式）
- 移除对 `downloads_list_item`、`downloads_episode_dropdown`、`downloads_episode_info` 等自定义组件的依赖

## 影响

- 受影响的代码：
  - `lib/presentation/features/downloads/downloads.dart`（重构主页面）
  - `lib/domain/repositories/podcast_repository.dart`（新增接口方法）
  - `lib/data/repositories/podcast_repository_impl.dart`（实现新方法）
  - `lib/domain/usecases/`（新增 use case）
  - `lib/presentation/providers/` 或 `lib/presentation/features/downloads/`（新增 provider）

## 新增需求

### 需求：获取已下载 Episode 列表

系统应提供获取所有已下载 episode 的能力。

#### 场景：获取已下载列表

- **当**调用获取已下载 episode 方法
- **则**系统应返回所有 `isDownloaded == true` 的 episode 列表
- **并且**按发布时间降序排序

### 需求：Downloads 页面展示已下载 Episode

Downloads 页面应展示所有已下载的 episode 列表。

#### 场景：显示已下载列表

- **当**用户进入 Downloads 页面
- **且**存在已下载的 episode
- **则**应使用 `EpisodeItem` 组件展示每个已下载 episode
- **并且**最后一项不显示分隔线
- **并且**支持点击播放和点击查看详情

#### 场景：加载状态

- **当**数据正在加载
- **则**应显示加载指示器（CircularProgressIndicator）

#### 场景：空状态

- **当**没有已下载的 episode
- **则**应显示空状态提示

## 修改的需求

无

## 移除的需求

无
