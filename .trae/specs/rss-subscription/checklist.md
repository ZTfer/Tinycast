# 检查清单

## 数据模型

- [ ] Podcast 实体类已创建（Domain 层）
- [ ] Podcast 模型类已创建（Data 层）
- [ ] Episode 实体类已创建（Domain 层）
- [ ] Episode 模型类已创建（Data 层）
- [ ] 模型包含所有必需字段
- [ ] 模型序列化和反序列化正常工作

## Isar 数据库配置

- [ ] Podcast Isar collection 已创建
- [ ] Episode Isar collection 已创建
- [ ] 索引配置正确（title、rssUrl、lastUpdated）
- [ ] 关联关系配置正确（Podcast -> Episode）
- [ ] 数据库初始化成功

## RSS 解析器

- [ ] RSS 解析服务类已创建
- [ ] HTTP 请求功能正常工作（使用 dio）
- [ ] XML 解析功能正常工作（使用 xml 包）
- [ ] 播客元数据提取正确
- [ ] 节目列表提取正确
- [ ] 支持多种 RSS 格式（RSS 2.0、Atom 等）
- [ ] 错误处理和重试逻辑正常工作

## 数据源

- [ ] RemotePodcastDataSource 已创建
- [ ] 从 RSS 获取播客数据的方法正常工作
- [ ] LocalPodcastDataSource 已创建
- [ ] 从数据库查询播客的方法正常工作
- [ ] 保存播客到数据库的方法正常工作
- [ ] 删除播客的方法正常工作
- [ ] 检查重复订阅的方法正常工作

## 仓库

- [ ] PodcastRepository 接口已创建（Domain 层）
- [ ] 仓库方法已定义（subscribe、unsubscribe、getSubscribed、getById）
- [ ] PodcastRepositoryImpl 已创建（Data 层）
- [ ] 订阅逻辑正常工作（解析 RSS + 保存数据库）
- [ ] 取消订阅逻辑正常工作
- [ ] 查询已订阅播客列表正常工作
- [ ] 根据 ID 查询播客正常工作

## 用例

- [ ] SubscribePodcastUseCase 已创建
- [ ] UnsubscribePodcastUseCase 已创建
- [ ] GetSubscribedPodcastsUseCase 已创建
- [ ] GetPodcastByIdUseCase 已创建
- [ ] 输入验证正常工作

## Riverpod Providers

- [ ] PodcastNotifier 已创建
- [ ] podcastProvider 已创建
- [ ] 订阅状态管理正常工作
- [ ] 加载状态管理正常工作
- [ ] 错误状态管理正常工作

## RSS 订阅界面

- [ ] RssSubscriptionPage 已创建
- [ ] RSS URL 输入框正常工作
- [ ] 订阅按钮正常工作
- [ ] URL 格式验证正常工作
- [ ] 加载状态显示正常
- [ ] 错误提示显示正常
- [ ] 成功提示显示正常

## 播客列表页面

- [ ] LibraryPage 已更新（使用真实数据）
- [ ] PodcastProvider 连接正常
- [ ] 播客列表展示正常
- [ ] 播客卡片组件正常工作
- [ ] 下拉刷新正常工作
- [ ] 空状态处理正常

## 播客详情页面

- [ ] PodcastDetailPage 已创建
- [ ] 播客信息显示正常（封面、标题、作者、描述）
- [ ] 节目列表显示正常
- [ ] 节目列表项组件正常工作
- [ ] 加载更多功能正常工作
- [ ] 返回按钮正常工作

## 错误处理

- [ ] 网络错误处理正常
- [ ] 解析错误处理正常
- [ ] 存储错误处理正常
- [ ] Toast 提示正常工作
- [ ] 错误对话框正常工作

## 单元测试

- [ ] Podcast 模型测试通过
- [ ] Episode 模型测试通过
- [ ] RSS 解析器测试通过
- [ ] 数据源测试通过
- [ ] 仓库测试通过
- [ ] 用例测试通过

## 组件测试

- [ ] RssSubscriptionPage 测试通过
- [ ] LibraryPage 测试通过
- [ ] PodcastDetailPage 测试通过
- [ ] 播客卡片组件测试通过

## 集成测试

- [ ] 完整订阅流程测试通过
- [ ] 取消订阅流程测试通过
- [ ] 播客列表展示测试通过
- [ ] 播客详情展示测试通过
