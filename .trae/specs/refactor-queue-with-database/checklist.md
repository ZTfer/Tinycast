# 检查清单

## Queue 数据模型

- [ ] queue_model.dart 已创建并包含所有必需字段（id、episodeId、position、addedAt）
- [ ] .g.dart 文件已生成
- [ ] QueueItem 已在 isar_collections.dart 中注册
- [ ] position 字段索引已配置

## 队列数据访问层

- [ ] LocalQueueDataSource 已创建
- [ ] getAll() 方法正常工作（按 position 升序返回）
- [ ] addToQueue() 方法正常工作（自动分配 position）
- [ ] removeFromQueue() 方法正常工作（正确更新剩余项的 position）
- [ ] clearQueue() 方法正常工作

## 队列仓库层

- [ ] QueueRepository 接口已定义
- [ ] QueueRepositoryImpl 已实现所有方法
- [ ] 仓库方法能正确操作数据库

## 队列 UseCase

- [ ] GetQueueUseCase 能获取队列并关联 Episode 信息
- [ ] AddToQueueUseCase 正常工作
- [ ] RemoveFromQueueUseCase 正常工作
- [ ] ClearQueueUseCase 正常工作

## Riverpod Providers

- [ ] QueueNotifier 已创建
- [ ] queueProvider 正常提供队列数据
- [ ] 队列状态变化能正确触发 UI 更新

## Queue 页面 UI

- [ ] queue.dart 已重构为双区域布局
- [ ] _buildDivider() 组件实现正确（高度 0.5，颜色 0xFFE0E0E0）
- [ ] 有队列数据时显示"队列"标题和队列列表
- [ ] 有未播放 episodes 时显示"继续播放"标题和列表
- [ ] 队列和未播放都存在时，中间显示分割线
- [ ] 队列和未播放都为空时显示 QueueEmptyPage
- [ ] 队列列表项能正确展示 episode 信息（通过 episodeId 查询）
- [ ] 未播放列表项功能正常（复用现有逻辑）

## 编译验证

- [ ] 项目能成功编译（flutter analyze 无错误）
- [ ] 无类型错误
