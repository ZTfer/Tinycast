# Tasks

- [ ] Task 1: 添加 Podcast 和 Episode 模型的 iTunes 字段
  - [ ] SubTask 1.1: 在 `lib/domain/entities/podcast.dart` 添加 `appleId` 和 `itunesArtworkUrl` 字段
  - [ ] SubTask 1.2: 在 `lib/domain/entities/episode.dart` 添加 `appleId` 和 `itunesArtworkUrl` 字段
  - [ ] SubTask 1.3: 在 `lib/data/models/podcast_model.dart` 添加对应 Isar 字段定义
  - [ ] SubTask 1.4: 在 `lib/data/models/episode_model.dart` 添加对应 Isar 字段定义
  - [ ] SubTask 1.5: 运行 `flutter pub run build_runner build` 重新生成 `.g.dart` 文件

- [ ] Task 2: 创建 iTunes 搜索服务
  - [ ] SubTask 2.1: 创建 `lib/data/services/itunes_search_service.dart` 文件
  - [ ] SubTask 2.2: 实现 `searchPodcastOnITunes(term, {country, limit})` 方法
  - [ ] SubTask 2.3: 实现 US -> CN 区域降级搜索逻辑
  - [ ] SubTask 2.4: 解析 JSON 响应，提取 `collectionId`、`artworkUrl600`、`feedUrl`、`website`
  - [ ] SubTask 2.5: 添加错误处理和日志记录

- [ ] Task 3: 升级 RSS 解析服务使用 XML 库
  - [ ] SubTask 3.1: 重构 `_extractPodcastFromRss` 方法使用 XML 直接解析
  - [ ] SubTask 3.2: 重构 `_extractEpisodesFromRss` 方法使用 XML 直接解析
  - [ ] SubTask 3.3: 提取 iTunes 命名空间字段 (`<itunes:*>)
  - [ ] SubTask 3.4: 处理 episode 级别的 `itunes:id` 和 artwork
  - [ ] SubTask 3.5: 添加异常处理和容错逻辑
  - [ ] SubTask 3.6: 验证解析结果与现有返回结构兼容

- [ ] Task 4: 集成 iTunes 搜索到订阅流程
  - [ ] SubTask 4.1: 在 `RemotePodcastDataSource.getPodcastFromRss` 中调用 iTunes 搜索
  - [ ] SubTask 4.2: 实现异步搜索不阻塞订阅流程 (使用 `unawaited` 或 `Future.microtask`)
  - [ ] SubTask 4.3: 搜索到结果后更新播客的 `appleId` 和 `itunesArtworkUrl`
  - [ ] SubTask 4.4: 更新数据库中的播客记录

- [ ] Task 5: 实现播客合并逻辑
  - [ ] SubTask 5.1: 创建 `PodcastMergeService` 服务类
  - [ ] SubTask 5.2: 实现基于 `websiteUrl` 域名的匹配算法
  - [ ] SubTask 5.3: 实现基于 `feedUrl` 的相似度匹配作为备选
  - [ ] SubTask 5.4: 在数据库中标记关联关系
  - [ ] SubTask 5.5: 更新获取播客列表的逻辑，合并显示同一组播客

- [ ] Task 6: 验证和测试
  - [ ] SubTask 6.1: 测试 iTunes 搜索 US 区域成功场景
  - [ ] SubTask 6.2: 测试 US 失败降级到 CN 场景
  - [ ] SubTask 6.3: 测试两个区域都搜索不到场景 (字段为 null)
  - [ ] SubTask 6.4: 测试 RSS 解析包含 iTunes 字段
  - [ ] SubTask 6.5: 测试播客合并逻辑正确性
  - [ ] SubTask 6.6: 运行 `flutter analyze` 检查代码质量

# Task Dependencies

- [Task 2] depends on [Task 1] (需要模型字段定义完成后才能创建搜索服务)
- [Task 3] depends on [Task 1] (需要模型字段定义完成后才能更新解析逻辑)
- [Task 4] depends on [Task 2, Task 3] (需要搜索服务和解析服务都完成后才能集成)
- [Task 5] depends on [Task 1, Task 4] (需要模型字段和 iTunes ID 填充后才能实现合并)
- [Task 6] depends on [Task 4, Task 5] (需要所有功能完成后才能进行测试验证)
