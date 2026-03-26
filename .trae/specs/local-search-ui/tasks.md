# 任务列表

- [ ] 任务 1：创建 SearchHistory Isar 模型
  - [ ] 子任务 1.1：创建 `SearchHistory` 模型类（包含 id、keyword、searchedAt 字段）
  - [ ] 子任务 1.2：运行 `dart run build_runner build` 生成 Isar 代码
  - [ ] 子任务 1.3：更新 `IsarService` 添加 `SearchHistorySchema`

- [ ] 任务 2：实现搜索历史数据层
  - [ ] 子任务 2.1：创建 `SearchHistoryRepository` 接口
  - [ ] 子任务 2.2：创建 `SearchHistoryRepositoryImpl` 实现类
  - [ ] 子任务 2.3：实现保存搜索历史方法
  - [ ] 子任务 2.4：实现获取搜索历史方法（按时间倒序）
  - [ ] 子任务 2.5：实现清空搜索历史方法

- [ ] 任务 3：实现搜索历史 Domain 层
  - [ ] 子任务 3.1：创建 `SaveSearchHistoryUseCase`
  - [ ] 子任务 3.2：创建 `GetSearchHistoryUseCase`
  - [ ] 子任务 3.3：创建 `ClearSearchHistoryUseCase`

- [ ] 任务 4：实现本地搜索数据层
  - [ ] 子任务 4.1：在 `PodcastRepository` 添加搜索播客方法（匹配标题和简介）
  - [ ] 子任务 4.2：在 `PodcastRepository` 添加搜索剧集方法（匹配标题和简介）
  - [ ] 子任务 4.3：实现 Isar 查询逻辑

- [ ] 任务 5：实现本地搜索 Domain 层
  - [ ] 子任务 5.1：创建 `SearchLocalContentUseCase`
  - [ ] 子任务 5.2：定义搜索结果数据结构（包含播客和剧集列表）

- [ ] 任务 6：创建 SearchProvider
  - [ ] 子任务 6.1：定义 `SearchState`（包含状态、搜索历史、搜索结果、选中索引）
  - [ ] 子任务 6.2：创建 `SearchNotifier`
  - [ ] 子任务 6.3：实现搜索状态切换逻辑
  - [ ] 子任务 6.4：实现键盘导航逻辑（上下箭头、Enter）
  - [ ] 子任务 6.5：实现鼠标 hover 选中逻辑
  - [ ] 子任务 6.6：创建相关 Providers

- [ ] 任务 7：更新 SearchPage 状态展示
  - [ ] 子任务 7.1：根据状态条件展示/隐藏 toolbar
  - [ ] 子任务 7.2：根据状态切换展示搜索历史或搜索结果或空页面
  - [ ] 子任务 7.3：连接 SearchProvider

- [ ] 任务 8：更新 SearchInput 组件
  - [ ] 子任务 8.1：添加键盘事件监听（上下箭头、Enter）
  - [ ] 子任务 8.2：触发搜索时保存搜索历史
  - [ ] 子任务 8.3：连接 SearchProvider

- [ ] 任务 9：更新搜索历史组件
  - [ ] 子任务 9.1：更新 `SearchHistoryList` 使用真实数据
  - [ ] 子任务 9.2：更新 `SearchHistoryItem` 支持选中状态
  - [ ] 子任务 9.3：实现点击历史项触发搜索

- [ ] 任务 10：更新搜索结果组件
  - [ ] 子任务 10.1：更新 `SearchResultsPodcastList` 使用真实数据
  - [ ] 子任务 10.2：更新 `SearchResultsEpisodeList` 使用真实数据
  - [ ] 子任务 10.3：更新 `SearchResultsShowItem` 支持选中状态和跳转
  - [ ] 子任务 10.4：更新 `SearchResultsEpisodeItem` 支持选中状态和跳转
  - [ ] 子任务 10.5：合并播客和剧集搜索结果展示

- [ ] 任务 11：更新 SearchToolbar
  - [ ] 子任务 11.1：连接清空记录按钮到 SearchProvider
  - [ ] 子任务 11.2：实现清空搜索历史功能

- [ ] 任务 12：实现搜索结果跳转
  - [ ] 子任务 12.1：添加剧集详情路由
  - [ ] 子任务 12.2：实现播客搜索结果跳转到播客详情
  - [ ] 子任务 12.3：实现剧集搜索结果跳转到剧集详情

## 任务依赖关系

- [任务 2] 依赖于 [任务 1]
- [任务 3] 依赖于 [任务 2]
- [任务 4] 无依赖
- [任务 5] 依赖于 [任务 4]
- [任务 6] 依赖于 [任务 3, 任务 5]
- [任务 7] 依赖于 [任务 6]
- [任务 8] 依赖于 [任务 6]
- [任务 9] 依赖于 [任务 6]
- [任务 10] 依赖于 [任务 6]
- [任务 11] 依赖于 [任务 6]
- [任务 12] 依赖于 [任务 7, 任务 10]
