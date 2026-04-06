import 'package:isar_community/isar.dart';
import '../../domain/entities/podcast.dart';
import '../../domain/entities/episode.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/app_exception.dart';
import '../database/isar_service.dart';
import '../models/podcast_model.dart' as model;
import '../models/episode_model.dart' as model;

class LocalPodcastDataSource {
  final IsarService _isarService;

  LocalPodcastDataSource({IsarService? isarService})
    : _isarService = isarService ?? IsarService.instance;

  Future<List<model.Podcast>> getSubscribedPodcasts() async {
    try {
      Logger.info('获取所有已订阅播客');

      final allPodcasts = await _isarService.isar.podcasts.where().findAll();

      Logger.info('数据库中共有 ${allPodcasts.length} 个播客');

      for (final p in allPodcasts) {
        Logger.info(
          '播客: ${p.title}, isSubscribed: ${p.isSubscribed}, ID: ${p.id}',
        );
      }

      final podcasts = allPodcasts.where((p) => p.isSubscribed).toList();

      Logger.info('成功获取 ${podcasts.length} 个已订阅播客');

      return podcasts;
    } on IsarError catch (e, stackTrace) {
      Logger.error('获取已订阅播客失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '获取已订阅播客失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('获取已订阅播客失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '获取已订阅播客失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<model.Podcast?> getPodcastById(int id) async {
    try {
      Logger.info('根据 ID 查询播客: $id');

      final podcast = await _isarService.isar.podcasts.get(id);

      if (podcast != null) {
        Logger.info('成功获取播客: ${podcast.title}');
      } else {
        Logger.warning('未找到 ID 为 $id 的播客');
      }

      return podcast;
    } on IsarError catch (e, stackTrace) {
      Logger.error('查询播客失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '查询播客失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('查询播客失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '查询播客失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<int> savePodcast(Podcast podcast) async {
    try {
      Logger.info('保存播客到数据库: ${podcast.title}');

      final podcastModel = _convertPodcastEntityToModel(podcast);

      final id = await _isarService.isar.writeTxn(() async {
        final existingPodcast = await _isarService.isar.podcasts
            .filter()
            .rssUrlEqualTo(podcast.rssUrl)
            .findFirst();

        if (existingPodcast != null) {
          Logger.info('播客已存在，更新现有记录，ID: ${existingPodcast.id}');
          podcastModel.id = existingPodcast.id;
        }

        return await _isarService.isar.podcasts.put(podcastModel);
      });

      Logger.info('成功保存播客，ID: $id');

      return id;
    } on IsarError catch (e, stackTrace) {
      Logger.error('保存播客失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '保存播客失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('保存播客失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '保存播客失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> saveEpisodes(List<Episode> episodes) async {
    try {
      Logger.info('保存 ${episodes.length} 个节目到数据库');

      final episodeModels = episodes
          .map((episode) => _convertEpisodeEntityToModel(episode))
          .toList();

      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.episodes.putAll(episodeModels);
      });

      Logger.info('成功保存 ${episodes.length} 个节目');
    } on IsarError catch (e, stackTrace) {
      Logger.error('保存节目失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '保存节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('保存节目失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '保存节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> deletePodcast(int id) async {
    try {
      Logger.info('删除播客: $id');

      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.podcasts.delete(id);
      });

      Logger.info('成功删除播客: $id');
    } on IsarError catch (e, stackTrace) {
      Logger.error('删除播客失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '删除播客失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('删除播客失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '删除播客失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> deleteEpisodesByPodcastId(int podcastId) async {
    try {
      Logger.info('删除播客的所有节目: $podcastId');

      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.episodes
            .filter()
            .podcastIdEqualTo(podcastId)
            .deleteAll();
      });

      Logger.info('成功删除播客的所有节目: $podcastId');
    } on IsarError catch (e, stackTrace) {
      Logger.error('删除节目失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '删除节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('删除节目失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '删除节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> isPodcastSubscribed(String rssUrl) async {
    try {
      Logger.info('检查播客是否已订阅: $rssUrl');

      final podcast = await _isarService.isar.podcasts
          .filter()
          .rssUrlEqualTo(rssUrl)
          .isSubscribedEqualTo(true)
          .findFirst();

      final isSubscribed = podcast != null;

      if (isSubscribed) {
        Logger.info('播客已订阅: ${podcast.title}');
      } else {
        Logger.info('播客未订阅: $rssUrl');
      }

      return isSubscribed;
    } on IsarError catch (e, stackTrace) {
      Logger.error('检查订阅状态失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '检查订阅状态失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('检查订阅状态失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '检查订阅状态失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<model.Episode>> getEpisodesByPodcastId(int podcastId) async {
    try {
      Logger.info('获取播客的所有节目: $podcastId');

      final episodes = await _isarService.isar.episodes
          .filter()
          .podcastIdEqualTo(podcastId)
          .sortByPubDateDesc()
          .findAll();

      Logger.info('成功获取 ${episodes.length} 个节目');

      return episodes;
    } on IsarError catch (e, stackTrace) {
      Logger.error('获取节目失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '获取节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('获取节目失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '获取节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<model.Episode>> getLatestEpisodesByPodcastId(
    int podcastId, {
    int limit = 3,
  }) async {
    try {
      Logger.info('获取播客最新 $limit 个节目: $podcastId');

      final episodes = await _isarService.isar.episodes
          .filter()
          .podcastIdEqualTo(podcastId)
          .sortByPubDateDesc()
          .limit(limit)
          .findAll();

      Logger.info('成功获取 ${episodes.length} 个最新节目');

      return episodes;
    } on IsarError catch (e, stackTrace) {
      Logger.error('获取最新节目失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '获取最新节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('获取最新节目失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '获取最新节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<model.Podcast?> getPodcastByRssUrl(String rssUrl) async {
    try {
      Logger.info('根据 RSS URL 查询播客: $rssUrl');

      final podcast = await _isarService.isar.podcasts
          .filter()
          .rssUrlEqualTo(rssUrl)
          .findFirst();

      if (podcast != null) {
        Logger.info('成功获取播客: ${podcast.title}');
      } else {
        Logger.warning('未找到 RSS URL 为 $rssUrl 的播客');
      }

      return podcast;
    } on IsarError catch (e, stackTrace) {
      Logger.error('查询播客失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '查询播客失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('查询播客失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '查询播客失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> updatePodcastSubscription(int id, bool isSubscribed) async {
    try {
      Logger.info('更新播客订阅状态: $id, $isSubscribed');

      await _isarService.isar.writeTxn(() async {
        final podcast = await _isarService.isar.podcasts.get(id);
        Logger.info(
          '查询到的播客: ${podcast?.title}, ID: ${podcast?.id}, 当前isSubscribed: ${podcast?.isSubscribed}',
        );

        if (podcast != null) {
          podcast.isSubscribed = isSubscribed;
          podcast.subscribedAt = isSubscribed ? DateTime.now() : null;
          final updatedId = await _isarService.isar.podcasts.put(podcast);
          Logger.info(
            '更新后的播客 ID: $updatedId, isSubscribed: ${podcast.isSubscribed}',
          );
        } else {
          Logger.warning('未找到 ID 为 $id 的播客，无法更新订阅状态');
        }
      });

      Logger.info('成功更新播客订阅状态: $id');
    } on IsarError catch (e, stackTrace) {
      Logger.error('更新订阅状态失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '更新订阅状态失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('更新订阅状态失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '更新订阅状态失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> updatePodcastEpisodeCount(int id, int count) async {
    try {
      Logger.info('更新播客节目数量: $id, $count');

      await _isarService.isar.writeTxn(() async {
        final podcast = await _isarService.isar.podcasts.get(id);
        if (podcast != null) {
          podcast.episodeCount = count;
          podcast.lastUpdated = DateTime.now();
          await _isarService.isar.podcasts.put(podcast);
        }
      });

      Logger.info('成功更新播客节目数量: $id');
    } on IsarError catch (e, stackTrace) {
      Logger.error('更新节目数量失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '更新节目数量失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('更新节目数量失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '更新节目数量失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<model.Episode>> getUnplayedEpisodes() async {
    try {
      Logger.info('获取所有未播放节目');

      final episodes = await _isarService.isar.episodes
          .filter()
          .isPlayedEqualTo(false)
          .sortByPubDateDesc()
          .findAll();

      Logger.info('成功获取 ${episodes.length} 个未播放节目');

      return episodes;
    } on IsarError catch (e, stackTrace) {
      Logger.error('获取未播放节目失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '获取未播放节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('获取未播放节目失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '获取未播放节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<model.Podcast>> searchPodcasts(String keyword) async {
    try {
      Logger.info('搜索播客: $keyword');

      final podcasts = await _isarService.isar.podcasts
          .filter()
          .isSubscribedEqualTo(true)
          .and()
          .group((q) => q
              .titleContains(keyword, caseSensitive: false)
              .or()
              .descriptionContains(keyword, caseSensitive: false))
          .findAll();

      Logger.info('成功搜索到 ${podcasts.length} 个播客');

      return podcasts;
    } on IsarError catch (e, stackTrace) {
      Logger.error('搜索播客失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '搜索播客失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('搜索播客失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '搜索播客失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<model.Episode>> searchEpisodes(String keyword) async {
    try {
      Logger.info('搜索节目: $keyword');

      final episodes = await _isarService.isar.episodes
          .filter()
          .group((q) => q
              .titleContains(keyword, caseSensitive: false)
              .or()
              .descriptionContains(keyword, caseSensitive: false))
          .sortByPubDateDesc()
          .findAll();

      Logger.info('成功搜索到 ${episodes.length} 个节目');

      return episodes;
    } on IsarError catch (e, stackTrace) {
      Logger.error('搜索节目失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '搜索节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('搜索节目失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '搜索节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  model.Podcast _convertPodcastEntityToModel(Podcast entity) {
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
      ..subscribedAt = entity.subscribedAt;
  }

  model.Episode _convertEpisodeEntityToModel(Episode entity) {
    return model.Episode()
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
      ..downloadProgress = entity.downloadProgress
      ..playProgress = entity.playProgress
      ..lastPlayedAt = entity.lastPlayedAt
      ..updatedAt = entity.updatedAt;
  }
}
