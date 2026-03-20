# Tasks

- [ ] Task 1: 改进 SubscribeEpisodeAddButton 组件，支持自定义图标
  - [ ] SubTask 1.1: 添加 icon 可选参数到 SubscribeEpisodeAddButton
  - [ ] SubTask 1.2: 修改 _SubscribeEpisodeAddButtonWidget 支持自定义图标
  - [ ] SubTask 1.3: 确保已订阅状态和加载状态不受影响
  - [ ] SubTask 1.4: 测试按钮在不同状态下的显示

- [ ] Task 2: 创建 Library 空状态页面组件
  - [ ] SubTask 2.1: 创建 library_empty_page 目录结构
  - [ ] SubTask 2.2: 创建 LibraryEmptyInfo 组件，显示空状态图标和文字
  - [ ] SubTask 2.3: 创建 LibraryEmptyButton 组件，参考 QueueEmptyButton 设计
  - [ ] SubTask 2.4: 创建 LibraryEmptyControlBar 组件，包含 RSS 订阅和搜索播客按钮
  - [ ] SubTask 2.5: 创建 LibraryEmptyPage 主组件，整合所有子组件

- [ ] Task 3: 集成 Library 空状态页面到 Library 页面
  - [ ] SubTask 3.1: 修改 Library 页面的空状态判断逻辑
  - [ ] SubTask 3.2: 替换现有的空状态展示为 LibraryEmptyPage
  - [ ] SubTask 3.3: 实现 RSS 订阅按钮的导航逻辑
  - [ ] SubTask 3.4: 实现搜索播客按钮的导航逻辑

- [ ] Task 4: 验证播客订阅流程
  - [ ] SubTask 4.1: 验证单个播客添加流程
  - [ ] SubTask 4.2: 验证批量添加播客流程
  - [ ] SubTask 4.3: 验证按钮状态更新
  - [ ] SubTask 4.4: 验证数据库检查逻辑

# Task Dependencies

- [Task 3] depends on [Task 2]
- [Task 4] depends on [Task 1, Task 3]
