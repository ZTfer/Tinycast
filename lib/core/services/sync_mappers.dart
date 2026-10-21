import 'package:tinycast/data/models/podcast_model.dart';
import 'package:tinycast/data/models/episode_model.dart';
import 'package:tinycast/data/models/play_history_model.dart';
import 'package:tinycast/data/models/favorite_model.dart';
import 'package:tinycast/data/models/queue_model.dart';

/// Converts a [Podcast] to a cloud-compatible map.
///
/// Extracted as a top-level function so that tests verify the exact
/// production mapping logic instead of a duplicated copy. [SyncService]
/// delegates to this function for its podcast push step.
Map<String, dynamic> podcastToCloudMap(Podcast p) {
  final map = <String, dynamic>{
    'title': p.title,
    'author': p.author,
    'description': p.description,
    'is_explicit': p.isExplicit,
    'language': p.language,
    'last_updated': p.lastUpdated.toUtc().toIso8601String(),
    'owner_email': p.ownerEmail,
    'owner_name': p.ownerName,
    'subtitle': p.subtitle,
    'website_url': p.websiteUrl,
    // Preserve the entity timestamp instead of restamping on every push:
    // remote pull uses `updated_at > since`, so a write-time stamp would
    // make every device re-pull the full library after any upload.
    'updated_at': p.lastUpdated.toUtc().toIso8601String(),
  };

  if (p.itunesId != null) map['itunes_id'] = p.itunesId;
  if (p.itunesArtworkUrl != null) {
    map['itunes_artwork_url'] = p.itunesArtworkUrl;
  }
  if (p.itunesCollectionExplicitness != null) {
    map['itunes_collection_explicitness'] = p.itunesCollectionExplicitness;
  }
  if (p.itunesCollectionViewUrl != null) {
    map['itunes_collection_view_url'] = p.itunesCollectionViewUrl;
  }
  if (p.itunesContentAdvisoryRating != null) {
    map['itunes_content_advisory_rating'] = p.itunesContentAdvisoryRating;
  }
  if (p.itunesCountry != null) map['itunes_country'] = p.itunesCountry;
  if (p.itunesGenreIds != null) map['itunes_genre_ids'] = p.itunesGenreIds;
  if (p.itunesGenres != null) map['itunes_genres'] = p.itunesGenres;
  if (p.itunesPrimaryGenreName != null) {
    map['itunes_primary_genre_name'] = p.itunesPrimaryGenreName;
  }
  if (p.itunesReleaseDate != null) {
    map['itunes_release_date'] = p.itunesReleaseDate!.toUtc().toIso8601String();
  }
  if (p.keywords != null) map['keywords'] = p.keywords;
  if (p.rssUrl.isNotEmpty) map['rss_urls'] = [p.rssUrl];
  final podcastCloudId =
      p.supabaseId != null ? int.tryParse(p.supabaseId!) : null;
  if (podcastCloudId != null) map['id'] = podcastCloudId;

  return map;
}

/// Converts an [Episode] to a cloud-compatible map.
///
/// Extracted as a top-level function so that tests verify the exact
/// production mapping logic. Does not include the `podcast_id` Isar
/// lookup — [SyncService] adds that separately after calling this
/// function.
Map<String, dynamic> episodeToCloudMap(Episode e) {
  final map = <String, dynamic>{
    'title': e.title,
    'description': e.description,
    'audio_url': e.audioUrl,
    'is_explicit': e.isExplicit,
    'updated_at': e.updatedAt.toUtc().toIso8601String(),
  };

  if (e.guid != null) map['guid'] = e.guid;
  if (e.artworkUrl != null) map['artwork_url'] = e.artworkUrl;
  if (e.duration != null) map['duration'] = e.duration;
  if (e.itunesArtworkUrl != null) {
    map['itunes_artwork_url'] = e.itunesArtworkUrl;
  }
  if (e.itunesContentAdvisoryRating != null) {
    map['itunes_content_advisory_rating'] = e.itunesContentAdvisoryRating;
  }
  if (e.itunesExplicitness != null) {
    map['itunes_explicitness'] = e.itunesExplicitness;
  }
  if (e.itunesId != null) map['itunes_id'] = e.itunesId;
  if (e.itunesReleaseDate != null) {
    map['itunes_release_date'] = e.itunesReleaseDate!.toUtc().toIso8601String();
  }
  if (e.link != null) map['link'] = e.link;
  if (e.podcastITunesId != null) map['podcast_itunes_id'] = e.podcastITunesId;
  map['pub_date'] = e.pubDate.toUtc().toIso8601String();
  final episodeCloudId =
      e.supabaseId != null ? int.tryParse(e.supabaseId!) : null;
  if (episodeCloudId != null) map['id'] = episodeCloudId;

  return map;
}

/// Converts a [PlayHistory] to a cloud-compatible map.
///
/// Extracted as a top-level function so that tests verify the exact
/// production mapping logic. Does not include the `episode_id` Isar
/// lookup — [SyncService] adds that separately after calling this
/// function.
Map<String, dynamic> playHistoryToCloudMap(PlayHistory h) {
  final map = <String, dynamic>{
    'artwork_url': h.artworkUrl,
    'description': h.description,
    'episode_guid': h.episodeGuid,
    'episode_itunes_id': h.episodeITunesId,
    'is_deleted': h.isDeleted,
    'is_played': h.isPlayed,
    'last_played_position_ms': h.lastPlayedPositionMs,
    'play_progress': h.playProgress,
    'last_update_time': h.lastUpdateTime.toUtc().toIso8601String(),
    'played_duration': h.playedDuration,
    'podcast_guid': h.podcastGuid,
    'podcast_itunes_id': h.podcastITunesId,
    'status': h.status.name,
    'title': h.title,
  };

  return map;
}

/// Converts a [Favorite] to a cloud-compatible map.
///
/// Extracted as a top-level function so that tests verify the exact
/// production mapping logic. Does not include the `episode_id` Isar
/// lookup — [SyncService] adds that separately after calling this
/// function.
Map<String, dynamic> favoriteToCloudMap(Favorite f) {
  final map = <String, dynamic>{
    'episode_guid': f.episodeGuid,
    'episode_itunes_id': f.episodeITunesId,
  };

  return map;
}

/// Converts a [Queue] item to a cloud-compatible map.
///
/// Extracted as a top-level function so that tests verify the exact
/// production mapping logic. Does not include the `episode_id` Isar
/// lookup — [SyncService] adds that separately after calling this
/// function.
Map<String, dynamic> queueItemToCloudMap(Queue q) {
  final map = <String, dynamic>{
    'episode_guid': q.episodeGuid,
    'episode_itunes_id': q.episodeITunesId,
    'podcast_guid': q.podcastGuid,
    'podcast_itunes_id': q.podcastITunesId,
    'position': q.position,
    'added_at': q.addedAt.toUtc().toIso8601String(),
  };

  return map;
}
