# 检查清单

## 队列数据模型
- [ ] QueueItem 实体类已创建（Domain 层）
- [ ] QueueItem 模型类已创建（Data 层）
- [ ] Isar collection 已配置
- [ ] 索引已配置（position、addedAt）
- [ ] 模型包含所有必需字段

## 队列数据源
- [ ] LocalQueueDataSource 已创建
- [ ] 添加到队列方法正常工作
- [ ] 从队列移除方法正常工作
- [ ] 重新排序方法正常工作
- [ ] 清空队列方法正常工作
- [ ] 获取队列列表方法正常工作

## 队列仓库
- [ ] QueueRepository 接口已创建
- [ ] 仓库方法已定义
- [ ] QueueRepositoryImpl 已创建
- [ ] 仓库方法已实现

## 队列用例
- [ ] AddToQueueUseCase 已创建
- [ ] RemoveFromQueueUseCase 已创建
- [ ] ReorderQueueUseCase 已创建
- [ ] ClearQueueUseCase 已创建
- [ ] GetQueueUseCase 已创建
- [ ] PlayNextInQueueUseCase 已创建

## Riverpod Providers
- [ ] QueueNotifier 已创建
- [ ] queueProvider 已创建
- [ ] 队列状态管理正常工作
- [ ] 队列变化流正常工作

## 队列页面
- [ ] UpNextQueuePage 已更新（使用真实数据）
- [ ] QueueProvider 连接正常
- [ ] 队列列表展示正常
- [ ] 队列项组件正常工作
- [ ] 拖放排序正常工作
- [ ] 空队列状态正常显示

## 播放功能集成
- [ ] 从队列播放逻辑正常工作
- [ ] 自动播放下一集逻辑正常工作
- [ ] PlaybackProvider 集成正常
- [ ] 播放后移除逻辑正常工作

## 队列设置
- [ ] 自动播放设置已添加
- [ ] 播放后移除设置已添加
- [ ] 设置持久化正常工作
- [ ] 设置应用正常工作

## 单元测试
- [ ] QueueItem 模型测试通过
- [ ] 队列数据源测试通过
- [ ] 队列仓库测试通过
- [ ] 队列用例测试通过

## 组件测试
- [ ] UpNextQueuePage 测试通过
- [ ] 队列项组件测试通过
- [ ] 拖放排序测试通过

## 集成测试
- [ ] 完整队列管理流程测试通过
- [ ] 队列播放流程测试通过
- [ ] 自动播放下一集测试通过
- [ ] 队列持久化测试通过
