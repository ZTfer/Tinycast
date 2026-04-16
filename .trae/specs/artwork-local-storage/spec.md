# 封面图本地存储与缓存 Spec

## Why
当前应用每次展示 podcast 和 episode 封面图时都需要从网络加载，导致：
1. 离线状态下无法显示封面图
2. 重复网络请求浪费带宽
3. 图片加载速度依赖网络状况

通过将封面图保存到本地文件系统并在数据库中记录路径，可以实现离线访问和更快的加载速度。

## What Changes
- 在 Episode 数据模型中添加 `artworkPath` 字段（String? 类型），用于存储 episode 封面图的本地相对路径
- 在 Podcast 数据模型中添加 `artworkPath` 字段（String? 类型），用于存储 podcast 封面图的本地相对路径
- 扩展 FileStorageService，添加基于 UUID v4 的图片文件名生成方法
- 创建或扩展图片下载服务，实现封面图下载、保存和路径记录逻辑
- 更新 UI 层图片显示组件，优先从本地路径加载，失败后回退到网络 URL

## Impact
- Affected specs: 无直接影响其他 spec
- Affected code:
  - `lib/data/models/episode_model.dart` - 添加 artworkPath 字段
  - `lib/data/models/podcast_model.dart` - 添加 artworkPath 字段
  - `lib/data/services/file_storage_service.dart` - 添加 UUID v4 图片文件名生成方法
  - `lib/data/services/image_cache_service.dart` - 扩展或新建 artwork 下载服务
  - 所有使用 CachedNetworkImage 显示封面图的 UI 组件 - 更新为支持本地文件优先加载

## ADDED Requirements

### Requirement: Episode 和 Podcast 模型扩展
系统 SHALL 在 Episode 和 Podcast 数据模型中添加 `artworkPath` 字段。

#### Scenario: 添加 artworkPath 字段
- **WHEN** 定义 Episode 和 Podcast Isar 模型
- **THEN** 模型包含 `String? artworkPath` 可空字段，用于存储封面图本地相对路径（格式：`images/{uuid}.jpg`）

### Requirement: UUID v4 图片文件名生成
FileStorageService SHALL 提供基于 UUID v4 的图片文件名生成方法，与音频文件命名规则保持一致。

#### Scenario: 生成图片文件名
- **WHEN** 调用 generateArtworkFileName() 方法
- **THEN** 返回格式为 `{uuid}.jpg` 的字符串，其中 uuid 为 UUID v4 格式

### Requirement: 封面图下载与保存服务
系统 SHALL 提供服务来下载、保存封面图并记录路径到数据库。

#### Scenario: 下载并保存 Episode 封面图
- **GIVEN** 一个 Episode 对象，其 artworkUrl 不为空
- **WHEN** 调用 downloadEpisodeArtwork(episode) 方法
- **THEN** 系统：
  1. 从 artworkUrl 下载图片数据
  2. 使用 UUID v4 生成文件名
  3. 将图片保存到 images 目录
  4. 将相对路径（`images/{filename}.jpg`）保存到 episode.artworkPath 字段
  5. 更新数据库记录
  6. 返回保存后的本地文件路径

#### Scenario: 下载并保存 Podcast 封面图
- **GIVEN** 一个 Podcast 对象，其 artworkUrl 不为空
- **WHEN** 调用 downloadPodcastArtwork(podcast) 方法
- **THEN** 系统：
  1. 从 artworkUrl 下载图片数据
  2. 使用 UUID v4 生成文件名
  3. 将图片保存到 images 目录
  4. 将相对路径（`images/{filename}.jpg`）保存到 podcast.artworkPath 字段
  5. 更新数据库记录
  6. 返回保存后的本地文件路径

#### Scenario: 跳过已存在的封面图
- **GIVEN** 一个 Episode/Podcast 对象，其 artworkPath 已有值且对应文件存在
- **WHEN** 调用下载方法
- **THEN** 直接返回现有路径，不重复下载

### Requirement: 本地优先的图片加载策略
UI 组件 SHALL 实现本地优先的图片加载策略。

#### Scenario: 从本地文件加载封面图
- **GIVEN** 一个 Episode/Podcast 对象，artworkPath 不为空且文件存在
- **WHEN** UI 组件需要显示封面图
- **THEN** 优先使用 Image.file() 加载本地文件

#### Scenario: 回退到网络 URL
- **GIVEN** 一个 Episode/Podcast 对象，满足以下任一条件：
  - artworkPath 为空
  - artworkPath 对应的文件不存在
- **WHEN** UI 组件需要显示封面图
- **THEN** 回退使用 artworkUrl 从网络加载（CachedNetworkImage）

#### Scenario: 触发后台下载
- **GIVEN** 从网络成功加载了封面图
- **WHEN** artworkPath 为空或文件不存在
- **THEN** 后台触发下载并保存操作，更新数据库中的 artworkPath

## MODIFIED Requirements

### Requirement: FileStorageService 扩展
现有 FileStorageService SHALL 新增 artwork 相关的文件名生成方法。

**修改内容**：
- 添加 `generateArtworkFileName()` 方法，使用 UUID v4 生成 `{uuid}.jpg` 格式文件名
- 保留现有 `generateImageFileName(url)` 方法（基于 URL hash）以兼容旧逻辑

### Requirement: ImageCacheService 集成
现有 ImageCacheService SHALL 与新的 artwork 存储系统集成或创建专门的 ArtworkDownloadService。

**修改内容**：
- 新增 `downloadAndSaveEpisodeArtwork(Episode episode)` 方法
- 新增 `downloadAndSavePodcastArtwork(Podcast podcast)` 方法
- 这些方法在下载完成后更新数据库记录
- 复用现有的 Dio 实例和错误处理机制

## REMOVED Requirements
无
