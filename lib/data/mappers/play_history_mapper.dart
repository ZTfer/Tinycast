import 'package:isar_community/isar.dart';

import 'package:tinycast/domain/entities/play_history.dart' as entity;
import 'package:tinycast/data/models/play_history_model.dart';

/// PlayHistory 领域实体与 Isar 持久化模型之间的映射
class PlayHistoryMapper {
  PlayHistoryMapper._();

  /// Model -> 领域实体
  static entity.PlayHistory toEntity(PlayHistory model) {
    return entity.PlayHistory(
      id: model.id,
      supabaseId: model.supabaseId,
      episodeId: model.episodeId,
      episodeGuid: model.episodeGuid,
      episodeITunesId: model.episodeITunesId,
      podcastId: model.podcastId,
      podcastGuid: model.podcastGuid,
      podcastITunesId: model.podcastITunesId,
      title: model.title,
      description: model.description,
      artworkUrl: model.artworkUrl,
      lastPlayedPositionMs: model.lastPlayedPositionMs,
      playProgress: model.playProgress,
      isPlayed: model.isPlayed,
      playedDuration: model.playedDuration,
      status: model.status,
      lastUpdateTime: model.lastUpdateTime,
      createdAt: model.createdAt,
      isDeleted: model.isDeleted,
    );
  }

  /// 领域实体 -> Model
  static PlayHistory toModel(entity.PlayHistory entity) {
    return PlayHistory()
      ..id = entity.id == 0 ? Isar.autoIncrement : entity.id
      ..supabaseId = entity.supabaseId
      ..episodeId = entity.episodeId
      ..episodeGuid = entity.episodeGuid
      ..episodeITunesId = entity.episodeITunesId
      ..podcastId = entity.podcastId
      ..podcastGuid = entity.podcastGuid
      ..podcastITunesId = entity.podcastITunesId
      ..title = entity.title
      ..description = entity.description
      ..artworkUrl = entity.artworkUrl
      ..lastPlayedPositionMs = entity.lastPlayedPositionMs
      ..playProgress = entity.playProgress
      ..isPlayed = entity.isPlayed
      ..playedDuration = entity.playedDuration
      ..status = entity.status
      ..lastUpdateTime = entity.lastUpdateTime
      ..isDeleted = entity.isDeleted;
  }

  /// Model 列表 -> 领域实体列表
  static List<entity.PlayHistory> toEntityList(List<PlayHistory> models) {
    return models.map(toEntity).toList();
  }
}

