# TinyCast 数据库技术文档

## 1. 概览

TinyCast 使用 **Isar**（`isar_community`）作为本地嵌入式 NoSQL 数据库，存储播客订阅、
剧集、收藏、播放历史、队列和应用设置。Isar 提供类型安全查询、异步 API 和事务支持。

### 1.1 技术栈

| 组件 | 值 |
|------|-----|
| 数据库 | Isar (`isar_community: ^3.3.2`) |
| 存储引擎 | NoSQL 嵌入式文档数据库 |
| 数据库文件 | `<ApplicationDocumentsDirectory>/tinycast.isar` |
| Schema 代码生成 | `build_runner` (`dart run build_runner build`) |
| Inspector | Debug / Profile 启用，Release 关闭 |

`IsarService._currentVersion` 当前为 `1`，仅作为代码内版本标记；`Isar.open`
不显式传入版本号，集合结构以生成的 `*Schema` 为准。

### 1.2 数据库初始化

```dart
// lib/data/database/isar_service.dart
class IsarService {
  static const String _databaseName = 'tinycast';

  Future<void> open({List<CollectionSchema>? schemas}) async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        PodcastSchema, EpisodeSchema, SearchHistoryModelSchema,
        FavoriteSchema, PlayHistorySchema, QueueSchema, AppSettingsModelSchema,
      ],
      directory: dir.path,
      name: _databaseName,
      inspector: !const bool.fromEnvironment('dart.vm.product'),
    );
    _isInitialized = true;
  }
}
```

- 数据库目录来自 `getApplicationDocumentsDirectory()`；
- `inspector` 在 Debug 和 Profile 构建中为 `true`，Release（`dart.vm.product`）中为 `false`；
- `open()` 是幂等的，已初始化时直接返回；
- 所有窗口共用同一数据库文件，但桌面多窗口运行在独立引擎中，每个窗口都要各自
  调用 `IsarService.instance.open()`。

### 1.3 注册的 Collections

| Isar 访问器 | CollectionSchema | 对应 Model | 用途 |
|-------------|------------------|-----------|------|
| `isar.podcasts` | `Podcast` | Podcast | 播客元数据（标题、描述、封面等） |
| `isar.episodes` | `Episode` | Episode | 剧集元数据（音频 URL、时长、播放状态等） |
| `isar.searchHistoryModels` | `SearchHistoryModel` | SearchHistoryModel | 搜索历史 |
| `isar.favorites` | `Favorite` | Favorite | 收藏记录 |
| `isar.playHistorys` | `PlayHistory` | PlayHistory | 播放历史 |
| `isar.queues` | `Queue` | Queue | 待播放队列 |
| `isar.appSettingsModels` | `AppSettingsModel` | AppSettingsModel | 应用全局设置（单例，id=0） |

---

## 2. Collection 详细定义

### 2.1 Podcast（播客）

**文件:** `lib/data/models/podcast_model.dart`

| 字段名 | 类型 | 索引 | 默认值 | 说明 |
|--------|------|------|--------|------|
| id | Id (int) | 主键 | Isar.autoIncrement | 自增主键 |
| supabaseId | String? | ✅ 有 | null | Supabase 同步 ID |
| title | String | ✅ 有 | - | 播客标题 |
| subtitle | String? | - | null | 副标题 |
| author | String | - | - | 播客作者 |
| description | String | - | - | 播客描述 |
| artworkUrl | String | - | - | 封面图片 URL |
| rssUrl | String | ✅ 唯一 | - | RSS Feed URL（唯一） |
| websiteUrl | String? | - | null | 官网链接 |
| language | String? | - | null | 语言代码 |
| copyright | String? | - | null | 版权信息 |
| categories | List\<String\>? | - | null | 分类列表 |
| keywords | List\<String\>? | - | null | 关键词列表 |
| isExplicit | bool | - | - | 是否包含成人内容 |
| ownerName | String? | - | null | 所有者名称 |
| ownerEmail | String? | - | null | 所有者邮箱 |
| lastUpdated | DateTime | ✅ 有 | - | Feed 最后更新时间 |
| episodeCount | int | - | - | 剧集数量 |
| isSubscribed | bool | - | - | 是否已订阅 |
| subscribedAt | DateTime? | - | null | 订阅时间 |
| lastFetchedAt | DateTime? | - | null | 最近一次成功刷新 Feed 的时间 |
| refreshFailedCount | int | - | 0 | 连续刷新失败次数（用于退避） |
| artworkPath | String? | - | null | 本地封面图片路径 |
| createdAt | DateTime | - | DateTime.now() | 对象创建时间 |
| itunesId | String? | ✅ 有 | null | Apple Podcasts ID |
| itunesArtworkUrl | String? | - | null | iTunes 封面图 URL |
| itunesPrimaryGenreName | String? | - | null | 主分类名称 |
| itunesGenres | List\<String\>? | - | null | 全部分类列表 |
| itunesGenreIds | List\<String\>? | - | null | 分类 ID 列表 |
| itunesCollectionViewUrl | String? | - | null | Apple Podcasts 页面 URL |
| itunesCountry | String? | - | null | iTunes 搜索国家代码 |
| itunesReleaseDate | DateTime? | - | null | iTunes 发布日期 |
| itunesCollectionExplicitness | String? | - | null | iTunes 内容分级 |
| itunesContentAdvisoryRating | String? | - | null | iTunes 内容评级 |

**关联:** 1 对多 → Episode (`podcastId`)

`lastFetchedAt` 和 `refreshFailedCount` 由 Feed 刷新流程维护（见
`LocalPodcastDataSource.updateLastFetchedAt` / `updateRefreshFailedCount`）。

---

### 2.2 Episode（剧集）

**文件:** `lib/data/models/episode_model.dart`

| 字段名 | 类型 | 索引 | 默认值 | 说明 |
|--------|------|------|--------|------|
| id | Id (int) | 主键 | Isar.autoIncrement | 自增主键 |
| supabaseId | String? | ✅ 有 | null | Supabase 同步 ID |
| podcastId | int | ✅ 有 | - | 所属播客 ID（外键关联） |
| title | String | - | - | 剧集标题 |
| description | String | - | - | 剧集描述 |
| link | String? | - | null | 剧集链接 |
| guid | String? | ✅ 有 | null | RSS GUID 唯一标识符 |
| author | String? | - | null | 剧集作者 |
| pubDate | DateTime | ✅ 有 | - | 发布日期（用于排序） |
| audioUrl | String | - | - | 音频文件 URL |
| audioType | String | - | - | 音频 MIME 类型 |
| duration | int? | - | null | 时长（秒） |
| artworkUrl | String? | - | null | 封面图片 URL |
| isExplicit | bool | - | - | 是否包含成人内容 |
| isPlayed | bool | - | - | 是否已播放 |
| isDownloaded | bool | - | - | 是否已下载 |
| downloadedPath | String? | - | null | 下载文件相对路径（`audio/<uuid>.mp3`） |
| artworkPath | String? | - | null | 本地封面图片路径 |
| downloadProgress | double | - | - | 下载进度 (0.0-1.0) |
| playProgress | double | - | - | 播放进度 (0.0-1.0) |
| lastPlayedAt | DateTime? | - | null | 最后播放时间 |
| createdAt | DateTime | - | - | 创建时间 |
| updatedAt | DateTime | - | - | 更新时间 |
| itunesId | String? | ✅ 有 | null | iTunes 剧集 ID（用于多区域关联） |
| podcastITunesId | String? | - | null | 所属播客的 iTunes ID |
| itunesArtworkUrl | String? | - | null | iTunes 封面图 URL |
| itunesReleaseDate | DateTime? | - | null | iTunes 发布日期 |
| itunesExplicitness | String? | - | null | iTunes 内容分级 |
| itunesContentAdvisoryRating | String? | - | null | iTunes 内容评级 |

**关联:** 多对 1 ← Podcast (`podcastId`)

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
| supabaseId | String? | ✅ 有 | null | Supabase 同步 ID |
| episodeId | int | ✅ 有 | - | 剧集 ID |
| episodeGuid | String? | - | null | 剧集 GUID（用于 fallback 关联） |
| episodeITunesId | String? | - | null | 剧集 iTunes ID（用于 fallback 关联） |
| createdAt | DateTime | - | DateTime.now() | 收藏时间 |

**Fallback 关联策略:** 按以下优先级匹配：

1. `episodeITunesId`
2. `episodeGuid`
3. `episodeId`（兼容旧数据）

实现位于 `lib/data/datasources/local_favorite_datasource.dart`。

---

### 2.4 Queue（待播放队列）

**文件:** `lib/data/models/queue_model.dart`

| 字段名 | 类型 | 索引 | 默认值 | 说明 |
|--------|------|------|--------|------|
| id | Id (int) | 主键 | Isar.autoIncrement | 自增主键 |
| supabaseId | String? | ✅ 有 | null | Supabase 同步 ID |
| episodeId | int | ✅ 有 | - | 剧集 ID |
| episodeGuid | String? | - | null | 剧集 GUID（用于 fallback 关联） |
| episodeITunesId | String? | - | null | 剧集 iTunes ID（用于 fallback 关联） |
| podcastId | int? | - | null | 所属播客 ID |
| podcastGuid | String? | - | null | 播客 GUID |
| podcastITunesId | String? | - | null | 播客 iTunes ID（用于 fallback 关联） |
| position | int | ✅ 有 | - | 队列位置（0 为最前） |
| addedAt | DateTime | - | DateTime.now() | 添加时间 |

**Fallback 关联策略:** 按以下优先级匹配：

1. `podcastITunesId` + `episodeITunesId`
2. `podcastId` + `episodeGuid`
3. `episodeId`（兼容旧数据）

实现位于 `lib/data/datasources/local_queue_datasource.dart`。

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
| supabaseId | String? | ✅ 有 | null | Supabase 同步 ID |
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
| playProgress | double | - | 0.0 | 播放进度 (0.0-1.0) |
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

**Fallback 关联策略:** 按以下优先级匹配：

1. `episodeITunesId`
2. `episodeGuid`
3. `episodeId`（兼容旧数据）

实现位于 `lib/data/repositories/play_history_repository_impl.dart`。

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

**文件:** `lib/data/models/search_history_model.dart`

| 字段名 | 类型 | 索引 | 默认值 | 说明 |
|--------|------|------|--------|------|
| id | Id (int) | 主键 | Isar.autoIncrement | 自增主键 |
| keyword | String | - | - | 搜索关键词 |
| searchedAt | DateTime | ✅ 有 | - | 搜索时间 |

---

### 2.7 AppSettingsModel（应用设置）

**文件:** `lib/data/models/app_settings_model.dart`

单例集合，固定使用 `id = 0`。

| 字段名 | 类型 | 索引 | 默认值 | 说明 |
|--------|------|------|--------|------|
| id | Id (int) | 主键 | 0 | 固定为 0（单例模式） |
| downloadOnFavorite | bool | - | false | 收藏时自动下载 |
| removePlayedDownloads | bool | - | false | 播放完成后移除下载 |
| autoDownloadPolicy | AutoDownloadPolicyEnum | - | latest3 | 自动下载策略 |
| feedRefreshInterval | FeedRefreshIntervalEnum | - | every6h | Feed 自动刷新间隔 |
| refreshOnCellular | bool | - | false | 允许蜂窝网络刷新 Feed |
| notifyOnNewEpisodes | bool | - | true | 新剧集通知开关 |
| backgroundRefreshEnabled | bool | - | true | 后台刷新开关 |
| playbackSpeed | double | - | 1.0 | 播放速度 |
| volume | double | - | 0.3 | 音量 |
| skipForwardTime | int | - | 30 | 快进时间（秒） |
| skipBackwardTime | int | - | 15 | 快退时间（秒） |
| continuousPlay | bool | - | true | 连续播放 |
| sleepTimer | SleepTimerEnum | - | off | 睡眠定时器 |
| sleepTimerEndTimeMillis | int? | - | null | 睡眠定时器结束时间（毫秒时间戳） |

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

**Feed 刷新间隔枚举:**

```dart
enum FeedRefreshIntervalEnum {
  manual,     // 仅手动
  hourly,     // 每小时
  every3h,    // 每 3 小时
  every6h,    // 每 6 小时（默认）
  every12h,   // 每 12 小时
  daily,      // 每天
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
  episodeEnd, // 当前剧集结束
}
```

`SleepTimerEnum` 提供 `minutes` getter，`episodeEnd` 和 `off` 返回 `null`。

---

## 3. 数据库架构

### 3.1 ER 图

```text
┌─────────────────┐       1:N        ┌─────────────────┐
│     Podcast     │──────────────────▶│     Episode     │
│                 │   podcastId      │                 │
│  id (PK)        │                  │  id (PK)        │
│  rssUrl (UQ)    │                  │  podcastId (FK) │
│  title          │                  │  title          │
│  author         │                  │  guid           │
│  artworkUrl     │                  │  itunesId       │
│  isSubscribed   │                  │  podcastITunesId│
│  itunesId       │                  │  audioUrl       │
│  supabaseId     │                  │  supabaseId     │
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
└─────────────────┘                  │  supabaseId     │
                                     │  ...            │
                                     └────────┬────────┘
                                              │
         ┌─────────────────┐                  │
         │     Favorite    │                  │
         │                 │                  │
         │  id (PK)        │                  │
         │  episodeId (FK) │◀─────────────────┘
         │  episodeGuid    │
         │  episodeITunesId│                  ┌─────────────────┐
         │  supabaseId     │                  │      Queue      │
         └────────┬────────┘                  │                 │
                  │                           │  id (PK)        │
                  │                           │  episodeId (FK) │
                  └───────────────────────────▶│  podcastId      │
                                               │  position       │
                                               │  supabaseId     │
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
| Episode → SearchHistory | 无关联 | 独立记录搜索关键词 |

Isar 不强制外键约束，以上关系由业务代码维护；删除播客或剧集时需要在同一事务中
清理关联记录。

### 3.3 Fallback 关联机制

当业务唯一标识存在时优先使用它们，缺失时回退到自增 ID：

```text
优先级 1: podcastITunesId + episodeITunesId  (多区域 iTunes 匹配)
优先级 2: podcastId + episodeGuid             (RSS 标准标识)
优先级 3: episodeId                           (自增 ID 兼容)
```

实现位置：

- 收藏：`LocalFavoriteDataSource`
- 队列：`LocalQueueDataSource`
- 播放历史：`PlayHistoryRepositoryImpl`

---

## 4. 数据源与 Repository 层

### 4.1 架构层级

```text
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
│   │    RemotePodcastDataSource,     │   │
│   │    RemoteSyncDataSource, etc.)  │   │
│   └──────────────┬──────────────────┘   │
│                  │                       │
│   ┌──────────────▼──────────────────┐   │
│   │   IsarService                   │   │
│   │   (Database Instance)           │   │
│   └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### 4.2 数据源与 Repository 列表

| 类型 | 文件路径 | 职责 |
|------|---------|------|
| `LocalPodcastDataSource` | `lib/data/datasources/local_podcast_datasource.dart` | 播客与剧集的本地增删查、Feed 刷新时间维护 |
| `RemotePodcastDataSource` | `lib/data/datasources/remote_podcast_datasource.dart` | RSS / iTunes 远程获取与解析 |
| `RemoteSyncDataSource` | `lib/data/datasources/remote_sync_datasource.dart` | Supabase 六张同步表的分页读取与分块写入 |
| `LocalFavoriteDataSource` | `lib/data/datasources/local_favorite_datasource.dart` | 收藏增删查 |
| `LocalQueueDataSource` | `lib/data/datasources/local_queue_datasource.dart` | 队列增删查 |
| `PlayHistoryRepositoryImpl` | `lib/data/repositories/play_history_repository_impl.dart` | 播放历史增删查与 fallback 关联 |

`RemoteSyncDataSource` 使用 `syncPageSize = 1000` 分页读取、`syncUpsertChunkSize = 500`
分块写入，避免 PostgREST 的默认行数上限截断结果。

---

## 5. 代码生成

### 5.1 生成命令

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5.2 生成的 Schema 文件

| Model | 生成文件 | CollectionSchema |
|-------|---------|------------------|
| Podcast | `podcast_model.g.dart` | `PodcastSchema` |
| Episode | `episode_model.g.dart` | `EpisodeSchema` |
| Favorite | `favorite_model.g.dart` | `FavoriteSchema` |
| Queue | `queue_model.g.dart` | `QueueSchema` |
| PlayHistory | `play_history_model.g.dart` | `PlayHistorySchema` |
| AppSettingsModel | `app_settings_model.g.dart` | `AppSettingsModelSchema` |
| SearchHistoryModel | `search_history_model.g.dart` | `SearchHistoryModelSchema` |

### 5.3 Schema 变更

修改字段后必须重新运行 `build_runner`。新增字段时 Isar 使用 Dart 字段默认值；
删除或重命名字段会丢失对应数据，需要自行处理迁移。生成文件
（`*.g.dart`）不要手动编辑。

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

`deleteDatabase()` 会先关闭数据库，再删除 `tinycast.isar`。

### 6.4 Inspector

Inspector 仅在非 Release 构建中启用（`!const bool.fromEnvironment('dart.vm.product')`）。
启动后查看日志中 Isar 输出的 Inspector 连接信息，按日志给出的地址/端口连接；
不要假设端口固定为 `43263`，多实例或端口占用时会变化。

---

## 7. 最佳实践

1. **事务操作:** 所有写入都在 `writeTxn` 中执行，跨集合的一致性操作放在同一事务。
2. **日志记录:** 数据源操作带 `Logger` 日志，并使用 emoji 前缀区分类型。
3. **异常处理:** 统一使用 `AppException` 封装错误，区分 Isar 错误和其他异常。
4. **Fallback 关联:** 优先使用业务唯一标识（guid / iTunesId），再回退到自增 ID。
5. **软删除:** PlayHistory 使用 `isDeleted` 标记而非物理删除。
6. **快照存储:** PlayHistory 存储标题 / 描述 / 封面快照，原剧集被删除后仍可展示。
7. **索引克制:** 只为真实查询条件添加 `@Index()`；`rssUrl` 是唯一索引，写入前需去重。
