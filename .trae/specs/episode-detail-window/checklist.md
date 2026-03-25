# 检查清单

## 数据传递机制

- [x] `openEpisodeDetailWindow` 函数支持接收 episode 和 podcast 参数
- [x] 窗口参数可以正确序列化为 JSON
- [x] 窗口参数可以正确从 JSON 反序列化
- [x] `WindowArguments` 类支持携带 episode 和 podcast 数据
- [x] 新窗口可以正确接收并解析数据

## EpisodeDetail 组件

- [x] `EpisodeDetail` 组件可以接收 episode 和 podcast 数据
- [x] 数据正确传递给子组件

## EpisodeInfo 组件

- [x] 展示格式化后的发布时间（使用 TimeFormatter.formatTimeAgo）
- [x] 展示 episode 标题
- [x] 样式符合设计规范

## ShowInfo 组件

- [x] 展示播客封面图（使用网络图片或占位图）
- [x] 展示播客名称
- [x] 样式符合设计规范

## EpisodeDescription 组件

- [x] 集成 flutter_widget_from_html 包
- [x] 正确渲染 HTML 格式的 episode 描述
- [x] 样式与整体 UI 保持一致

## 调用方更新

- [x] `queue_episode_info.dart` 正确获取 episode 对应的 podcast 数据
- [x] 调用 `openEpisodeDetailWindow` 时传递 episode 和 podcast 数据

## 功能验证

- [x] 点击队列中的节目标题可以打开详情窗口
- [x] 详情窗口展示正确的发布时间
- [x] 详情窗口展示正确的节目标题
- [x] 详情窗口展示正确的播客封面图
- [x] 详情窗口展示正确的播客名称
- [x] 详情窗口正确渲染 episode 描述（支持 HTML）
