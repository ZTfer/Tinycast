# Tasks

## 任务列表

- [x] Task 1: 扩展数据模型 - 在 Episode 和 Podcast 模型中添加 artworkPath 字段
  - [x] 1.1 在 episode_model.dart 中添加 `String? artworkPath` 字段
  - [x] 1.2 在 podcast_model.dart 中添加 `String? artworkPath` 字段
  - [x] 1.3 重新生成 Isar 模型代码（运行 build_runner）

- [x] Task 2: 扩展 FileStorageService - 添加 UUID v4 图片文件名生成方法
  - [x] 2.1 添加 `generateArtworkFileName()` 方法，使用 UUID v4 生成 `{uuid}.jpg` 格式文件名
  - [x] 2.2 确保方法与现有 `generateAudioFileName()` 使用相同的 UUID 生成逻辑

- [x] Task 3: 创建/扩展封面图下载服务
  - [x] 3.1 在 ImageCacheService 或新建 ArtworkDownloadService 中实现 `downloadAndSaveEpisodeArtwork(Episode)` 方法
  - [x] 3.2 实现 `downloadAndSavePodcastArtwork(Podcast)` 方法
  - [x] 3.3 实现下载逻辑：检查 artworkPath → 下载图片 → 保存文件 → 更新数据库
  - [x] 3.4 完善错误处理和日志记录

- [x] Task 4: 集成到音频下载流程 - 在下载音频时自动下载封面图
  - [x] 4.1 在 AudioDownloadService.downloadEpisode() 成功后触发 episode 封面图下载
  - [x] 4.2 在订阅 Podcast 时自动下载 podcast 封面图（可选，根据实际业务需求）

- [x] Task 5: 更新 UI 层 - 实现本地优先的图片加载策略
  - [x] 5.1 创建 ArtworkImage Widget 组件，封装本地/网络加载逻辑
  - [x] 5.2 更新所有使用 CachedNetworkImage 显示 episode/podcast 封面图的组件
  - [x] 5.3 确保离线状态下能正确显示已保存的封面图

- [x] Task 6: 测试与验证
  - [x] 6.1 验证 Episode 和 Podcast 的 artworkPath 字段能正确保存和读取
  - [x] 6.2 验证封面图下载、保存流程正常工作
  - [x] 6.3 验证本地文件存在时优先使用本地文件
  - [x] 6.4 验证本地文件不存在时回退到网络加载并触发后台下载
  - [x] 6.5 验证离线状态下的显示效果

## Task Dependencies
- [Task 2] depends on [Task 1] - 需要先有 artworkPath 字段才能保存路径
- [Task 3] depends on [Task 1, Task 2] - 需要模型字段和文件名生成方法
- [Task 4] depends on [Task 3] - 需要先实现下载服务
- [Task 5] depends on [Task 3] - 需要下载服务提供数据
- [Task 6] depends on [Task 3, Task 5] - 所有功能实现后进行测试
