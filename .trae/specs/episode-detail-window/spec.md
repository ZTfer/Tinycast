# Episode Detail Window 功能 Spec

## 为什么

当前点击队列中的节目标题时，会打开一个空的 episode detail 窗口，无法展示实际的 episode 信息。用户需要在新窗口中查看当前 episode 的详细信息，包括发布时间、标题、封面图、播客名称和 episode 描述。

## 变更内容

- 修改 `openEpisodeDetailWindow` 函数，支持传递 episode 和 podcast 数据
- 更新 `EpisodeDetail` 组件，接收并展示真实的 episode 数据
- 更新 `EpisodeInfo` 组件，使用 `TimeFormatter` 格式化展示发布时间
- 更新 `ShowInfo` 组件，展示播客封面图和名称
- 更新 `EpisodeDescription` 组件，使用 `flutter_widget_from_html` 展示 episode 描述

## 影响

- 受影响的规格：队列管理
- 受影响的代码：
  - `lib/main.dart` - 修改 `openEpisodeDetailWindow` 函数
  - `lib/multi_window.dart` - 更新窗口参数传递
  - `lib/presentation/pages/episode_detail/episode_detail.dart` - 接收数据
  - `lib/presentation/pages/episode_detail/episode_info.dart` - 展示真实数据
  - `lib/presentation/pages/episode_detail/show_info.dart` - 展示播客信息
  - `lib/presentation/pages/episode_detail/episode_description.dart` - 展示描述
  - `lib/presentation/pages/up_next_queue/queue_item/queue_episode_info.dart` - 传递数据

## 新增需求

### 需求：Episode Detail 数据传递

系统应支持将 episode 和 podcast 数据传递到详情窗口。

#### 场景：打开详情窗口时传递数据

- **当**用户点击队列中的节目标题
- **则**系统应收集当前 episode 和对应的 podcast 数据
- **并且**将数据序列化后传递给新窗口
- **并且**新窗口接收并解析数据

### 需求：Episode 信息展示

系统应在详情窗口展示 episode 的基本信息。

#### 场景：展示发布时间

- **当**详情窗口加载完成
- **则**应使用 `TimeFormatter.formatTimeAgo` 格式化发布时间
- **并且**展示在页面顶部

#### 场景：展示节目标题

- **当**详情窗口加载完成
- **则**应展示 episode 的标题
- **并且**使用粗体样式

### 需求：播客信息展示

系统应在详情窗口展示播客信息。

#### 场景：展示播客封面图

- **当**详情窗口加载完成
- **则**应展示播客的封面图
- **并且**使用 `SvgPicture.asset` 作为占位图（当没有封面时）

#### 场景：展示播客名称

- **当**详情窗口加载完成
- **则**应展示播客的名称
- **并且**点击可跳转到播客详情

### 需求：Episode 描述展示

系统应在详情窗口展示 episode 的详细描述。

#### 场景：使用 HTML 渲染描述

- **当**详情窗口加载完成
- **则**应使用 `flutter_widget_from_html` 渲染 episode 描述
- **并且**支持 HTML 标签（如 `<p>`, `<a>`, `<b>` 等）
- **并且**样式应与整体 UI 保持一致

## 修改的需求

无

## 移除的需求

无
