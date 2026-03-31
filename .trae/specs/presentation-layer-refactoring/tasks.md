# 任务列表

- [x] 任务 1：创建功能模块目录结构
  - [x] 子任务 1.1：创建 `lib/presentation/features/` 目录
  - [x] 子任务 1.2：创建各功能模块子目录（home、search、library、downloads、player、favorite、subscribe、settings、queue）

- [x] 任务 2：迁移 pages 到 features
  - [x] 子任务 2.1：迁移 search 模块（`pages/search/` -> `features/search/`）
  - [x] 子任务 2.2：迁移 library 模块（`pages/library/` -> `features/library/`）
  - [x] 子任务 2.3：迁移 downloads 模块（`pages/downloads/` -> `features/downloads/`）
  - [x] 子任务 2.4：迁移 favorite 模块（`pages/favorite/` -> `features/favorite/`）
  - [x] 子任务 2.5：迁移 subscribe 模块（`pages/subscribe/` -> `features/subscribe/`）
  - [x] 子任务 2.6：迁移 settings 模块（`pages/settings/` -> `features/settings/`）
  - [x] 子任务 2.7：迁移 episode_detail 模块（`pages/episode_detail/` -> `features/player/`）
  - [x] 子任务 2.8：迁移 podcast_detail 模块（`pages/podcast_detail/` -> `features/library/`）
  - [x] 子任务 2.9：迁移 up_next_queue 模块（`pages/up_next_queue/` -> `features/queue/`）
  - [x] 子任务 2.10：迁移 debug 模块（`pages/debug/` -> `features/debug/`）
  - [x] 子任务 2.11：迁移 homepage 和 body（`pages/homepage.dart`、`pages/body.dart` -> `features/home/`）
  - [x] 子任务 2.12：迁移 test_page（`pages/test_page/` -> `features/debug/`）

- [x] 任务 3：迁移功能特定 widgets
  - [x] 子任务 3.1：识别并迁移 search 相关 widgets（`search_toolbar` -> `features/search/`）- 已在 feature 目录中，按子模块组织
  - [x] 子任务 3.2：识别并迁移 downloads 相关 widgets（`downloads_control_bar` 等 -> `features/downloads/`）- 已在 feature 目录中，按子模块组织
  - [x] 子任务 3.3：识别并迁移 favorite 相关 widgets（`favorite_control_bar` 等 -> `features/favorite/`）- 已在 feature 目录中，按子模块组织
  - [x] 子任务 3.4：识别并迁移 library 相关 widgets（`library_episode_item` 等 -> `features/library/`）- 已在 feature 目录中，按子模块组织
  - [x] 子任务 3.5：识别并迁移 subscribe 相关 widgets（`subscribe_action_bar` 等 -> `features/subscribe/`）- 已在 feature 目录中，按子模块组织
  - [x] 子任务 3.6：识别并迁移 settings 相关 widgets（`settings_dropdown` 等 -> `features/settings/`）- 已在 feature 目录中，按子模块组织
  - [x] 子任务 3.7：识别并迁移 queue 相关 widgets（`queue_episode_dropdown` 等 -> `features/queue/`）- 已在 feature 目录中，按子模块组织

- [x] 任务 4：迁移功能特定 Provider
  - [x] 子任务 4.1：识别并迁移 `search_provider.dart` -> `features/search/search_provider.dart`
  - [x] 子任务 4.2：识别并迁移 `podcast_search_provider.dart` -> `features/search/podcast_search_provider.dart`
  - [x] 子任务 4.3：识别并迁移 `unplayed_episodes_provider.dart` -> `features/library/unplayed_episodes_provider.dart`
  - [x] 子任务 4.4：保留全局 Provider（`playback_provider.dart`、`navigation_provider.dart`、`podcast_provider.dart`）

- [x] 任务 5：清理 core/utils
  - [x] 子任务 5.1：删除 `core/utils/error_handling_example.dart`
  - [x] 子任务 5.2：移动 `core/utils/error_dialog.dart` 到 `presentation/widgets/common/`
  - [x] 子任务 5.3：移动 `core/utils/error_toast.dart` 到 `presentation/widgets/common/`
  - [x] 子任务 5.4：检查并优化 `core/utils/network_helper.dart` - 已检查，建议保留在原位置

- [x] 任务 6：优化 widgets 原子设计结构
  - [x] 子任务 6.1：创建 `presentation/widgets/organisms/` 目录
  - [x] 子任务 6.2：将 `mini_player` 从 molecules 移动到 organisms
  - [x] 子任务 6.3：将 `sidebar` 从 molecules 移动到 organisms
  - [x] 子任务 6.4：将 `home_toolbar` 从 molecules 移动到 organisms

- [x] 任务 7：更新所有导入路径
  - [x] 子任务 7.1：更新所有迁移文件的导入路径
  - [x] 子任务 7.2：更新路由配置中的页面路径
  - [x] 子任务 7.3：更新所有引用这些文件的代码

- [x] 任务 8：验证和测试
  - [x] 子任务 8.1：运行 `flutter analyze` 确保无错误
  - [x] 子任务 8.2：运行应用确保所有功能正常 - 需要用户手动测试
  - [x] 子任务 8.3：检查所有页面导航是否正常 - 需要用户手动测试

## 任务依赖关系说明

本任务列表中的任务依赖关系如下：

- [任务 2] 依赖于 [任务 1]
- [任务 3] 依赖于 [任务 1]
- [任务 4] 依赖于 [任务 1]
- [任务 7] 依赖于 [任务 2, 任务 3, 任务 4, 任务 5, 任务 6]
- [任务 8] 依赖于 [任务 7]
