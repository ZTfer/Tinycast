# 播客库展示最新剧集功能 Spec

## Why

当前资料库页面虽然能显示播客列表，但每个播客下方的剧集列表为空，用户无法快速查看每个播客的最新内容。需要从数据库加载并展示每个播客的最新3集剧集，提升用户体验。

## What Changes

- 在 `library.dart` 中为每个播客加载最新3集剧集
- 使用现有的 `podcastProvider` 的 `loadEpisodesByPodcastId` 方法获取剧集数据
- 将剧集数据传递给 `LibraryListItem` 组件进行展示
- 优化数据加载策略，避免阻塞UI渲染

## Impact

- Affected specs: podcast-app-mvp (任务 10)
- Affected code:
  - `lib/presentation/pages/library/library.dart`
  - `lib/presentation/providers/podcast_provider.dart`

## ADDED Requirements

### Requirement: 展示播客最新剧集

系统应当在资料库页面的每个播客项下展示最新3集剧集。

#### Scenario: 成功加载剧集

- **WHEN** 用户打开资料库页面
- **THEN** 系统加载所有订阅的播客
- **AND** 为每个播客加载最新3集剧集
- **AND** 在播客信息下方展示剧集列表

#### Scenario: 剧集数据为空

- **WHEN** 某个播客没有剧集数据
- **THEN** 该播客项下不显示剧集列表或显示空状态

#### Scenario: 加载剧集失败

- **WHEN** 加载剧集时发生错误
- **THEN** 该播客项下不显示剧集列表
- **AND** 不影响其他播客和剧集的展示

## MODIFIED Requirements

### Requirement: 资料库页面数据加载

资料库页面需要同时加载播客列表和每个播客的最新剧集。

原有实现：

```dart
final episodes = <Episode>[];
```

修改为：

```dart
final episodes = await _loadEpisodesForPodcast(podcast.id);
```

## Implementation Notes

### 数据加载策略

1. **并行加载**: 先加载播客列表，然后并行加载每个播客的最新3集剧集
2. **懒加载**: 可以考虑在用户滚动到播客项时才加载剧集（可选优化）
3. **缓存策略**: 使用 Riverpod 的状态管理缓存已加载的剧集数据

### Provider 扩展

考虑创建一个专门的 provider 来管理每个播客的最新剧集：

```dart
final latestEpisodesProvider = FutureProvider.family<List<Episode>, int>((ref, podcastId) async {
  final useCase = ref.watch(getEpisodesByPodcastIdUseCaseProvider);
  final episodes = await useCase(podcastId);
  return episodes.take(3).toList();
});
```

### 性能考虑

- 如果播客数量较多，考虑限制并发加载数量
- 可以使用 `Future.wait` 并行加载所有播客的剧集
- 考虑添加加载状态指示器
