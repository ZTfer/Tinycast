# Queue页面重构与数据库实现 Spec

## 为什么

当前的Queue页面仅展示未播放的episodes，缺乏用户手动管理播放队列的功能。需要引入queue数据库来支持用户自定义播放顺序，并在页面上方显示手动添加的队列，下方显示未播放的episodes，提供更好的用户体验。

## 变更内容

- 创建 queue 数据库模型（Isar collection）
- 实现队列数据访问层（DataSource、Repository、UseCase）
- 创建 Riverpod Provider 管理队列状态
- 重构 Queue 页面UI结构（队列 + 未播放 episodes + 空状态）
- 添加分割线组件 `_buildDivider()`

## 影响

- 受影响的代码：
  - Data层：新增 queue_model.dart、queue 数据源和仓库
  - Domain层：新增 queue 用例
  - Presentation层：重构 queue.dart、新增 queue provider
  - Database：注册新 collection 到 Isar

## 新增需求

### 需求：Queue 数据库模型

系统应定义 QueueItem 数据模型用于持久化用户添加到播放队列的节目。

#### 场景：模型定义

- **当**定义 QueueItem 模型
- **则**应包含以下字段：
  - id: int (Isar autoIncrement)
  - episodeId: int (关联 Episode 表的主键)
  - position: int (在队列中的排序位置)
  - addedAt: DateTime (添加时间)

#### 场景：数据库配置

- **当**配置 Isar collection
- **则**应在 isar_collections.dart 中注册 QueueItem
- **并且**配置 position 字段索引用于排序

### 需求：队列数据访问

系统应提供完整的队列 CRUD 操作。

#### 场景：获取队列列表

- **当**调用获取队列方法
- **则**返回按 position 升序排列的所有 QueueItem
- **并且**可通过 episodeId 关联查询 Episode 信息

#### 场景：添加到队列

- **当**用户添加 episode 到队列
- **则**创建 QueueItem 记录，position 为当前最大值+1
- **并且**保存到数据库

#### 场景：从队列移除

- **当**用户从队列移除项目
- **则**删除对应的 QueueItem 记录
- **并且**更新剩余项目的 position 值

#### 场景：清空队列

- **当**用户清空队列
- **则**删除所有 QueueItem 记录

### 需求：Queue 页面 UI 结构

系统应根据数据状态动态显示内容。

#### 场景：有队列数据且有未播放 episodes

- **当**队列中有数据且存在未播放的 episodes
- **则**页面显示：
  1. Text("队列") 标题
  2. 队列列表（从 queue 数据库查询并通过 episodeId 获取 episode 信息展示）
  3. _buildDivider() 分割线
  4. Text("继续播放") 标题
  5. 未播放 episodes 列表

#### 场景：仅有队列数据

- **当**队列中有数据但没有未播放的 episodes
- **则**页面显示：
  1. Text("队列") 标题
  2. 队列列表

#### 场景：仅有未播放 episodes

- **当**队列为空但存在未播放的 episodes
- **则**页面显示：
  1. Text("继续播放") 标题
  2. 未播放 episodes 列表

#### 场景：空状态

- **当**队列和未播放 episodes 都为空
- **则**显示 QueueEmptyPage 空状态页面

#### 场景：分割线组件

- **当**渲染分割线
- **则**显示高度为 0.5、颜色为 Color(0xFFE0E0E0) 的 Container

```dart
Widget _buildDivider() {
  return Container(height: 0.5, color: const Color(0xFFE0E0E0));
}
```

## 修改的需求

### 需求：现有 Queue 页面

修改现有的 Queue 页面，从单一列表改为双区域布局。

- **之前**：仅显示未播放 episodes 列表或空状态
- **之后**：根据数据显示队列区域 + 未播放区域 + 空状态

## 移除的需求

无
