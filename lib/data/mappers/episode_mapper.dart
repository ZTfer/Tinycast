import '../../domain/entities/episode.dart';
import '../models/episode_model.dart' as model;

/// Episode 实体与模型之间的映射器
class EpisodeMapper {
  /// 将 Model 转换为 Entity
  static Episode toEntity(model.Episode model) {
    return Episode(
      id: model.id,
      supabaseId: model.supabaseId,
      podcastId: model.podcastId,
      title: model.title,
      description: model.description,
      link: model.link,
      guid: model.guid,
      author: model.author,
      pubDate: model.pubDate,
      audioUrl: model.audioUrl,
      audioType: model.audioType,
      duration: model.duration,
      artworkUrl: model.artworkUrl,
      isExplicit: model.isExplicit,
      isPlayed: model.isPlayed,
      isDownloaded: model.isDownloaded,
      isFavorite: false,
      downloadedPath: model.downloadedPath,
      artworkPath: model.artworkPath,
      downloadProgress: model.downloadProgress,
      playProgress: model.playProgress,
      lastPlayedAt: model.lastPlayedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      itunesId: model.itunesId,
      podcastITunesId: model.podcastITunesId,
      itunesArtworkUrl: model.itunesArtworkUrl,
      itunesReleaseDate: model.itunesReleaseDate,
      itunesExplicitness: model.itunesExplicitness,
      itunesContentAdvisoryRating: model.itunesContentAdvisoryRating,
    );
  }

  /// 将 Entity 转换为 Model
  static model.Episode toModel(Episode entity) {
    return model.Episode()
      ..id = entity.id
      ..supabaseId = entity.supabaseId
      ..podcastId = entity.podcastId
      ..title = entity.title
      ..description = entity.description
      ..link = entity.link
      ..guid = entity.guid
      ..author = entity.author
      ..pubDate = entity.pubDate
      ..audioUrl = entity.audioUrl
      ..audioType = entity.audioType
      ..duration = entity.duration
      ..artworkUrl = entity.artworkUrl
      ..isExplicit = entity.isExplicit
      ..isPlayed = entity.isPlayed
      ..isDownloaded = entity.isDownloaded
      ..downloadedPath = entity.downloadedPath
      ..artworkPath = entity.artworkPath
      ..downloadProgress = entity.downloadProgress
      ..playProgress = entity.playProgress
      ..lastPlayedAt = entity.lastPlayedAt
      ..updatedAt = entity.updatedAt
      ..itunesId = entity.itunesId
      ..podcastITunesId = entity.podcastITunesId
      ..itunesArtworkUrl = entity.itunesArtworkUrl
      ..itunesReleaseDate = entity.itunesReleaseDate
      ..itunesExplicitness = entity.itunesExplicitness
      ..itunesContentAdvisoryRating = entity.itunesContentAdvisoryRating;
  }

  /// 批量将 Model 列表转换为 Entity 列表
  static List<Episode> toEntityList(List<model.Episode> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// 批量将 Entity 列表转换为 Model 列表
  static List<model.Episode> toModelList(List<Episode> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}
