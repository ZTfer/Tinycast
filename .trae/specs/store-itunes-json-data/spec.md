# iTunes JSON 数据存储与字段重命名规范

## Why

将 `appleId` 重命名为更准确的 `itunesId`，同时需要完整保存 iTunes Search API 返回的 JSON 数据到数据库，为后续功能（播客详情展示、iTunes 跳转等）提供完整数据支撑。

## What Changes

- **字段重命名**: `appleId` → `itunesId`（Podcast 和 Episode 实体/模型）
- **新增 Podcast 字段**: `itunesPrimaryGenreName`, `iTunesGenres`, `iTunesGenreIds`, `iTunesCollectionViewUrl`, `iTunesArtworkUrl600`, `iTunesCountry`, `iTunesReleaseDate`, `iTunesCollectionExplicitness`, `iTunesContentAdvisoryRating`
- **新增 Episode 字段**: `iTunesId`, `iTunesArtworkUrl600`, `iTunesReleaseDate`, `iTunesExplicitness`, `iTunesContentAdvisoryRating`
- **更新 iTunes 搜索服务**: 保存完整 JSON 结果到 SearchResult
- **更新订阅流程**: 异步搜索后将完整数据存储到数据库

## Impact

- **受影响的数据模型**: Podcast、Episode 实体与 Isar 模型
- **受影响的代码文件**:
  - `lib/domain/entities/podcast.dart`
  - `lib/domain/entities/episode.dart`
  - `lib/data/models/podcast_model.dart`
  - `lib/data/models/episode_model.dart`
  - `lib/data/services/itunes_search_service.dart`
  - `lib/data/datasources/remote_podcast_datasource.dart`
  - `lib/data/datasources/local_podcast_datasource.dart`
  - `lib/data/repositories/podcast_repository_impl.dart`
- **数据库迁移**: Isar 需要重新生成 `.g.dart` 文件

## ADDED Requirements

### Requirement: Podcast 添加 iTunes 完整字段

Podcast 实体 SHALL 包含以下 iTunes 相关字段：

| 字段名 | 类型 | 来源 JSON 字段 | 说明 |
|--------|------|---------------|------|
| `itunesId` | String? | `collectionId` | iTunes 播客 ID |
| `iTunesPrimaryGenreName` | String? | `primaryGenreName` | 主要流派名称 |
| `iTunesGenres` | List\<String\>? | `genres` | 流派列表 |
| `iTunesGenreIds` | List\<String\>? | `genreIds` | 流派 ID 列表 |
| `iTunesCollectionViewUrl` | String? | `collectionViewUrl` | iTunes 详情页链接 |
| `iTunesArtworkUrl600` | String? | `artworkUrl600` | 600x600 封面图 |
| `iTunesCountry` | String? | `country` | 国家代码 (如 "USA") |
| `iTunesReleaseDate` | DateTime? | `releaseDate` | 发布日期 |
| `iTunesCollectionExplicitness` | String? | `collectionExplicitness` | 播客成人内容标识 |
| `iTunesContentAdvisoryRating` | String? | `contentAdvisoryRating` | 内容分级评级 |

### Requirement: Episode 添加 iTunes 字段

Episode 实体 SHALL 包含以下 iTunes 相关字段：

| 字段名 | 类型 | 来源 JSON 字段 | 说明 |
|--------|------|---------------|------|
| `iTunesId` | String? | `trackId` | iTunes 单集 ID |
| `iTunesArtworkUrl600` | String? | `artworkUrl600` | 600x600 封面图 |
| `iTunesReleaseDate` | DateTime? | `releaseDate` | 发布日期 |
| `iTunesExplicitness` | String? | `trackExplicitness` | 单集成人内容标识 |
| `iTunesContentAdvisoryRating` | String? | `contentAdvisoryRating` | 内容分级评级 |

### Requirement: iTunes 搜索结果存储

ITunesSearchResult SHALL 包含完整 JSON 字段映射，并提供 `fromFullJson` 方法处理完整响应。

## MODIFIED Requirements

### Requirement: appleId 重命名为 itunesId

**Podcast 和 Episode 实体/模型中的 `appleId` 字段 SHALL 重命名为 `itunesId`**，以准确反映数据来源为 iTunes 而非 Apple 其他服务。

### Requirement: 订阅流程更新

订阅流程 SHALL 在 iTunes 搜索成功后，将完整的搜索结果数据存储到播客记录中，包括流派、发布日期、国家、分级等信息。

## REMOVED Requirements

**无** - 仅新增字段，不删除现有功能。
