# 检查清单

## 功能模块化结构

- [x] `lib/presentation/features/` 目录已创建
- [x] 各功能模块子目录已创建（home、search、library、downloads、player、favorite、subscribe、settings、queue）
- [x] 功能模块目录结构清晰，符合规范

## pages 迁移

- [x] search 模块已迁移到 `features/search/`
- [x] library 模块已迁移到 `features/library/`
- [x] downloads 模块已迁移到 `features/downloads/`
- [x] favorite 模块已迁移到 `features/favorite/`
- [x] subscribe 模块已迁移到 `features/subscribe/`
- [x] settings 模块已迁移到 `features/settings/`
- [x] episode_detail 模块已迁移到 `features/player/`
- [x] podcast_detail 模块已迁移到 `features/library/`
- [x] up_next_queue 模块已迁移到 `features/queue/`
- [x] debug 模块已迁移到 `features/debug/`
- [x] homepage 和 body 已迁移到 `features/home/`
- [x] test_page 已迁移到 `features/debug/`

## 功能特定 widgets 迁移

- [x] search 相关 widgets 已迁移到 `features/search/` - 按子模块组织
- [x] downloads 相关 widgets 已迁移到 `features/downloads/` - 按子模块组织
- [x] favorite 相关 widgets 已迁移到 `features/favorite/` - 按子模块组织
- [x] library 相关 widgets 已迁移到 `features/library/` - 按子模块组织
- [x] subscribe 相关 widgets 已迁移到 `features/subscribe/` - 按子模块组织
- [x] settings 相关 widgets 已迁移到 `features/settings/` - 按子模块组织
- [x] queue 相关 widgets 已迁移到 `features/queue/` - 按子模块组织

## Provider 迁移

- [x] `search_provider.dart` 已迁移到 `features/search/`
- [x] `podcast_search_provider.dart` 已迁移到 `features/search/`
- [x] `unplayed_episodes_provider.dart` 已迁移到 `features/library/`
- [x] 全局 Provider（`playback_provider.dart`、`navigation_provider.dart`、`podcast_provider.dart`）保留在 `presentation/providers/`

## core/utils 清理

- [x] `error_handling_example.dart` 已删除
- [x] `error_dialog.dart` 已移动到 `presentation/widgets/common/`
- [x] `error_toast.dart` 已移动到 `presentation/widgets/common/`
- [x] `network_helper.dart` 已检查和优化 - 建议保留在原位置

## widgets 原子设计优化

- [x] `presentation/widgets/organisms/` 目录已创建
- [x] `mini_player` 已移动到 organisms
- [x] `sidebar` 已移动到 organisms
- [x] `home_toolbar` 已移动到 organisms

## 导入路径更新

- [x] 所有迁移文件的导入路径已更新
- [x] 路由配置中的页面路径已更新
- [x] 所有引用这些文件的代码已更新

## 功能验证

- [x] `flutter analyze` 无错误
- [ ] 应用能正常启动 - 需要用户手动测试
- [ ] 所有页面导航正常 - 需要用户手动测试
- [ ] 所有功能正常运行（搜索、下载、播放、订阅、设置等） - 需要用户手动测试
