# 任务列表

- [ ] 任务 1：修改数据传递机制
  - [ ] 子任务 1.1：修改 `openEpisodeDetailWindow` 函数，支持接收 episode 和 podcast 参数
  - [ ] 子任务 1.2：创建窗口参数序列化/反序列化逻辑（使用 JSON）
  - [ ] 子任务 1.3：更新 `WindowArguments` 类，支持携带 episode 和 podcast 数据
  - [ ] 子任务 1.4：更新 `parseArguments` 函数，解析 JSON 数据

- [ ] 任务 2：更新 EpisodeDetail 组件
  - [ ] 子任务 2.1：修改 `EpisodeDetail` 为 StatefulWidget 或接收参数
  - [ ] 子任务 2.2：从窗口参数中获取 episode 和 podcast 数据
  - [ ] 子任务 2.3：将数据传递给子组件

- [ ] 任务 3：更新 EpisodeInfo 组件
  - [ ] 子任务 3.1：添加 episode 参数接收
  - [ ] 子任务 3.2：使用 `TimeFormatter.formatTimeAgo` 格式化 pubDate
  - [ ] 子任务 3.3：展示 episode 标题

- [ ] 任务 4：更新 ShowInfo 组件
  - [ ] 子任务 4.1：添加 podcast 参数接收
  - [ ] 子任务 4.2：展示播客封面图（使用网络图片或占位图）
  - [ ] 子任务 4.3：展示播客名称

- [ ] 任务 5：更新 EpisodeDescription 组件
  - [ ] 子任务 5.1：添加 description 参数接收
  - [ ] 子任务 5.2：集成 `flutter_widget_from_html` 包
  - [ ] 子任务 5.3：使用 `HtmlWidget` 渲染 episode 描述

- [ ] 任务 6：更新调用方
  - [ ] 子任务 6.1：修改 `queue_episode_info.dart` 中的 `openEpisodeDetailWindow` 调用
  - [ ] 子任务 6.2：获取当前 episode 对应的 podcast 数据
  - [ ] 子任务 6.3：传递 episode 和 podcast 数据给 `openEpisodeDetailWindow`

- [ ] 任务 7：验证和测试
  - [ ] 子任务 7.1：验证时间格式化显示正确
  - [ ] 子任务 7.2：验证播客封面和名称显示正确
  - [ ] 子任务 7.3：验证 HTML 描述渲染正确

## 任务依赖关系说明

本任务列表中的任务依赖关系如下：

- [任务 2] 依赖于 [任务 1]
- [任务 3] 依赖于 [任务 2]
- [任务 4] 依赖于 [任务 2]
- [任务 5] 依赖于 [任务 2]
- [任务 6] 依赖于 [任务 1]
- [任务 7] 依赖于 [任务 3, 任务 4, 任务 5, 任务 6]
