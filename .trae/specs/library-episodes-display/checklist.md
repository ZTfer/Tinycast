# 检查清单

## Provider 实现

- [ ] `latestEpisodesProvider` 已创建并使用 `FutureProvider.family`
- [ ] Provider 正确返回每个播客的最新3集剧集
- [ ] Provider 正确处理加载状态
- [ ] Provider 正确处理错误状态
- [ ] Provider 的单元测试通过

## 资料库页面集成

- [ ] `library.dart` 正确使用 `latestEpisodesProvider`
- [ ] 每个播客项都能加载并展示最新3集剧集
- [ ] 剧集数据正确传递给 `LibraryListItem` 组件
- [ ] 剧集列表在 `LibraryEpisodeItem` 中正确渲染
- [ ] 空剧集状态得到正确处理
- [ ] 剧集加载错误不影响其他播客展示

## 用户体验

- [ ] 剧集加载时有适当的加载状态指示
- [ ] 页面滚动流畅，无卡顿
- [ ] 多个播客同时加载时性能良好
- [ ] 剧集点击功能保留（TODO 注释）

## 测试覆盖

- [ ] Widget 测试验证剧集展示功能
- [ ] 空剧集状态测试通过
- [ ] 错误处理测试通过
- [ ] 手动测试验证完整功能

## 代码质量

- [ ] 代码遵循项目现有风格
- [ ] 无 lint 错误或警告
- [ ] 代码有适当的注释
- [ ] 无不必要的代码重复
