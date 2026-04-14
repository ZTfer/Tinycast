# 标记为已播放功能 Spec

## Why
用户需要手动将 episode 标记为已播放状态，以便：
- 管理收听进度，快速标记已听完的内容
- 自动从待播清单（queue）中移除已完成的项目
- 在播放历史中记录完成状态（不记录实际播放时长）

## What Changes
- 在 EpisodeDropdown 组件中添加 `onMarkAsPlayed` 回调参数
- 实现标记已播放在 EpisodeControlBar 中的业务逻辑
- 新增/更新数据源层方法：更新 episode.isPlayed、更新/创建 PlayHistory 记录
- 如果 episode 在 queue 数据库中，自动移除
- 刷新 queue.dart 的 UI 显示
- **注意**：PlayHistory 中的 `playedDuration` 字段保持为 0 或现有值，不因手动标记而增加

## Impact
- Affected specs: dropdown-menu-system, playback-history, queue-management
- Affected code:
  - `/lib/presentation/widgets/organisms/dropdown/episode_dropdown/episode_dropdown.dart` - 添加回调参数
  - `/lib/presentation/widgets/molecules/episode_item/episode_control_bar.dart` - 实现业务逻辑
  - `/lib/data/datasources/local_podcast_datasource.dart` - 添加更新 isPlayed 方法
  - `/lib/domain/repositories/podcast_repository.dart` - 添加接口方法
  - `/lib/data/repositories/podcast_repository_impl.dart` - 实现方法
  - `/lib/data/datasources/local_queue_datasource.dart` - 已有 removeFromQueueByEpisodeId 方法
  - `/lib/presentation/providers/queue_provider.dart` - 集成刷新逻辑
  - `/lib/core/utils/toast_utils.dart` - 复用 Toast 工具

## ADDED Requirements

### Requirement: EpisodeDropdown 标记已播放回调
EpisodeDropdown 组件 SHALL 提供 `onMarkAsPlayed` 回调参数，用于处理标记已播放的业务逻辑。

#### 接口定义：
```dart
final VoidCallback? onMarkAsPlayed; // 标记已播放回调
```

#### Scenario: 点击标记为已播放按钮
- **WHEN** 用户点击"标记为已播放"菜单项
- **THEN** 调用 `onMarkAsPlayed?.call()` 执行业务逻辑
- **AND** 关闭下拉菜单

### Requirement: 标记已播放业务逻辑
系统 SHALL 实现完整的标记已播放流程：

#### 执行顺序：
1. **更新 Episode 状态**：将 episode 的 `isPlayed` 字段设置为 `true`
2. **更新/创建 PlayHistory 记录**：
   - 如果存在对应 episodeId 的 PlayHistory 记录 → 更新：`isPlayed=true`, `status=completed`, `lastUpdateTime=now`
   - 如果不存在 → 创建新记录：`isPlayed=true`, `status=completed`, `playedDuration=0`（不增加实际播放时长）
3. **检查并移除 Queue**：如果该 episode 在 queue 数据库中存在 → 移除该记录
4. **刷新 UI**：触发 queue 列表刷新
5. **显示反馈**：Toast 提示"已标记为已播放"

#### Scenario: 成功标记已播放
- **WHEN** 用户点击"标记为已播放"
- **THEN** 系统：
  1. 更新 episode.isPlayed = true 到数据库
  2. 更新/创建 PlayHistory 记录（status=completed, playedDuration 不变）
  3. 从 queue 中移除该 episode（如果存在）
  4. 刷新 queue UI
  5. 显示成功 Toast

#### Scenario: Episode 已在 Queue 中
- **WHEN** 标记已播放的 episode 当前在 queue 数据库中
- **THEN** 系统自动将该 episode 从 queue 中移除
- **AND** queue.dart 列表立即更新，不再显示该 episode

### Requirement: PlayHistory 播放时长字段说明
PlayHistory 模型中的 `playedDuration` 字段 SHALL 仅用于记录**实际播放时长**（通过播放器监听累计），不因手动标记操作而修改。

#### 规则：
- 手动标记已播放时：**不修改** `playedDuration` 值（保持原值或 0）
- 实际播放时：由播放器进度监听器累计更新（拖动进度条、跳过不计入）
- 字段用途：统计用户的真实收听时长

#### Scenario: 手动标记不影响播放时长
- **WHEN** 用户手动标记 episode 为已播放
- **THEN** PlayHistory.playedDuration 保持不变（不增加）

## MODIFIED Requirements

### Requirement: EpisodeDropdown 组件接口
修改后的 EpisodeDropdown SHALL 包含以下新增参数：

```dart
class EpisodeDropdown extends StatelessWidget {
  final VoidCallback? onMarkAsPlayed; // 标记已播放回调
  
  const EpisodeDropdown({
    ...
    this.onMarkAsPlayed,
  });
}
```

### Requirement: EpisodeControlBar 业务集成
EpisodeControlBar SHALL 实现 `_handleMarkAsPlayed()` 方法：

```dart
Future<void> _handleMarkAsPlayed() async {
  // 1. 更新 episode.isPlayed = true
  // 2. 更新/创建 PlayHistory 记录（status=completed）
  // 3. 从 queue 移除（如果存在）
  // 4. 刷新 queue UI
  // 5. 显示 Toast "已标记为已播放"
}
```

### Requirement: PodcastRepository 接口扩展
PodcastRepository SHALL 新增更新 isPlayed 状态的方法：

```dart
abstract class PodcastRepository {
  ...
  Future<void> updateIsPlayed(int episodeId, bool isPlayed);
}
```

## REMOVED Requirements
无
