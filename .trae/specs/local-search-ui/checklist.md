# 检查清单

## SearchHistory Isar 模型

- [x] SearchHistory 模型类已创建（包含 id、keyword、searchedAt 字段）
- [x] Isar 代码已生成
- [x] IsarService 已更新添加 SearchHistorySchema

## 搜索历史数据层

- [x] SearchHistoryRepository 接口已创建
- [x] SearchHistoryRepositoryImpl 实现类已创建
- [x] 保存搜索历史方法正常工作
- [x] 获取搜索历史方法正常工作（按时间倒序）
- [x] 清空搜索历史方法正常工作

## 搜索历史 Domain 层

- [x] SaveSearchHistoryUseCase 已创建
- [x] GetSearchHistoryUseCase 已创建
- [x] ClearSearchHistoryUseCase 已创建

## 本地搜索数据层

- [x] PodcastRepository 搜索播客方法已添加
- [x] PodcastRepository 搜索剧集方法已添加
- [x] Isar 查询逻辑正常工作

## 本地搜索 Domain 层

- [x] SearchLocalContentUseCase 已创建
- [x] 搜索结果数据结构已定义

## SearchProvider

- [x] SearchState 已定义
- [x] SearchNotifier 已创建
- [x] 搜索状态切换逻辑正常工作
- [x] 键盘导航逻辑正常工作（上下箭头、Enter）
- [x] 鼠标 hover 选中逻辑正常工作
- [x] 相关 Providers 已创建

## SearchPage 状态展示

- [x] toolbar 根据状态条件展示/隐藏
- [x] 根据状态切换展示搜索历史或搜索结果或空页面
- [x] SearchProvider 已连接

## SearchInput 组件

- [x] 键盘事件监听已添加（上下箭头、Enter）
- [x] 搜索时保存搜索历史
- [x] SearchProvider 已连接

## 搜索历史组件

- [x] SearchHistoryList 使用真实数据
- [x] SearchHistoryItem 支持选中状态
- [x] 点击历史项触发搜索正常工作

## 搜索结果组件

- [x] SearchResultsPodcastList 使用真实数据
- [x] SearchResultsEpisodeList 使用真实数据
- [x] SearchResultsShowItem 支持选中状态和跳转
- [x] SearchResultsEpisodeItem 支持选中状态和跳转
- [x] 播客和剧集搜索结果合并展示正常

## SearchToolbar

- [x] 清空记录按钮连接到 SearchProvider
- [x] 清空搜索历史功能正常工作

## 搜索结果跳转

- [x] 剧集详情路由已添加
- [x] 播客搜索结果跳转到播客详情正常
- [x] 剧集搜索结果跳转到剧集详情正常
