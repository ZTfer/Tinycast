# Tasks

- [ ] Task 1: 在 Episode Isar 模型中添加 isFavorite 字段
  - [ ] 在 `lib/data/models/episode_model.dart` 中添加 `late bool isFavorite` 字段（位于 isPlayed 附近）
  - [ ] 运行 `dart run build_runner build --delete-conflicting-outputs` 重新生成 `episode_model.g.dart`

- [ ] Task 2: 在 Domain 层 Episode 实体中添加 isFavorite 字段
  - [ ] 在 `lib/domain/entities/episode.dart` 中添加 `final bool isFavorite` 字段
  - [ ] 在构造函数中添加 `isFavorite = false` 默认参数

- [ ] Task 3: 更新 EpisodeDropdown 组件支持动态收藏状态
  - [ ] 添加 `Episode? episode` 可选参数
  - [ ] 添加 `VoidCallback? onToggleFavorite` 回调参数
  - [ ] 根据 `episode?.isFavorite` 动态渲染收藏菜单项（文本、图标、回调）

- [ ] Task 4: 更新所有 Episode 构造函数调用处兼容新字段
  - [ ] 搜索所有 `Episode(` 构造函数调用，确保传入 isFavorite 参数或使用默认值

# Task Dependencies
- [Task 2] 无依赖，可与 Task 1 并行
- [Task 3] 依赖于 [Task 1, Task 2]
- [Task 4] 依赖于 [Task 2]
