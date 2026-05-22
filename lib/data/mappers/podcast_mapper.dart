import '../../domain/entities/podcast.dart';
import '../models/podcast_model.dart' as model;

/// Podcast 实体与模型之间的映射器
class PodcastMapper {
  /// 将 Model 转换为 Entity
  static Podcast toEntity(model.Podcast model) {
    return Podcast(
      id: model.id,
      title: model.title,
      subtitle: model.subtitle,
      author: model.author,
      description: model.description,
      artworkUrl: model.artworkUrl,
      rssUrl: model.rssUrl,
      websiteUrl: model.websiteUrl,
      language: model.language,
      copyright: model.copyright,
      categories: model.categories,
      keywords: model.keywords,
      isExplicit: model.isExplicit,
      ownerName: model.ownerName,
      ownerEmail: model.ownerEmail,
      lastUpdated: model.lastUpdated,
      episodeCount: model.episodeCount,
      isSubscribed: model.isSubscribed,
      subscribedAt: model.subscribedAt,
      artworkPath: model.artworkPath,
      createdAt: model.createdAt,
      itunesId: model.itunesId,
      itunesArtworkUrl: model.itunesArtworkUrl,
      itunesPrimaryGenreName: model.itunesPrimaryGenreName,
      itunesGenres: model.itunesGenres,
      itunesGenreIds: model.itunesGenreIds,
      itunesCollectionViewUrl: model.itunesCollectionViewUrl,
      itunesCountry: model.itunesCountry,
      itunesReleaseDate: model.itunesReleaseDate,
      itunesCollectionExplicitness: model.itunesCollectionExplicitness,
      itunesContentAdvisoryRating: model.itunesContentAdvisoryRating,
    );
  }

  /// 将 Entity 转换为 Model
  static model.Podcast toModel(Podcast entity) {
    return model.Podcast()
      ..title = entity.title
      ..subtitle = entity.subtitle
      ..author = entity.author
      ..description = entity.description
      ..artworkUrl = entity.artworkUrl
      ..rssUrl = entity.rssUrl
      ..websiteUrl = entity.websiteUrl
      ..language = entity.language
      ..copyright = entity.copyright
      ..categories = entity.categories
      ..keywords = entity.keywords
      ..isExplicit = entity.isExplicit
      ..ownerName = entity.ownerName
      ..ownerEmail = entity.ownerEmail
      ..lastUpdated = entity.lastUpdated
      ..episodeCount = entity.episodeCount
      ..isSubscribed = entity.isSubscribed
      ..subscribedAt = entity.subscribedAt
      ..itunesId = entity.itunesId
      ..itunesArtworkUrl = entity.itunesArtworkUrl
      ..itunesPrimaryGenreName = entity.itunesPrimaryGenreName
      ..itunesGenres = entity.itunesGenres
      ..itunesGenreIds = entity.itunesGenreIds
      ..itunesCollectionViewUrl = entity.itunesCollectionViewUrl
      ..itunesCountry = entity.itunesCountry
      ..itunesReleaseDate = entity.itunesReleaseDate
      ..itunesCollectionExplicitness = entity.itunesCollectionExplicitness
      ..itunesContentAdvisoryRating = entity.itunesContentAdvisoryRating;
  }

  /// 批量将 Model 列表转换为 Entity 列表
  static List<Podcast> toEntityList(List<model.Podcast> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// 批量将 Entity 列表转换为 Model 列表
  static List<model.Podcast> toModelList(List<Podcast> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}
