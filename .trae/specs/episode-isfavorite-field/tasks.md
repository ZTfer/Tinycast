# Tasks

- [ ] Task 1: 创建 Favorite Isar 数据模型
  - [ ] 创建 `lib/data/models/favorite_model.dart`，包含 Id id、@Index() late int episodeId、final DateTime createdAt 字段
  - [ ] 运行 `dart run build_runner build --delete-conflicting-outputs` 生成 `favorite_model.g.dart`

- [ ] Task 2: 注册 FavoriteSchema 到 IsarService
  - [ ] 在 `lib/data/database/isar_service.dart` 中 import Favorite 模型
  - [ ] 在 `Isar.open()` 的 schemas 列表中添加 `FavoriteSchema`

- [ ] Task 3: 更新 EpisodeDropdown 支持动态收藏状态
  - [ ] 添加 `bool isFavorite` 参数（默认 false）
  - [ ] 添加 `VoidCallback? onToggleFavorite` 回调参数
  - [ ] 根据 isFavorite 动态设置收藏项的 text（"收藏"/"取消收藏"）、icon（LucideIcons.star/LucideIcons.starOff）、onPressed（onToggleFavorite）

# Task Dependencies
- [Task 2] 依赖于 [Task 1]（需要先生成 FavoriteSchema）
- [Task 3] 无依赖，可与 Task 1 并行
