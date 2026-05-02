# iTunes 搜索集成与 Apple Podcast ID 规范

## Why

当用户订阅新播客时，需要能够异步搜索 iTunes 播客数据库，获取 Apple Podcast ID 以实现跨区播客合并和统一识别。同时需要在 Podcast 和 Episode 数据模型中添加 iTunes 相关字段（Apple ID、封面图地址），建立与苹果播客生态的对应关系，并采用 XML 库直接解析 RSS 以获得更灵活的数据掌控能力。

## What Changes

- **新增 iTunes 搜索服务**: 实现异步搜索 `https://itunes.apple.com/search` 接口，支持 US/CN 区域降级搜索
- **添加 Podcast 模型字段**: 增加 `appleId` (iTunes ID) 和 `itunesArtworkUrl` (iTunes 封面图) 字段
- **添加 Episode 模型字段**: 增加 `appleId` 和 `itunesArtworkUrl` 字段以保持与苹果的对应关系
- **数据库迁移**: 更新 Isar 数据库 schema 以支持新字段
- **集成搜索流程**: 在订阅播客时异步触发 iTunes 搜索并存储结果
- **RSS 解析升级**: 使用 XML 库直接解析 RSS，提取完整的 iTunes 命名空间字段
- **播客合并逻辑**: 基于 websiteUrl 或 feedUrl 实现跨区同一播客识别与合并显示

## Impact

- **受影响的数据模型**: Podcast、Episode 实体与 Isar 模型
- **受影响的代码文件**:
  - `lib/domain/entities/podcast.dart`
  - `lib/domain/entities/episode.dart`
  - `lib/data/models/podcast_model.dart`
  - `lib/data/models/episode_model.dart`
- **新增的代码文件**:
  - `lib/data/services/itunes_search_service.dart` (iTunes 搜索服务)
- **受影响的服务**:
  - `lib/data/services/rss_parser_service.dart` (升级使用 XML 解析)
  - `lib/data/datasources/remote_podcast_datasource.dart` (集成 iTunes 搜索)
- **受影响的 UI**:
  - 订阅搜索结果展示可能需要显示 iTunes 封面图
- **受影响的数据库**: Isar 数据库需要迁移添加新字段

## ADDED Requirements

### Requirement: iTunes 搜索服务

系统 SHALL 提供异步搜索 iTunes 播客数据库的能力，支持多区域降级搜索策略。

#### Scenario: 美国区搜索成功
- **WHEN** 用户订阅新播客
- **THEN** 系统异步请求 `https://itunes.apple.com/search?term=播客标题&entity=podcast&limit=5&country=us`
- **AND** 如果找到结果，提取 `collectionId` 作为 Apple ID，`artworkUrl600` 作为封面图地址

#### Scenario: 美国区搜索失败降级到中国
- **WHEN** 美国区搜索返回空结果或网络错误
- **THEN** 系统自动重试请求 `https://itunes.apple.com/search?term=播客标题&entity=podcast&limit=5&country=cn`
- **AND** 如果中国区有结果，使用该结果的 Apple ID 和封面图

#### Scenario: 两个区域都搜索不到
- **WHEN** 美国和中国区域都搜索不到结果
- **THEN** Apple ID 字段保持为 null
- **AND** 不影响正常订阅流程，播客仍可成功订阅

### Requirement: Podcast 模型添加 Apple ID 字段

Podcast 实体 SHALL 包含 `appleId` 和 `itunesArtworkUrl` 字段用于存储 iTunes 播客信息。

```dart
// Podcast 实体新增字段
final String? appleId;          // Apple Podcast ID (如 "id111")
final String? itunesArtworkUrl; // iTunes 封面图 URL (600x600)
```

#### Scenario: 保存到数据库
- **WHEN** iTunes 搜索到结果
- **THEN** `appleId` 存储为字符串类型（保留 "id" 前缀）
- **AND** `itunesArtworkUrl` 存储完整 URL 地址

#### Scenario: 搜索不到结果
- **WHEN** iTunes 搜索无结果
- **THEN** `appleId` 为 null
- **AND** `itunesArtworkUrl` 为 null
- **AND** 播客其他字段正常保存

### Requirement: Episode 模型添加 Apple ID 字段

Episode 实体 SHALL 包含 `appleId` 和 `itunesArtworkUrl` 字段以保持与苹果播客的对应关系。

```dart
// Episode 实体新增字段
final String? appleId;          // Apple Podcast Episode ID
final String? itunesArtworkUrl; // iTunes Episode 封面图 URL
```

#### Scenario: 从 RSS 解析 Episode iTunes 信息
- **WHEN** 解析 RSS feed 中的 episode 条目
- **THEN** 提取 `<itunes:id>` 如果存在
- **AND** 提取 episode 级别的 artwork URL

### Requirement: 播客合并逻辑

系统 SHALL 基于 feedUrl 或 websiteUrl 识别跨区同一播客并进行合并显示。

#### Scenario: 不同区域的同一播客
- **WHEN** 用户 A 订阅美区 RSS (Apple ID: id111)
- **AND** 用户 B 订阅中区 RSS (Apple ID: id222)
- **AND** 两者的 websiteUrl 域名一致或 feedUrl 相同
- **THEN** 系统标记为"同一组"
- **AND** 前端展示时合并显示为一个播客

#### Scenario: 合并策略实现
- **WHEN** 检测到多个播客具有相同的 canonical 标识
- **THEN** 保留第一个订阅的记录作为主记录
- **AND** 其他记录标记为关联记录
- **AND** 在前端只显示主记录

### Requirement: XML 库直接解析 RSS

系统 SHALL 使用 XML 库直接解析 RSS feed 以完全掌控数据提取过程。

#### Scenario: 解析标准 RSS 2.0
- **WHEN** 获取到 RSS XML 内容
- **THEN** 使用 XML 库解析 document
- **AND** 提取 `<channel>` 下的播客元数据
- **AND** 提取 `<item>` 下的 episode 数据
- **AND** 处理 iTunes 命名空间字段 (`<itunes:*>`)

#### Scenario: 处理异常 RSS 源
- **WHEN** RSS 源格式不标准或有异常
- **THEN** 使用 try-catch 保护解析流程
- **AND** 跳过无法解析的字段而非整体失败
- **AND** 记录警告日志便于调试

## MODIFIED Requirements

### Requirement: Podcast 实体 (现有)

Podcast 实体 SHALL 扩展包含 iTunes 相关字段:

**现有字段保持不变**, 新增:
- `appleId`: String? - Apple Podcast Collection ID
- `itunesArtworkUrl`: String? - iTunes 600x600 封面图 URL

### Requirement: Episode 实体 (现有)

Episode 实体 SHALL 扩展包含 iTunes 相关字段:

**现有字段保持不变**, 新增:
- `appleId`: String? - Apple Podcast Episode ID
- `itunesArtworkUrl`: String? - iTunes Episode 封面图 URL

### Requirement: 播客订阅流程 (现有)

订阅流程 SHALL 在成功解析 RSS 后异步触发 iTunes 搜索:

1. 用户输入 RSS URL 或关键词
2. 解析 RSS 获取播客基本信息
3. **异步发起 iTunes 搜索** (不阻塞订阅流程)
4. 如果搜索到结果，更新播客的 Apple ID 和封面图
5. 保存播客到本地数据库

### Requirement: RSS 解析服务 (现有)

RssParserService SHALL 升级为使用 XML 库直接解析而非依赖 rss_dart 封装:

- 使用 `xml` 库解析 XML 文档
- 手动提取标准 RSS 字段
- 手动提取 iTunes 命名空间字段
- 保持向后兼容的返回结构

## REMOVED Requirements

无移除需求。

## Technical Notes

### iTunes Search API 格式

请求 URL:
```
https://itunes.apple.com/search?term={搜索词}&entity=podcast&limit=5&country={us|cn}
```

响应结构 (关键字段):
```json
{
  "resultCount": 1,
  "results": [
    {
      "collectionId": 1234567890,  // Apple Podcast ID
      "collectionName": "播客标题",
      "artworkUrl600": "https://is1-ssl.mzstatic.com/image/thumb/...",  // 600x600 封面图
      "feedUrl": "https://feeds.example.com/podcast.xml",  // RSS 源地址
      "website": "https://example.com",  // 官网地址
      "description": "播客描述"
    }
  ]
}
```

### 数据库迁移策略

由于使用 Isar 数据库，添加新字段需要:
1. 在 Podcast 和 Episode 模型中添加字段定义
2. 运行 `flutter pub run build_runner build` 重新生成 `.g.dart` 文件
3. Isar 会自动处理 schema 迁移 (新字段默认为 null)

### Canonical ID 设计

为了解决"同一播客不同区 ID 不同"的问题:
- 使用 `websiteUrl` 的域名作为主要合并依据
- 备选使用 `feedUrl` 的相似度匹配
- 在数据库中标记关联关系，前端合并展示
