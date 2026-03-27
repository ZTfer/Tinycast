# Tasks

- [x] Task 1: 修改 LibraryShowInfo 组件支持标题点击和 hover 效果
  - [x] SubTask 1.1: 将标题 Text 改为可交互的组件（如 MouseRegion + GestureDetector 或 InkWell）
  - [x] SubTask 1.2: 添加 hover 状态管理
  - [x] SubTask 1.3: 实现 hover 时下划线效果
  - [x] SubTask 1.4: 添加 onTitleTap 回调参数

- [x] Task 2: 修改 LibraryListItem 组件传递点击事件
  - [x] SubTask 2.1: 在 LibraryListItem 中添加 onTitleTap 参数
  - [x] SubTask 2.2: 将 onTitleTap 传递给 LibraryShowInfo

- [x] Task 3: 修改 Library 页面处理标题点击导航
  - [x] SubTask 3.1: 在 _LibraryPodcastItem 中添加标题点击处理
  - [x] SubTask 3.2: 调用 _navigateToPodcastDetail 方法进行导航

- [x] Task 4: 验证 MiniPlayer 始终展示在页面顶部
  - [x] SubTask 4.1: 检查 HomePage 布局确保 MiniPlayer 在顶部
  - [x] SubTask 4.2: 验证页面滚动时 MiniPlayer 位置固定

## Task Dependencies

- Task 2 依赖于 Task 1
- Task 3 依赖于 Task 2
