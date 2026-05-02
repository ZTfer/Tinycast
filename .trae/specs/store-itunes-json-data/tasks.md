# Tasks

- [ ] Task 1: Podcast 实体和模型字段重命名与扩展
  - [ ] SubTask 1.1: 将 `appleId` 重命名为 `itunesId` (Podcast entity)
  - [ ] SubTask 1.2: 将 `appleId` 重命名为 `iTunesId` (Episode entity)
  - [ ] SubTask 1.3: Podcast Isar 模型添加所有新字段
  - [ ] SubTask 1.4: Episode Isar 模型添加所有新字段
  - [ ] SubTask 1.5: 运行 build_runner 重新生成 .g.dart 文件

- [ ] Task 2: iTunes 搜索结果模型扩展
  - [ ] SubTask 2.1: ITunesSearchResult 添加新字段 (primaryGenreName, genres, genreIds, collectionViewUrl, country, releaseDate, collectionExplicitness, contentAdvisoryRating)
  - [ ] SubTask 2.2: fromJson 解析所有新字段

- [ ] Task 3: 更新数据存储和转换逻辑
  - [ ] SubTask 3.1: local_podcast_datasource 更新 _convertPodcastEntityToModel 包含新字段
  - [ ] SubTask 3.2: podcast_repository_impl 更新 _convertPodcastModelToEntity 包含新字段
  - [ ] SubTask 3.3: 创建 updateFullITunesInfo 方法更新所有新字段

- [ ] Task 4: 更新订阅流程
  - [ ] SubTask 4.1: remote_podcast_datasource 的 _asyncITunesSearch 存储完整搜索结果

- [ ] Task 5: 全局 appleId 引用更新
  - [ ] SubTask 5.1: 搜索所有引用 appleId 的地方并更新为 itunesId

- [ ] Task 6: 验证和测试
  - [ ] SubTask 6.1: flutter analyze 通过

# Task Dependencies

- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 1, Task 2]
- [Task 4] depends on [Task 2, Task 3]
- [Task 5] depends on [Task 1]
- [Task 6] depends on [Task 4, Task 5]
