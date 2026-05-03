# TinyCast 数据库技术文档

## 1. 概览

TinyCast 使用 **Isar** 作为本地嵌入式 NoSQL 数据库，存储播客订阅、剧集、收藏、播放历史、队列和应用设置等数据。Isar 是 Flutter 生态中高性能的本地数据库，支持异步操作、类型安全和复杂的查询。

### 1.1 技术栈

| 组件 | 值 |
|------|------|
| 数据库 | Isar (isar_community) |
| 存储引擎 | NoSQL 嵌入式文档数据库 |
| 数据库文件 | `<ApplicationDocumentsDirectory>/tinycast.isar` |
| 版本 | 1 |
| Schema 代码生成 | `build_runner` (dart run build_runner build) |
| 数据库 Inspector | 已启用 (`inspector: true`) |

### 1.2 数据库初始化

```dart
// lib/data/database/isar_service.dart
class IsarService {
  static const String _databaseName = 'tinycast';
  static const int _currentVersion = 1;
  Isar? _isar;
  bool _isInitialized = false;
  
  Future<void> open({List<CollectionSchema>? schemas}) async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        PodcastSchema, EpisodeSchema, SearchHistoryModelSchema,
        FavoriteSchema, PlayHistorySchema, QueueSchema, AppSettingsModelSchema
      ],
      directory: dir.path,
      name: _databaseName,
      inspector: true,
    );
    _isInitialized = true;
  }
}
```

### 1.3 注册的 Collections

| 集合名称 | 对应 Model | 用途 |
|----------|-----------|------|
| podcasts | Podcast | 播客元数据（标题、描述、封面等） |
| episodes | Episode | 剧集元数据（音频 URL、时长、播放状态等） |
| searchHistoryModels | SearchHistoryModel | 搜索历史记录 |
| favorites | Favorite | 收藏记录 |
| playHistorys | PlayHistory | 播放历史记录 |
| queues | Queue | 待播放队列 |
| appSettingsModels | AppSettingsModel | 应用全局设置（单例，id=0） |

---

## 2. Collection 详细定义

### 2.1 Podcast（播客）

**文件:** `lib/data/models/podcast_model.dart`

| 字段名 | 类型 | 索引 | 默认值 | 说明 |
|--------|------|------|--------|------|
| id | Id (int) | 主键 | Isar.autoIncrement | 自增主键 |
| title | String | - | - | 播客标题 |
| description | String | - | - | 播客描述 |
| link | String? | - | null | 播客官网链接 |
| author | String? | - | null | 播客作者 |
| email | String? | - | null | 联系邮箱 |
| copyright | String? | - | null | 版权信息 |
| subtitle | String? | - | null | 副标题 |
| summary | String? | - | null | 摘要 |
| explicit | String? | - | null | 是否包含成人内容 |
| category | String? | - | null | 分类 |
| imageUrl | String? | - | null | 封面图片 URL |
| itunesType | String? | - | null | iTunes 播客类型 |
| ownerName | String? | - | null | 所有者名称 |
| ownerEmail | String? | - | null | 所有者邮箱 |
| language | String? | - | null | 语言代码 |
| pubDate | DateTime? | - | null | 发布日期 |
| lastBuildDate | DateTime? | - | null | 最后构建日期 |
| generator | String? | - | null | RSS 生成器 |
| feedUrl | String? | - | null | RSS Feed URL |
| webUrl | String? | - | null | 网页 URL |
| itunesId | String? | - | null | Apple Podcasts ID（iTunes Search API collectionId） |
| itunesArtworkUrl600 | String? | - | null | 600x600 封面图 URL |
| itunesPrimaryGenreName | String? | - | null | 主分类名称 |
| itunesGenres | List\<String\>? | - | null | 全部分类列表 |
| itunesGenreIds | List\<String\>? | - | null | 分类 ID 列表 |
| itunesCollectionViewUrl | String? | - | null | Apple Podcasts 页面 URL |
| country | String? | - | null | iTunes 搜索国家代码 |
| itunesReleaseDate | DateTime? | - | null | iTunes 发布日期 |
| itunesCollectionExplicitness | String? | - | null | iTunes 内容分级 |
| itunesContentAdvisoryRating | String? | - | null | iTunes 内容评级 |
| artworkPath | String? | - | null | 本地封面图片路径 |
| isSubscribed | bool | - | false | 是否已订阅 |
| lastRefreshedAt | DateTime | - | DateTime.now() | 最后刷新时间 |
| createdAt | DateTime | - | DateTime.now() | 创建时间 |
| updatedAt | DateTime | - | DateTime.now() | 更新时间 |

**关联:** 1 对多 → Episode (podcastId)

---

### 2.2 Episode（剧集）

**文件:** `lib/data/models/episode_model.dart`

| 字段名 | 类型 | 索引 | 默认值 | 说明 |
|--------|------|------|--------|------|
| id | Id (int) | 主键 | Isar.autoIncrement | 自增主键 |
| podcastId | int | ✅ 有 | - | 所属播客 ID（外键关联） |
| title | String | - | - | 剧集标题 |
| description | String | - | - | 剧集描述 |
| link | String? | - | null | 剧集链接 |
| guid | String? | - | null | RSS GUID 唯一标识符 |
| author | String? | - | null | 剧集作者 |
| pubDate | DateTime | ✅ 有 | - | 发布日期（用于排序） |
| audioUrl | String | - | - | 音频文件 URL |
| audioType | String | - | - | 音频 MIME 类型 |
| duration | int? | - | null | 时长（秒） |
| artworkUrl | String? | - | null | 封面图片 URL |
| isExplicit | bool | - | - | 是否包含成人内容 |
| isPlayed | bool | - | - | 是否已播放 |
| isDownloaded | bool | - | - | 是否已下载 |
| downloadedPath | String? | - | null | 本地下载文件路径 |
| artworkPath | String? | - | null | 本地封面图片路径 |
| downloadProgress | double | - | - | 下载进度 (0.0-1.0) |
| playProgress | double | - | - | 播放进度 (0.0-1.0) |
| lastPlayedAt | DateTime? | - | null | 最后播放时间 |
| createdAt | DateTime | - | DateTime.now() | 创建时间 |
| updatedAt | DateTime | - | - | 更新时间 |
| itunesId | String? | - | null | iTunes 剧集 ID（用于多区域关联） |
| podcastITunesId | String? | - | null | 所属播客的 iTunes ID |
| itunesArtworkUrl | String? | - | null | iTunes 封面图 URL |
| itunesReleaseDate | DateTime? | - | null | iTunes 发布日期 |
| itunesExplicitness | String? | - | null | iTunes 内容分级 |
| itunesContentAdvisoryRating | String? | - | null | iTunes 内容评级 |

**关联:** 多对 1 ← Podcast (podcastId)

**关键查询模式:**
```dart
// 按播客查询剧集
isar.episodes.filter().podcastIdEqualTo(podcastId).findAll()

// 按发布日期排序
sortByPubDateDesc() / sortByPubDateAsc()
```

---

### 2.3 Favorite（收藏）

**文件:** `lib/data/models/favorite_model.dart`

| 字段名 | 类型 | 索引 | 默认值 | 说明 |
|--------|------|------|--------|------|
| id | Id (int) | 主键 | Isar.autoIncrement | 自增主键 |
| episodeId | int | ✅ 有 | - | 剧集 ID |
| episodeGuid | String? | - | null | 剧集 GUID（用于 fallback 关联） |
| episodeITunesId | String? | - | null | 剧集 iTunes ID（用于 fallback 关联） |
| createdAt | DateTime | - | DateTime.now() | 收藏时间 |

**Fallback 关联策略:** 查询收藏时按以下优先级匹配：
1. `episodeITunesId` 匹配（最稳定）
2. `episodeGuid` 匹配（RSS 标准标识）
3. `episodeId` 匹配（兼容旧数据）

---

### 2.4 Queue（待播放队列）

**文件:** `lib/data/models/queue_model.dart`

| 字段名 | 类型 | 索引 | 默认值 | 说明 |
|--------|------|------|--------|------|
| id | Id (int) | 主键 | Isar.autoIncrement | 自增主键 |
| episodeId | int | ✅ 有 | - | 剧集 ID |
| episodeGuid | String? | - | null | 剧集 GUID（用于 fallback 关联） |
| episodeITunesId | String? | - | null | 剧集 iTunes ID（用于 fallback 关联） |
| podcastId | int? | - | null | 所属播客 ID |
| podcastGuid | String? | - | null | 播客 GUID |
| podcastITunesId | String? | - | null | 播客 iTunes ID（用于 fallback 关联） |
| position | int | ✅ 有 | - | 队列位置（0 为最前） |
| addedAt | DateTime | - | DateTime.now() | 添加时间 |

**Fallback 关联策略:** 查询队列时按以下优先级匹配：
1. `podcastITunesId` + `episodeITunesId` 匹配
2. `podcastId` + `episodeGuid` 匹配
3. `episodeId` 匹配（兼容旧数据）

**关键查询模式:**
```dart
// 按位置排序
items.sort((a, b) => a.position.compareTo(b.position))

// 按播客批量移除
removeFromQueueByPodcast(podcastId, podcastITunesId: ...)
```

---

### 2.5 PlayHistory（播放历史）

**文件:** `lib/data/models/play_history_model.dart`

| 字段名 | 类型 | 索引 | 默认值 | 说明 |
|--------|------|------|--------|------|
| id | Id (int) | 主键 | Isar.autoIncrement | 自增主键 |
| episodeId | int | ✅ 有 | - | 剧集 ID |
| episodeGuid | String? | - | null | 剧集 GUID（用于 fallback 关联） |
| episodeITunesId | String? | - | null | 剧集 iTunes ID（用于 fallback 关联） |
| podcastId | int | ✅ 有 | - | 播客 ID |
| podcastGuid | String? | - | null | 播客 GUID |
| podcastITunesId | String? | - | null | 播客 iTunes ID |
| title | String | - | - | 剧集标题（快照） |
| description | String? | - | null | 剧集描述（快照） |
| artworkUrl | String? | - | null | 封面图 URL（快照） |
| lastPlayedPositionMs | int | - | 0 | 最后播放位置（毫秒） |
| isPlayed | bool | - | false | 是否已播放完成 |
| playedDuration | int | - | 0 | 已播放时长（毫秒） |
| status | PlayHistoryStatus | - | playing | 播放状态枚举 |
| lastUpdateTime | DateTime | ✅ 有 | - | 最后更新时间 |
| createdAt | DateTime | - | DateTime.now() | 创建时间 |
| isDeleted | bool | - | false | 软删除标记 |

**枚举值:**
```dart
enum PlayHistoryStatus { playing, completed, skipped }
```

**Fallback 关联策略:** 查询播放历史时按以下优先级匹配：
1. `episodeITunesId` 匹配
2. `episodeGuid` 匹配
3. `episodeId` 匹配（兼容旧数据）

**关键查询模式:**
```dart
// 获取已完成的播放历史
filter()
  .statusEqualTo(PlayHistoryStatus.completed)
  .and()
  .isDeletedEqualTo(false)
  .sortByLastUpdateTimeDesc()

// 获取最新的播放中记录
filter()
  .group((q) => q
    .statusEqualTo(PlayHistoryStatus.playing)
    .or()
    .isPlayedEqualTo(false))
  .and()
  .isDeletedEqualTo(false)
  .sortByLastUpdateTimeDesc()
```

---

### 2.6 SearchHistoryModel（搜索历史）

| 字段名 | 类型 | 索引 | 默认值 | 说明 |
|--------|------|------|--------|------|
| id | Id (int) | 主键 | Isar.autoIncrement | 自增主键 |
| query | String | - | - | 搜索关键词 |
| createdAt | DateTime | - | DateTime.now() | 搜索时间 |

---

### 2.7 AppSettingsModel（应用设置）

**文件:** `lib/data/models/app_settings_model.dart`

| 字段名 | 类型 | 索引 | 默认值 | 说明 |
|--------|------|------|--------|------|
| id | Id (int) | 主键 | 0 | 固定为 0（单例模式） |
| downloadOnFavorite | bool | - | false | 收藏时自动下载 |
| removePlayedDownloads | bool | - | false | 播放完成后移除下载 |
| autoDownloadPolicy | AutoDownloadPolicyEnum | - | latest3 | 自动下载策略 |
| playbackSpeed | double | - | 1.0 | 播放速度 |
| volume | double | - | 0.3 | 音量 |
| skipForwardTime | int | - | 30 | 快进时间（秒） |
| skipBackwardTime | int | - | 15 | 快退时间（秒） |
| continuousPlay | bool | - | true | 连续播放 |
| sleepTimer | SleepTimerEnum | - | off | 睡眠定时器 |
| sleepTimerEndTimeMillis | int? | - | null | 睡眠定时器结束时间 |

**自动下载策略枚举:**
```dart
enum AutoDownloadPolicyEnum {
  off,        // 关闭
  latest1,    // 最新 1 集
  latest2,    // 最新 2 集
  latest3,    // 最新 3 集
  latest5,    // 最新 5 集
  latest10,   // 最新 10 集
  past24h,    // 过去 24 小时
  past7d,     // 过去 7 天
  past14d,    // 过去 14 天
  past30d,    // 过去 30 天
  all,        // 全部
}
```

**睡眠定时器枚举:**
```dart
enum SleepTimerEnum {
  off,        // 关闭
  min5,       // 5 分钟
  min10,      // 10 分钟
  min15,      // 15 分钟
  min30,      // 30 分钟
  min45,      // 45 分钟
  min60,      // 60 分钟
  episodeEnd, // 播集结束
}
```

---

## 3. 数据库架构

### 3.1 ER 图

```
┌─────────────────┐       1:N        ┌─────────────────┐
│     Podcast     │──────────────────▶│     Episode     │
│                 │   podcastId      │                 │
│  id (PK)        │                  │  id (PK)        │
│  title          │                  │  podcastId (FK) │
│  description    │                  │  title          │
│  itunesId       │                  │  guid           │
│  imageUrl       │                  │  itunesId       │
│  feedUrl        │                  │  podcastITunesId│
│  isSubscribed   │                  │  audioUrl       │
│  ...            │                  │  ...            │
└────────┬────────┘                  └────────┬────────┘
         │                                    │
         │                                    │ 1:N (快照)
         ▼                                    ▼
┌─────────────────┐       N:1        ┌─────────────────┐
│    AppSettings  │                  │   PlayHistory   │
│                 │                  │                 │
│  id = 0 (PK)    │                  │  id (PK)        │
│  playbackSpeed  │                  │  episodeId (FK) │
│  volume         │                  │  podcastId (FK) │
│  ...            │                  │  title (快照)   │
└─────────────────┘                  │  ...            │
                                     └────────┬────────┘
                                              │
         ┌─────────────────┐                  │
         │     Favorite    │                  │
         │                 │                  │
         │  id (PK)        │                  │
         │  episodeId (FK) │◀─────────────────┘
         │  episodeGuid    │
         │  episodeITunesId│                  ┌─────────────────┐
         └────────┬────────┘                  │      Queue      │
                  │                           │                 │
                  │                           │  id (PK)        │
                  │                           │  episodeId (FK) │
                  └───────────────────────────▶│  podcastId      │
                                               │  position       │
                                               │  ...            │
                                               └─────────────────┘
```

### 3.2 关联关系

| 关系 | 类型 | 关联字段 |
|------|------|---------|
| Podcast → Episode | 1:N | Episode.podcastId → Podcast.id |
| Podcast → PlayHistory | 1:N（快照） | PlayHistory.podcastId → Podcast.id |
| Episode → Favorite | 1:1 | Favorite.episodeId → Episode.id |
| Episode → PlayHistory | 1:N（快照） | PlayHistory.episodeId → Episode.id |
| Episode → Queue | 1:1 | Queue.episodeId → Episode.id |
| Episode → SearchHistory | 无关 | 独立记录搜索关键词 |

### 3.3 Fallback 关联机制

当使用 guid/iTunesId 关联时，如果数据库中不存在对应字段，则自动 fallback 到自增 ID：

```
优先级 1: podcastITunesId + episodeITunesId  (多区域 iTunes 匹配)
优先级 2: podcastId + episodeGuid             (RSS 标准标识)
优先级 3: episodeId                           (自增 ID 兼容)
```

这一机制在 `LocalFavoriteDataSource`、`LocalQueueDataSource` 和 `PlayHistoryRepository` 中实现。

---

## 4. 数据源与 Repository 层

### 4.1 架构层级

```
┌─────────────────────────────────────────┐
│           Domain Layer                  │
│   ┌─────────────────────────────────┐   │
│   │   Repository Interfaces         │   │
│   │   (FavoriteRepository, etc.)    │   │
│   └──────────────┬──────────────────┘   │
└──────────────────┼──────────────────────┘
                   │ implements
┌──────────────────┼──────────────────────┐
│           Data Layer                    │
│   ┌──────────────▼──────────────────┐   │
│   │   Repository Implementations    │   │
│   │   (FavoriteRepositoryImpl, etc.)│   │
│   └──────────────┬──────────────────┘   │
│                  │                       │
│   ┌──────────────▼──────────────────┐   │
│   │   Data Sources                  │   │
│   │   (LocalFavoriteDataSource,     │   │
│   │    LocalQueueDataSource, etc.)  │   │
│   └──────────────┬──────────────────┘   │
│                  │                       │
│   ┌──────────────▼──────────────────┐   │
│   │   IsarService                   │   │
│   │   (Database Instance)           │   │
│   └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### 4.2 数据源列表

| 数据源 | 文件路径 | 职责 |
|--------|---------|------|
| LocalFavoriteDataSource | `lib/data/datasources/local_favorite_datasource.dart` | 收藏增删查 |
| LocalQueueDataSource | `lib/data/datasources/local_queue_datasource.dart` | 队列增删查 |
| PlayHistoryRepository | `lib/data/repositories/play_history_repository.dart` | 播放历史增删查 |

---

## 5. 代码生成

### 5.1 生成命令

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5.2 生成的 Schema 文件

| Model | 生成文件 |
|-------|---------|
| Podcast | `podcast_model.g.dart` → PodcastSchema |
| Episode | `episode_model.g.dart` → EpisodeSchema |
| Favorite | `favorite_model.g.dart` → FavoriteSchema |
| Queue | `queue_model.g.dart` → QueueSchema |
| PlayHistory | `play_history_model.g.dart` → PlayHistorySchema |
| AppSettingsModel | `app_settings_model.g.dart` → AppSettingsModelSchema |
| SearchHistoryModel | `search_history_model.g.dart` → SearchHistoryModelSchema |

### 5.3 Schema ID 管理

Isar 为每个字段分配一个内部 ID，用于序列化。修改字段时需要重新运行 `build_runner` 生成新的 schema 文件。添加新字段时，Isar 会自动处理迁移（新增字段使用默认值）。

---

## 6. 数据库维护

### 6.1 关闭数据库

```dart
await IsarService.instance.close();
```

### 6.2 清空所有数据

```dart
await IsarService.instance.clearAll();
```

### 6.3 删除数据库文件

```dart
await IsarService.instance.deleteDatabase();
```

### 6.4 Inspector

开发模式下已启用 Isar Inspector，可通过浏览器访问 `http://localhost:43263` 查看实时数据库状态。

---

## 7. 最佳实践

1. **事务操作:** 所有写入操作都在 `writeTxn` 中执行，确保原子性
2. **日志记录:** 所有数据源操作都有详细的 Logger 日志，使用 emoji 前缀区分类型
3. **异常处理:** 统一使用 `AppException` 封装错误，区分 IsarError 和其他异常
4. **Fallback 关联:** 优先使用业务唯一标识（guid/iTunesId），fallback 到自增 ID
5. **软删除:** PlayHistory 使用 `isDeleted` 标记而非物理删除，支持数据恢复
6. **快照存储:** PlayHistory 存储 episode 的标题/描述/封面快照，即使原数据被删除也能显示
