# 检查清单

## 下载管理器
- [ ] DownloadManager 类已创建
- [ ] 下载任务队列已实现
- [ ] 并发下载控制已实现
- [ ] 下载优先级管理已实现

## 下载功能
- [ ] dio 下载方法正常工作
- [ ] 下载进度跟踪正常工作
- [ ] 下载速度计算正常工作
- [ ] 剩余时间估算正常工作
- [ ] 断点续传正常工作

## 文件存储管理
- [ ] path_provider 集成正常
- [ ] 存储路径获取正常
- [ ] 下载目录结构已创建
- [ ] 文件保存方法正常工作
- [ ] 文件删除方法正常工作
- [ ] 不同平台路径差异已处理

## 下载控制
- [ ] 暂停下载方法正常工作
- [ ] 恢复下载方法正常工作
- [ ] 取消下载方法正常工作
- [ ] 批量操作正常工作

## 下载状态持久化
- [ ] DownloadTask 模型已创建
- [ ] DownloadTask Isar collection 已创建
- [ ] 保存下载状态方法正常工作
- [ ] 加载下载状态方法正常工作
- [ ] 恢复未完成下载正常工作

## 自动下载
- [ ] AutoDownloadService 已创建
- [ ] 新节目检测正常工作
- [ ] 下载设置检查正常工作
- [ ] 自动下载逻辑正常工作

## 数据源和仓库
- [ ] DownloadDataSource 已创建
- [ ] 下载相关方法已实现
- [ ] DownloadRepository 接口已创建
- [ ] DownloadRepositoryImpl 已创建
- [ ] 仓库方法已实现

## 用例
- [ ] DownloadEpisodeUseCase 已创建
- [ ] PauseDownloadUseCase 已创建
- [ ] ResumeDownloadUseCase 已创建
- [ ] CancelDownloadUseCase 已创建
- [ ] DeleteDownloadUseCase 已创建

## Riverpod Providers
- [ ] DownloadNotifier 已创建
- [ ] downloadProvider 已创建
- [ ] 下载状态管理正常工作
- [ ] 下载进度流正常工作

## 下载页面
- [ ] DownloadsPage 已更新（使用真实数据）
- [ ] DownloadProvider 连接正常
- [ ] 下载列表展示正常
- [ ] 下载项组件正常工作
- [ ] 下载进度显示正常
- [ ] 下载控制按钮正常工作

## 错误处理
- [ ] 网络错误处理正常
- [ ] 存储错误处理正常
- [ ] 文件错误处理正常
- [ ] 错误提示显示正常
- [ ] 重试机制正常工作

## 单元测试
- [ ] DownloadManager 测试通过
- [ ] 下载功能测试通过
- [ ] 文件存储管理测试通过
- [ ] 下载控制测试通过
- [ ] 数据源和仓库测试通过

## 组件测试
- [ ] DownloadsPage 测试通过
- [ ] 下载项组件测试通过
- [ ] 下载进度显示测试通过

## 集成测试
- [ ] 完整下载流程测试通过
- [ ] 暂停/恢复下载测试通过
- [ ] 取消下载测试通过
- [ ] 自动下载测试通过
