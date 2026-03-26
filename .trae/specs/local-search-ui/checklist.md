# 检查清单

## SearchHistory Isar 模型

- [ ] SearchHistory 模型类已创建（包含 id、keyword、searchedAt 字段）
- [ ] Isar 代码已生成
- [ ] IsarService 已更新添加 SearchHistorySchema

## 搜索历史数据层

- [ ] SearchHistoryRepository 接口已创建
- [ ] SearchHistoryRepositoryImpl 实现类已创建
- [ ] 保存搜索历史方法正常工作
- [ ] 获取搜索历史方法正常工作（按时间倒序）
- [ ] 清空搜索历史方法正常工作

## 搜索历史 Domain 层

- [ ] SaveSearchHistoryUseCase 已创建
- [ ] GetSearchHistoryUseCase 已创建
- [ ] ClearSearchHistoryUseCase 已创建

## 本地搜索数据层

- [ ] PodcastRepository 搜索播客方法已添加
- [ ] PodcastRepository 搜索剧集方法已添加
- [ ] Isar 查询逻辑正常工作

## 本地搜索 Domain 层

- [ ] SearchLocalContentUseCase 已创建
- [ ] 搜索结果数据结构已定义

## SearchProvider

- [ ] SearchState 已定义
- [ ] SearchNotifier 已创建
- [ ] 搜索状态切换逻辑正常工作
- [ ] 键盘导航逻辑正常工作（上下箭头、Enter）
- [ ] 鼠标 hover 选中逻辑正常工作
- [ ] 相关 Providers 已创建

## SearchPage 状态展示

- [ ] toolbar 根据状态条件展示/隐藏
- [ ] 根据状态切换展示搜索历史或搜索结果或空页面
- [ ] SearchProvider 已连接

## SearchInput 组件

- [ ] 键盘事件监听已添加（上下箭头、Enter）
- [ ] 搜索时保存搜索历史
- [ ] SearchProvider 已连接

## 搜索历史组件

- [ ] SearchHistoryList 使用真实数据
- [ ] SearchHistoryItem 支持选中状态
- [ ] 点击历史项触发搜索正常工作

## 搜索结果组件

- [ ] SearchResultsPodcastList 使用真实数据
- [ ] SearchResultsEpisodeList 使用真实数据
- [ ] SearchResultsShowItem 支持选中状态和跳转
- [ ] SearchResultsEpisodeItem 支持选中状态和跳转
- [ ] 播客和剧集搜索结果合并展示正常

## SearchToolbar

- [ ] 清空记录按钮连接到 SearchProvider
- [ ] 清空搜索历史功能正常工作

## 搜索结果跳转

- [ ] 剧集详情路由已添加
- [ ] 播客搜索结果跳转到播客详情正常
- [ ] 剧集搜索结果跳转到剧集详情正常
