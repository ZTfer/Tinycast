# Checklist

- [ ] Podcast 实体中 `appleId` 已重命名为 `itunesId`
- [ ] Episode 实体中 `appleId` 已重命名为 `iTunesId`
- [ ] Podcast 模型包含所有新字段：`iTunesPrimaryGenreName`, `iTunesGenres`, `iTunesGenreIds`, `iTunesCollectionViewUrl`, `iTunesArtworkUrl600`, `iTunesCountry`, `iTunesReleaseDate`, `iTunesCollectionExplicitness`, `iTunesContentAdvisoryRating`
- [ ] Episode 模型包含新字段：`iTunesId`, `iTunesArtworkUrl600`, `iTunesReleaseDate`, `iTunesExplicitness`, `iTunesContentAdvisoryRating`
- [ ] `.g.dart` 文件已重新生成
- [ ] `ITunesSearchResult` 包含完整字段和正确的 fromJson 解析
- [ ] `_convertPodcastEntityToModel` 和 `_convertPodcastModelToEntity` 包含所有新字段
- [ ] 订阅流程在搜索成功后存储完整 iTunes 信息
- [ ] 所有引用 `appleId` 的地方已更新为 `itunesId`
- [ ] `flutter analyze` 通过无错误
