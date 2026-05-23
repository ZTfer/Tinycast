import 'package:isar_community/isar.dart';
import '../../domain/entities/podcast.dart';
import '../../domain/entities/episode.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/app_exception.dart';
import '../../core/utils/itunes_info_dto.dart';
import '../database/isar_service.dart';
import '../mappers/podcast_mapper.dart';
import '../mappers/episode_mapper.dart';
import '../models/podcast_model.dart' as model;
import '../models/episode_model.dart' as model;

class LocalPodcastDataSource {
  final IsarService _isarService;

  LocalPodcastDataSource({IsarService? isarService})
    : _isarService = isarService ?? IsarService.instance;

  Future<List<model.Podcast>> getSubscribedPodcasts() async {
    final stopwatch = Stopwatch()..start();
    try {
      Logger.info('🕒 [DATASOURCE] getSubscribedPodcasts 开始');

      Logger.info('🕒 [DATASOURCE] [${stopwatch.elapsedMilliseconds}ms] 开始 Isar findAll 查询');
      final allPodcasts = await _isarService.isar.podcasts.where().findAll();
      Logger.info('🕒 [DATASOURCE] [${stopwatch.elapsedMilliseconds}ms] Isar findAll 完成, 共 ${allPodcasts.length} 个播客');

      for (final p in allPodcasts) {
        Logger.info(
          '播客: ${p.title}, isSubscribed: ${p.isSubscribed}, ID: ${p.id}',
        );
      }

      final unsubscribedWithRss = allPodcasts
          .where((p) => !p.isSubscribed && p.rssUrl.isNotEmpty)
          .toList();

      if (unsubscribedWithRss.isNotEmpty) {
        Logger.info(
          '🕒 [DATASOURCE] 发现 ${unsubscribedWithRss.length} 个有 RSS URL 但 isSubscribed=false 的播客，自动修复',
        );
        await _repairSubscriptionFlag(unsubscribedWithRss);
        Logger.info('🕒 [DATASOURCE] 修复完成，内存中播客对象状态已更新');
      }

      Logger.info('🕒 [DATASOURCE] [${stopwatch.elapsedMilliseconds}ms] 开始过滤 isSubscribed');
      final podcasts = allPodcasts.where((p) => p.isSubscribed).toList();
      Logger.info('🕒 [DATASOURCE] [${stopwatch.elapsedMilliseconds}ms] 过滤完成, 已订阅 ${podcasts.length} 个');

      Logger.info('成功获取 ${podcasts.length} 个已订阅播客, 总耗时 ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.stop();

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

  Future<void> _repairSubscriptionFlag(List<model.Podcast> podcasts) async {
    try {
      await _isarService.isar.writeTxn(() async {
        for (final p in podcasts) {
          p.isSubscribed = true;
          p.subscribedAt ??= p.createdAt;
          await _isarService.isar.podcasts.put(p);
        }
      });
      Logger.info('🕒 [DATASOURCE] 已修复 ${podcasts.length} 个播客的订阅状态');
    } catch (e, stackTrace) {
      Logger.error('🕒 [DATASOURCE] 修复订阅状态失败', error: e, stackTrace: stackTrace);
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

      final podcastModel = PodcastMapper.toModel(podcast);

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

      final episodeModels = EpisodeMapper.toModelList(episodes);

      final podcastITunesIdMap = <int, String>{};
      final isar = _isarService.isar;

      await isar.writeTxn(() async {
        for (final episodeModel in episodeModels) {
          if (episodeModel.podcastITunesId == null ||
              episodeModel.podcastITunesId!.isEmpty) {
            final podcastId = episodeModel.podcastId;
            String? itunesId = podcastITunesIdMap[podcastId];

            if (itunesId == null) {
              final podcast = isar.podcasts.getSync(podcastId);
              if (podcast != null &&
                  podcast.itunesId != null &&
                  podcast.itunesId!.isNotEmpty) {
                itunesId = podcast.itunesId!;
                podcastITunesIdMap[podcastId] = itunesId;
              }
            }

            if (itunesId != null) {
              episodeModel.podcastITunesId = itunesId;
            }
          }
        }
        await isar.episodes.putAll(episodeModels);
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

      final deleted = await _isarService.isar.writeTxn(() async {
        return await _isarService.isar.podcasts.delete(id);
      });

      if (deleted) {
        Logger.info('成功删除播客: $id');
      } else {
        Logger.warning('播客不存在，跳过删除: $id');
      }
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

  Future<void> updateFullITunesInfo(int id, ITunesInfoDTO info) async {
    try {
      Logger.info('更新播客完整 iTunes 信息: $id');

      await _isarService.isar.writeTxn(() async {
        final podcast = await _isarService.isar.podcasts.get(id);
        if (podcast != null) {
          podcast.itunesId = info.itunesId;
          podcast.itunesArtworkUrl = info.itunesArtworkUrl600;
          podcast.itunesPrimaryGenreName = info.itunesPrimaryGenreName;
          podcast.itunesGenres = info.itunesGenres;
          podcast.itunesGenreIds = info.itunesGenreIds;
          podcast.itunesCollectionViewUrl = info.itunesCollectionViewUrl;
          podcast.itunesCountry = info.itunesCountry;
          podcast.itunesReleaseDate = info.itunesReleaseDate;
          podcast.itunesCollectionExplicitness = info.itunesCollectionExplicitness;
          podcast.itunesContentAdvisoryRating = info.itunesContentAdvisoryRating;
          await _isarService.isar.podcasts.put(podcast);
        }
      });

      Logger.info('成功更新播客完整 iTunes 信息: $id');
    } on IsarError catch (e, stackTrace) {
      Logger.error('更新 iTunes 信息失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '更新 iTunes 信息失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('更新 iTunes 信息失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '更新 iTunes 信息失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 将播客的 iTunes ID 批量关联到其所有 episode
  Future<void> updateEpisodesPodcastITunesId(
    int podcastId,
    String? podcastITunesId,
  ) async {
    try {
      Logger.info('更新播客 $podcastId 下所有 episode 的 podcastITunesId: $podcastITunesId');

      final episodes = await _isarService.isar.episodes
          .filter()
          .podcastIdEqualTo(podcastId)
          .findAll();

      if (episodes.isEmpty) return;

      await _isarService.isar.writeTxn(() async {
        for (final episode in episodes) {
          episode.podcastITunesId = podcastITunesId;
        }
        await _isarService.isar.episodes.putAll(episodes);
      });

      Logger.info('成功更新 ${episodes.length} 个 episode 的 podcastITunesId');
    } on IsarError catch (e, stackTrace) {
      Logger.error('更新 episode podcastITunesId 失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '更新 episode iTunes 关联失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('更新 episode podcastITunesId 失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '更新 episode iTunes 关联失败',
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

  Future<List<model.Episode>> getDownloadedEpisodes() async {
    try {
      Logger.info('获取所有已下载节目');

      final episodes = await _isarService.isar.episodes
          .filter()
          .isDownloadedEqualTo(true)
          .sortByPubDateDesc()
          .findAll();

      Logger.info('成功获取 ${episodes.length} 个已下载节目');

      return episodes;
    } on IsarError catch (e, stackTrace) {
      Logger.error('获取已下载节目失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '获取已下载节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('获取已下载节目失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '获取已下载节目失败',
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

  Future<List<model.Episode>> getEpisodesByIds(List<int> ids) async {
    try {
      Logger.info('根据 IDs 获取节目，数量: ${ids.length}');

      final allEpisodes = await _isarService.isar.episodes
          .where()
          .sortByPubDateDesc()
          .findAll();

      final episodes = allEpisodes.where((e) => ids.contains(e.id)).toList();

      Logger.info('成功获取 ${episodes.length} 个节目');
      return episodes;
    } on IsarError catch (e, stackTrace) {
      Logger.error('根据 IDs 获取节目失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '根据 IDs 获取节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('根据 IDs 获取节目失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '根据 IDs 获取节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> updateIsPlayed(int episodeId, bool isPlayed) async {
    try {
      Logger.info('📋 [PODCAST-DS] 更新 episode isPlayed, episodeId: $episodeId, isPlayed: $isPlayed');

      final episode = await _isarService.isar.episodes
          .where()
          .idEqualTo(episodeId)
          .findFirst();

      if (episode == null) {
        Logger.warning('📋 [PODCAST-DS] 未找到 episode: $episodeId');
        return;
      }

      episode.isPlayed = isPlayed;
      episode.updatedAt = DateTime.now();

      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.episodes.put(episode);
      });

      Logger.info('📋 [PODCAST-DS] 成功更新 episode isPlayed, episodeId: $episodeId');
    } on IsarError catch (e, stackTrace) {
      Logger.error('📋 [PODCAST-DS] 更新 isPlayed 失败', error: e, stackTrace: stackTrace);
      throw AppException.storage('更新播放状态失败', originalError: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      Logger.error('📋 [PODCAST-DS] 更新 isPlayed 异常', error: e, stackTrace: stackTrace);
      throw AppException.unknown('更新播放状态失败', originalError: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateLastFetchedAt(int podcastId, DateTime lastFetchedAt) async {
    try {
      Logger.info('更新播客最后获取时间: $podcastId, $lastFetchedAt');

      await _isarService.isar.writeTxn(() async {
        final podcast = await _isarService.isar.podcasts.get(podcastId);
        if (podcast != null) {
          podcast.lastFetchedAt = lastFetchedAt;
          await _isarService.isar.podcasts.put(podcast);
        } else {
          Logger.warning('未找到 ID 为 $podcastId 的播客，无法更新最后获取时间');
        }
      });

      Logger.info('成功更新播客最后获取时间: $podcastId');
    } on IsarError catch (e, stackTrace) {
      Logger.error('更新最后获取时间失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '更新最后获取时间失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('更新最后获取时间失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '更新最后获取时间失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> updateRefreshFailedCount(int podcastId, int count) async {
    try {
      Logger.info('更新播客刷新失败次数: $podcastId, $count');

      await _isarService.isar.writeTxn(() async {
        final podcast = await _isarService.isar.podcasts.get(podcastId);
        if (podcast != null) {
          podcast.refreshFailedCount = count;
          await _isarService.isar.podcasts.put(podcast);
        } else {
          Logger.warning('未找到 ID 为 $podcastId 的播客，无法更新刷新失败次数');
        }
      });

      Logger.info('成功更新播客刷新失败次数: $podcastId');
    } on IsarError catch (e, stackTrace) {
      Logger.error('更新刷新失败次数失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '更新刷新失败次数失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('更新刷新失败次数失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '更新刷新失败次数失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Set<String>> getExistingEpisodeGuids(int podcastId) async {
    try {
      Logger.info('获取播客已存在的节目 GUID 列表: $podcastId');

      final episodes = await _isarService.isar.episodes
          .filter()
          .podcastIdEqualTo(podcastId)
          .findAll();

      final guids = <String>{};
      for (final episode in episodes) {
        if (episode.guid != null && episode.guid!.isNotEmpty) {
          guids.add(episode.guid!);
        }
      }

      Logger.info('成功获取 ${guids.length} 个已存在的节目 GUID');

      return guids;
    } on IsarError catch (e, stackTrace) {
      Logger.error('获取节目 GUID 列表失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '获取节目 GUID 列表失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('获取节目 GUID 列表失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '获取节目 GUID 列表失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<int> bulkInsertNewEpisodes(List<model.Episode> newEpisodes) async {
    try {
      Logger.info('批量插入新节目，数量: ${newEpisodes.length}');

      if (newEpisodes.isEmpty) {
        Logger.info('没有新节目需要插入');
        return 0;
      }

      int insertedCount = 0;

      await _isarService.isar.writeTxn(() async {
        for (final episode in newEpisodes) {
          if (episode.podcastITunesId == null ||
              episode.podcastITunesId!.isEmpty) {
            final podcast = _isarService.isar.podcasts.getSync(episode.podcastId);
            if (podcast != null &&
                podcast.itunesId != null &&
                podcast.itunesId!.isNotEmpty) {
              episode.podcastITunesId = podcast.itunesId!;
            }
          }
        }

        await _isarService.isar.episodes.putAll(newEpisodes);
        insertedCount = newEpisodes.length;
      });

      Logger.info('成功批量插入 $insertedCount 个新节目');

      return insertedCount;
    } on IsarError catch (e, stackTrace) {
      Logger.error('批量插入新节目失败', error: e, stackTrace: stackTrace);
      throw AppException.storage(
        '批量插入新节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('批量插入新节目异常', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '批量插入新节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
