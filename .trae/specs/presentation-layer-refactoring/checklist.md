# 检查清单

## 功能模块化结构

- [ ] `lib/presentation/features/` 目录已创建
- [ ] 各功能模块子目录已创建（home、search、library、downloads、player、favorite、subscribe、settings、queue）
- [ ] 功能模块目录结构清晰，符合规范

## pages 迁移

- [ ] search 模块已迁移到 `features/search/`
- [ ] library 模块已迁移到 `features/library/`
- [ ] downloads 模块已迁移到 `features/downloads/`
- [ ] favorite 模块已迁移到 `features/favorite/`
- [ ] subscribe 模块已迁移到 `features/subscribe/`
- [ ] settings 模块已迁移到 `features/settings/`
- [ ] episode_detail 模块已迁移到 `features/player/`
- [ ] podcast_detail 模块已迁移到 `features/library/`
- [ ] up_next_queue 模块已迁移到 `features/queue/`
- [ ] debug 模块已迁移到 `features/debug/`
- [ ] homepage 和 body 已迁移到 `features/home/`

## 功能特定 widgets 迁移

- [ ] search 相关 widgets 已迁移到 `features/search/widgets/`
- [ ] downloads 相关 widgets 已迁移到 `features/downloads/widgets/`
- [ ] favorite 相关 widgets 已迁移到 `features/favorite/widgets/`
- [ ] library 相关 widgets 已迁移到 `features/library/widgets/`
- [ ] subscribe 相关 widgets 已迁移到 `features/subscribe/widgets/`
- [ ] settings 相关 widgets 已迁移到 `features/settings/widgets/`
- [ ] queue 相关 widgets 已迁移到 `features/queue/widgets/`

## Provider 迁移

- [ ] `search_provider.dart` 已迁移到 `features/search/`
- [ ] `podcast_search_provider.dart` 已迁移到 `features/search/`
- [ ] `unplayed_episodes_provider.dart` 已迁移到 `features/library/`
- [ ] 全局 Provider（`playback_provider.dart`、`navigation_provider.dart`、`podcast_provider.dart`）保留在 `presentation/providers/`

## core/utils 清理

- [ ] `error_handling_example.dart` 已删除
- [ ] `error_dialog.dart` 已移动到 `presentation/widgets/common/`
- [ ] `error_toast.dart` 已移动到 `presentation/widgets/common/`
- [ ] `network_helper.dart` 已检查和优化

## widgets 原子设计优化

- [ ] `presentation/widgets/organisms/` 目录已创建
- [ ] `mini_player` 已移动到 organisms
- [ ] `sidebar` 已移动到 organisms
- [ ] `home_toolbar` 已移动到 organisms

## 导入路径更新

- [ ] 所有迁移文件的导入路径已更新
- [ ] 路由配置中的页面路径已更新
- [ ] 所有引用这些文件的代码已更新

## 功能验证

- [ ] `flutter analyze` 无错误
- [ ] 应用能正常启动
- [ ] 所有页面导航正常
- [ ] 所有功能正常运行（搜索、下载、播放、订阅、设置等）
