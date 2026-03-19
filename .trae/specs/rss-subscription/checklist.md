# 检查清单

## 数据模型

- [x] Podcast 实体类已创建（Domain 层）
- [x] Podcast 模型类已创建（Data 层）
- [x] Episode 实体类已创建（Domain 层）
- [x] Episode 模型类已创建（Data 层）
- [x] 模型包含所有必需字段
- [x] 模型序列化和反序列化正常工作

## Isar 数据库配置

- [x] Podcast Isar collection 已创建
- [x] Episode Isar collection 已创建
- [x] 索引配置正确（title、rssUrl、lastUpdated）
- [x] 关联关系配置正确（Podcast -> Episode）
- [x] 数据库初始化成功

## RSS 解析器

- [x] RSS 解析服务类已创建
- [x] HTTP 请求功能正常工作（使用 dio）
- [x] XML 解析功能正常工作（使用 xml 包）
- [x] 播客元数据提取正确
- [x] 节目列表提取正确
- [x] 支持多种 RSS 格式（RSS 2.0、Atom 等）
- [x] 错误处理和重试逻辑正常工作

## 数据源

- [x] RemotePodcastDataSource 已创建
- [x] 从 RSS 获取播客数据的方法正常工作
- [x] LocalPodcastDataSource 已创建
- [x] 从数据库查询播客的方法正常工作
- [x] 保存播客到数据库的方法正常工作
- [x] 删除播客的方法正常工作
- [x] 检查重复订阅的方法正常工作

## 仓库

- [x] PodcastRepository 接口已创建（Domain 层）
- [x] 仓库方法已定义（subscribe、unsubscribe、getSubscribed、getById）
- [x] PodcastRepositoryImpl 已创建（Data 层）
- [x] 订阅逻辑正常工作（解析 RSS + 保存数据库）
- [x] 取消订阅逻辑正常工作
- [x] 查询已订阅播客列表正常工作
- [x] 根据 ID 查询播客正常工作

## 用例

- [x] SubscribePodcastUseCase 已创建
- [x] UnsubscribePodcastUseCase 已创建
- [x] GetSubscribedPodcastsUseCase 已创建
- [x] GetPodcastByIdUseCase 已创建
- [x] 输入验证正常工作

## Riverpod Providers

- [x] PodcastNotifier 已创建
- [x] podcastProvider 已创建
- [x] 订阅状态管理正常工作
- [x] 加载状态管理正常工作
- [x] 错误状态管理正常工作

## RSS 订阅界面

- [x] RssSubscriptionPage 已创建
- [x] RSS URL 输入框正常工作
- [x] 订阅按钮正常工作
- [x] URL 格式验证正常工作
- [x] 加载状态显示正常
- [x] 错误提示显示正常
- [x] 成功提示显示正常

## 播客列表页面

- [x] LibraryPage 已更新（使用真实数据）
- [x] PodcastProvider 连接正常
- [x] 播客列表展示正常
- [x] 播客卡片组件正常工作
- [x] 下拉刷新正常工作
- [x] 空状态处理正常

## 播客详情页面

- [x] PodcastDetailPage 已创建
- [x] 播客信息显示正常（封面、标题、作者、描述）
- [x] 节目列表显示正常
- [x] 节目列表项组件正常工作
- [x] 加载更多功能正常工作
- [x] 返回按钮正常工作

## 错误处理

- [x] 网络错误处理正常
- [x] 解析错误处理正常
- [x] 存储错误处理正常
- [x] Toast 提示正常工作
- [x] 错误对话框正常工作

## 文件存储服务

- [x] FileStorageService 已创建
- [x] 获取存储目录方法正常工作（使用 path_provider）
- [x] 临时缓存目录正确（temporaryDirectory）
- [x] 永久存储目录正确（applicationSupportDirectory）
- [x] 文件存在性检查方法正常工作
- [x] 删除文件方法正常工作
- [x] 获取文件大小方法正常工作
- [x] 路径拼接方法正常工作（使用 path.join）
- [x] 文件命名方法正常工作（EpisodeID.mp3 或 Hash(Url).mp3）
- [x] 数据库只存储相对路径或文件名

## 音频文件下载

- [x] AudioDownloadService 已创建
- [x] 音频下载方法正常工作（使用 dio）
- [x] 下载进度跟踪正常工作
- [x] 断点续传功能正常工作
- [x] 下载失败处理正常工作
- [x] 部分下载文件保存在 temporaryDirectory
- [x] 数据库中的下载状态更新正常
- [x] isDownloaded 和 downloadedPath 字段更新正常

## 图片缓存

- [x] ImageCacheService 已创建
- [x] 图片缓存检查方法正常工作
- [x] 图片下载和缓存方法正常工作
- [x] 图片缓存目录管理正常工作（applicationSupportDirectory/images）
- [x] 图片缓存清理方法正常工作
- [x] 使用 Hash(Url) 作为缓存文件名

## 缓存清理机制

- [x] CacheCleanupService 已创建
- [x] 手动清理缓存方法正常工作
- [x] 自动清理缓存方法正常工作（磁盘空间不足时）
- [x] 取消订阅时清理文件方法正常工作
- [x] 缓存大小计算方法正常工作
- [x] 清理策略实现正常（清理所有、清理已播放、保留最近 N 集）
- [x] 删除物理文件后更新数据库状态正常

## 文件管理界面

- [x] CacheSettingsPage 已创建
- [x] 缓存大小显示正常
- [x] 清理缓存按钮正常工作
- [x] 清理选项选择正常工作
- [x] 清理进度显示正常
- [x] 清理结果反馈正常

## 平台权限配置

- [x] iOS/macOS Entitlements 配置正确（如需要）
- [x] Android 权限配置正确（如需要）
- [x] Linux Snap/Flatpak 权限配置正确（如需要）
- [x] Windows AppData 目录访问验证正常

## 文件存储测试

- [ ] FileStorageService 测试通过
- [ ] AudioDownloadService 测试通过
- [ ] ImageCacheService 测试通过
- [ ] CacheCleanupService 测试通过
- [ ] 文件路径拼接测试通过
- [ ] 文件命名逻辑测试通过

## 文件存储集成测试

- [ ] 完整下载流程测试通过
- [ ] 断点续传流程测试通过
- [ ] 缓存清理流程测试通过
- [ ] 取消订阅时文件清理测试通过
- [ ] 跨平台文件存储测试通过

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
