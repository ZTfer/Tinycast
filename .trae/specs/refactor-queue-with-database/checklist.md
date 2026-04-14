# 检查清单

## Queue 数据模型

- [x] queue_model.dart 已创建并包含所有必需字段（id、episodeId、position、addedAt）
- [x] .g.dart 文件已生成
- [x] QueueItem 已在 isar_collections.dart 中注册
- [x] position 字段索引已配置

## 队列数据访问层

- [x] LocalQueueDataSource 已创建
- [x] getAll() 方法正常工作（按 position 升序返回）
- [x] addToQueue() 方法正常工作（自动分配 position）
- [x] removeFromQueue() 方法正常工作（正确更新剩余项的 position）
- [x] clearQueue() 方法正常工作

## 队列仓库层

- [x] QueueRepository 接口已定义
- [x] QueueRepositoryImpl 已实现所有方法
- [x] 仓库方法能正确操作数据库

## 队列 UseCase

- [x] GetQueueUseCase 能获取队列并关联 Episode 信息
- [x] AddToQueueUseCase 正常工作
- [x] RemoveFromQueueUseCase 正常工作
- [x] ClearQueueUseCase 正常工作

## Riverpod Providers

- [x] QueueNotifier 已创建
- [x] queueProvider 正常提供队列数据
- [x] 队列状态变化能正确触发 UI 更新

## Queue 页面 UI

- [x] queue.dart 已重构为双区域布局
- [x] _buildDivider() 组件实现正确（高度 0.5，颜色 0xFFE0E0E0）
- [x] 有队列数据时显示"队列"标题和队列列表
- [x] 有未播放 episodes 时显示"继续播放"标题和列表
- [x] 队列和未播放都存在时，中间显示分割线
- [x] 队列和未播放都为空时显示 QueueEmptyPage
- [x] 队列列表项能正确展示 episode 信息（通过 episodeId 查询）
- [x] 未播放列表项功能正常（复用现有逻辑）

## 编译验证

- [x] 项目能成功编译（flutter analyze 无错误）
- [x] 无类型错误

## 额外修复

- [x] IsarService.open() 已注册 QueueSchema（运行时必须）
