# 检查清单

## 数据传递机制

- [ ] `openEpisodeDetailWindow` 函数支持接收 episode 和 podcast 参数
- [ ] 窗口参数可以正确序列化为 JSON
- [ ] 窗口参数可以正确从 JSON 反序列化
- [ ] `WindowArguments` 类支持携带 episode 和 podcast 数据
- [ ] 新窗口可以正确接收并解析数据

## EpisodeDetail 组件

- [ ] `EpisodeDetail` 组件可以接收 episode 和 podcast 数据
- [ ] 数据正确传递给子组件

## EpisodeInfo 组件

- [ ] 展示格式化后的发布时间（使用 TimeFormatter.formatTimeAgo）
- [ ] 展示 episode 标题
- [ ] 样式符合设计规范

## ShowInfo 组件

- [ ] 展示播客封面图（使用网络图片或占位图）
- [ ] 展示播客名称
- [ ] 样式符合设计规范

## EpisodeDescription 组件

- [ ] 集成 flutter_widget_from_html 包
- [ ] 正确渲染 HTML 格式的 episode 描述
- [ ] 样式与整体 UI 保持一致

## 调用方更新

- [ ] `queue_episode_info.dart` 正确获取 episode 对应的 podcast 数据
- [ ] 调用 `openEpisodeDetailWindow` 时传递 episode 和 podcast 数据

## 功能验证

- [ ] 点击队列中的节目标题可以打开详情窗口
- [ ] 详情窗口展示正确的发布时间
- [ ] 详情窗口展示正确的节目标题
- [ ] 详情窗口展示正确的播客封面图
- [ ] 详情窗口展示正确的播客名称
- [ ] 详情窗口正确渲染 episode 描述（支持 HTML）
