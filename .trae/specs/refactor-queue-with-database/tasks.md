# 任务列表

- [ ] 任务 1：创建 Queue 数据模型
  - [ ] 子任务 1.1：在 lib/data/models/ 创建 queue_model.dart（包含 id、episodeId、position、addedAt 字段）
  - [ ] 子任务 1.2：运行 build_runner 生成 .g.dart 文件
  - [ ] 子任务 1.3：在 isar_collections.dart 中注册 QueueItem collection

- [ ] 任务 2：实现队列数据访问层
  - [ ] 子任务 2.1：创建 LocalQueueDataSource（lib/data/datasources/）
  - [ ] 子任务 2.2：实现 getAll() 方法（按 position 排序）
  - [ ] 子任务 2.3：实现 addToQueue(episodeId) 方法
  - [ ] 子任务 2.4：实现 removeFromQueue(id) 方法（更新 position）
  - [ ] 子任务 2.5：实现 clearQueue() 方法

- [ ] 任务 3：实现队列仓库层
  - [ ] 子任务 3.1：创建 QueueRepository 接口（lib/data/repositories/ 或 domain 层）
  - [ ] 子任务 3.2：创建 QueueRepositoryImpl 实现类
  - [ ] 子任务 3.3：实现所有仓库方法

- [ ] 任务 4：实现队列 UseCase
  - [ ] 子任务 4.1：创建 GetQueueUseCase（获取队列并关联 Episode 信息）
  - [ ] 子任务 4.2：创建 AddToQueueUseCase
  - [ ] 子任务 4.3：创建 RemoveFromQueueUseCase
  - [ ] 子任务 4.4：创建 ClearQueueUseCase

- [ ] 任务 5：创建 Riverpod Providers
  - [ ] 子任务 5.1：创建 QueueNotifier 管理队列状态
  - [ ] 子任务 5.2：创建 queueProvider、queueItemsProvider
  - [ ] 子任务 5.3：实现队列状态变化监听和刷新

- [ ] 任务 6：重构 Queue 页面 UI
  - [ ] 子任务 6.1：重构 queue.dart，实现条件渲染逻辑
  - [ ] 子任务 6.2：实现 _buildDivider() 分割线组件
  - [ ] 子任务 6.3：实现队列区域展示（显示"队列"标题 + 队列列表）
  - [ ] 子任务 6.4：实现未播放 episodes 区域展示（显示"继续播放"标题 + 列表）
  - [ ] 子任务 6.5：处理空状态展示（复用现有 QueueEmptyPage）

## 任务依赖关系

- [任务 2] 依赖于 [任务 1]
- [任务 3] 依赖于 [任务 2]
- [任务 4] 依赖于 [任务 3]
- [任务 5] 依赖于 [任务 4]
- [任务 6] 依赖于 [任务 5, 任务 1]
