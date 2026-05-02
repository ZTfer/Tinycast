# Checklist

## 数据模型
- [ ] Podcast 实体包含 `appleId` (String?) 和 `itunesArtworkUrl` (String?) 字段
- [ ] Episode 实体包含 `appleId` (String?) 和 `itunesArtworkUrl` (String?) 字段
- [ ] Podcast Isar 模型正确添加新字段并标记为 nullable
- [ ] Episode Isar 模型正确添加新字段并标记为 nullable
- [ ] `.g.dart` 文件已重新生成且无编译错误

## iTunes 搜索服务
- [ ] `ITunesSearchService` 类已创建
- [ ] `searchPodcastOnITunes(term, {country, limit})` 方法实现正确
- [ ] 请求 URL 格式符合 `https://itunes.apple.com/search?term={term}&entity=podcast&limit={limit}&country={country}`
- [ ] US 区域优先搜索逻辑已实现
- [ ] US 失败后自动降级到 CN 区域的逻辑已实现
- [ ] JSON 响应解析正确提取 `collectionId`、`artworkUrl600`、`feedUrl`、`website`
- [ ] 网络错误和空结果处理正确
- [ ] 日志记录完整 (搜索开始、结果、错误)

## RSS 解析升级
- [ ] `RssParserService` 使用 `xml` 库直接解析 XML
- [ ] 正确提取 `<channel>` 下的播客元数据 (title, description, author, etc.)
- [ ] 正确提取 `<itunes:*>` 命名空间字段 (subtitle, summary, image, explicit, etc.)
- [ ] 正确解析 `<item>` 下的 episode 数据
- [ ] Episode 级别的 `<itunes:id>` 和 artwork 已处理
- [ ] 异常 RSS 源有容错处理 (try-catch, 跳过失败字段)
- [ ] 返回结构与现有接口兼容 (Map<String, dynamic> with 'podcast' and 'episodes')

## 订阅流程集成
- [ ] 订阅播客时异步触发 iTunes 搜索 (不阻塞主流程)
- [ ] 使用 `unawaited` 或 `Future.microtask` 实现异步
- [ ] 搜索到结果后正确更新 Podcast 的 `appleId` 和 `itunesArtworkUrl`
- [ ] 更新后的播客数据正确保存到 Isar 数据库
- [ ] 搜索失败不影响播客正常订阅

## 播客合并逻辑
- [ ] `PodcastMergeService` 服务类已创建
- [ ] 基于 `websiteUrl` 域名的匹配算法正确实现
- [ ] 基于 `feedUrl` 的相似度匹配作为备选已实现
- [ ] 数据库中标记关联关系的逻辑正确
- [ ] 获取播客列表时合并显示同一组播客
- [ ] 合并后只显示主记录，关联记录不重复显示

## 代码质量
- [ ] `flutter analyze` 通过无错误
- [ ] 代码遵循项目现有命名和格式规范
- [ ] 所有新增字段在构造函数中有正确的参数
- [ ] 日志记录使用项目现有的 `Logger` 工具
- [ ] 错误处理使用项目现有的 `AppException` 体系

## 功能验证
- [ ] iTunes 搜索 US 区域成功场景测试通过
- [ ] iTunes 搜索 US 失败降级 CN 场景测试通过
- [ ] iTunes 搜索两区域都失败场景测试通过 (字段为 null)
- [ ] RSS 解析包含 iTunes 字段测试通过
- [ ] 播客合并逻辑测试通过
- [ ] 订阅流程无阻塞异步搜索验证通过
