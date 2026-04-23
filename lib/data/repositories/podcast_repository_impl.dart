import '../../domain/entities/podcast.dart';
import '../../domain/entities/episode.dart';
import '../../domain/repositories/podcast_repository.dart';
import '../datasources/remote_podcast_datasource.dart';
import '../datasources/local_podcast_datasource.dart';
import '../services/file_storage_service.dart';
import '../models/podcast_model.dart' as model;
import '../models/episode_model.dart' as model;
import '../../core/utils/app_exception.dart';
import '../../core/utils/logger.dart';

class PodcastRepositoryImpl implements PodcastRepository {
  final RemotePodcastDataSource _remoteDataSource;
  final LocalPodcastDataSource _localDataSource;
  final FileStorageService _fileStorageService;

  PodcastRepositoryImpl({
    RemotePodcastDataSource? remoteDataSource,
    LocalPodcastDataSource? localDataSource,
    FileStorageService? fileStorageService,
  }) : _remoteDataSource = remoteDataSource ?? RemotePodcastDataSource(),
       _localDataSource = localDataSource ?? LocalPodcastDataSource(),
       _fileStorageService = fileStorageService ?? FileStorageService.instance;

  @override
  Future<Podcast> subscribe(String rssUrl) async {
    final stopwatch = Stopwatch()..start();
    try {
      Logger.info('🕒 [TIMING] [0ms] 开始订阅播客: $rssUrl');

      final isSubscribed = await _localDataSource.isPodcastSubscribed(rssUrl);
      Logger.info('🕒 [TIMING] [${stopwatch.elapsedMilliseconds}ms] isPodcastSubscribed 完成, isSubscribed=$isSubscribed');
      if (isSubscribed) {
        throw AppException.validation('该播客已订阅');
      }

      final result = await _remoteDataSource.getPodcastFromRss(rssUrl);
      Logger.info('🕒 [TIMING] [${stopwatch.elapsedMilliseconds}ms] getPodcastFromRss 完成（网络请求）');
      final podcastEntity = result['podcast'] as Podcast;
      final episodes = result['episodes'] as List<Episode>;
      Logger.info('🕒 [TIMING] 解析到 ${episodes.length} 个剧集');

      Logger.info(
        '播客实体: ${podcastEntity.title}, isSubscribed: ${podcastEntity.isSubscribed}',
      );

      final podcastId = await _localDataSource.savePodcast(podcastEntity);
      Logger.info('🕒 [TIMING] [${stopwatch.elapsedMilliseconds}ms] savePodcast 完成, podcastId=$podcastId');

      final episodesWithPodcastId = episodes.map((episode) {
        return Episode(
          id: episode.id,
          podcastId: podcastId,
          title: episode.title,
          description: episode.description,
          link: episode.link,
          guid: episode.guid,
          author: episode.author,
          pubDate: episode.pubDate,
          audioUrl: episode.audioUrl,
          audioType: episode.audioType,
          duration: episode.duration,
          artworkUrl: episode.artworkUrl,
          isExplicit: episode.isExplicit,
          isPlayed: episode.isPlayed,
          isDownloaded: episode.isDownloaded,
          downloadedPath: episode.downloadedPath,
          downloadProgress: episode.downloadProgress,
          playProgress: episode.playProgress,
          lastPlayedAt: episode.lastPlayedAt,
          createdAt: episode.createdAt,
          updatedAt: episode.updatedAt,
        );
      }).toList();
      Logger.info('🕒 [TIMING] [${stopwatch.elapsedMilliseconds}ms] episodesWithPodcastId map 完成');

      await _localDataSource.saveEpisodes(episodesWithPodcastId);
      Logger.info('🕒 [TIMING] [${stopwatch.elapsedMilliseconds}ms] saveEpisodes 完成, 保存了 ${episodesWithPodcastId.length} 个剧集');

      await _localDataSource.updatePodcastSubscription(podcastId, true);
      Logger.info('🕒 [TIMING] [${stopwatch.elapsedMilliseconds}ms] updatePodcastSubscription 完成');

      await _localDataSource.updatePodcastEpisodeCount(
        podcastId,
        episodes.length,
      );
      Logger.info('🕒 [TIMING] [${stopwatch.elapsedMilliseconds}ms] updatePodcastEpisodeCount 完成');

      final podcastModel = await _localDataSource.getPodcastById(podcastId);
      Logger.info('🕒 [TIMING] [${stopwatch.elapsedMilliseconds}ms] getPodcastById 完成');
      if (podcastModel == null) {
        throw AppException.unknown('保存播客后无法获取数据');
      }

      Logger.info(
        '获取到的播客模型: ${podcastModel.title}, isSubscribed: ${podcastModel.isSubscribed}, ID: ${podcastModel.id}',
      );

      final podcast = _convertPodcastModelToEntity(podcastModel);
      Logger.info('🕒 [TIMING] [${stopwatch.elapsedMilliseconds}ms] 订阅流程完成，即将返回 podcast');

      Logger.info('成功订阅播客: ${podcast.title} (总耗时: ${stopwatch.elapsedMilliseconds}ms)');

      return podcast;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('订阅播客失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '订阅播客失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    } finally {
      stopwatch.stop();
    }
  }

  @override
  Future<void> unsubscribe(int podcastId) async {
    try {
      Logger.info('开始取消订阅播客: $podcastId');

      final podcast = await _localDataSource.getPodcastById(podcastId);
      if (podcast == null) {
        throw AppException.validation('播客不存在');
      }

      final episodes = await _localDataSource.getEpisodesByPodcastId(podcastId);

      final pathsToDelete = episodes
          .where((e) => e.isDownloaded && e.downloadedPath != null)
          .map((e) => e.downloadedPath!)
          .toList();

      if (pathsToDelete.isNotEmpty) {
        final deletedCount = await _fileStorageService.deleteFilesSafely(
          pathsToDelete,
          context: 'unsubscribe podcast: $podcastId',
        );
        Logger.info('成功删除 $deletedCount/${pathsToDelete.length} 个节目文件');
      }

      await _localDataSource.deleteEpisodesByPodcastId(podcastId);

      await _localDataSource.deletePodcast(podcastId);

      Logger.info('成功取消订阅播客: ${podcast.title}');
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('取消订阅播客失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '取消订阅播客失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Podcast>> getSubscribedPodcasts() async {
    try {
      Logger.info('获取已订阅播客列表');

      final podcastModels = await _localDataSource.getSubscribedPodcasts();

      final podcasts = podcastModels
          .map((model) => _convertPodcastModelToEntity(model))
          .toList();

      Logger.info('成功获取 ${podcasts.length} 个已订阅播客');

      return podcasts;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('获取已订阅播客列表失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '获取已订阅播客列表失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Podcast?> getPodcastById(int id) async {
    try {
      Logger.info('根据 ID 获取播客: $id');

      final podcastModel = await _localDataSource.getPodcastById(id);

      if (podcastModel == null) {
        Logger.info('未找到 ID 为 $id 的播客');
        return null;
      }

      final podcast = _convertPodcastModelToEntity(podcastModel);

      Logger.info('成功获取播客: ${podcast.title}');

      return podcast;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('获取播客失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '获取播客失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Episode>> getEpisodesByPodcastId(int podcastId) async {
    try {
      Logger.info('获取播客的节目列表: $podcastId');

      final episodeModels = await _localDataSource.getEpisodesByPodcastId(
        podcastId,
      );

      final episodes = episodeModels
          .map((model) => _convertEpisodeModelToEntity(model))
          .toList();

      Logger.info('成功获取 ${episodes.length} 个节目');

      return episodes;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('获取节目列表失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '获取节目列表失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Episode>> getLatestEpisodesByPodcastId(
    int podcastId, {
    int limit = 3,
  }) async {
    try {
      Logger.info('获取播客最新 $limit 个节目: $podcastId');

      final episodeModels = await _localDataSource.getLatestEpisodesByPodcastId(
        podcastId,
        limit: limit,
      );

      final episodes = episodeModels
          .map((model) => _convertEpisodeModelToEntity(model))
          .toList();

      Logger.info('成功获取 ${episodes.length} 个最新节目');

      return episodes;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('获取最新节目列表失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '获取最新节目列表失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Episode>> getUnplayedEpisodes() async {
    try {
      Logger.info('获取未播放节目列表');

      final episodeModels = await _localDataSource.getUnplayedEpisodes();

      final episodes = episodeModels
          .map((model) => _convertEpisodeModelToEntity(model))
          .toList();

      Logger.info('成功获取 ${episodes.length} 个未播放节目');

      return episodes;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('获取未播放节目列表失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '获取未播放节目列表失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Episode>> getEpisodesByIds(List<int> ids) async {
    try {
      Logger.info('根据 IDs 获取节目列表');

      final episodeModels = await _localDataSource.getEpisodesByIds(ids);

      final episodes = episodeModels
          .map((model) => _convertEpisodeModelToEntity(model))
          .toList();

      Logger.info('成功获取 ${episodes.length} 个节目');

      return episodes;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('根据 IDs 获取节目列表失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '根据 IDs 获取节目列表失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Episode>> getDownloadedEpisodes() async {
    try {
      Logger.info('获取已下载节目列表');

      final episodeModels = await _localDataSource.getDownloadedEpisodes();

      final episodes = episodeModels
          .map((model) => _convertEpisodeModelToEntity(model))
          .toList();

      Logger.info('成功获取 ${episodes.length} 个已下载节目');

      return episodes;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('获取已下载节目列表失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '获取已下载节目列表失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Podcast>> searchPodcasts(String keyword) async {
    try {
      Logger.info('搜索播客: $keyword');

      final podcastModels = await _localDataSource.searchPodcasts(keyword);

      final podcasts = podcastModels
          .map((model) => _convertPodcastModelToEntity(model))
          .toList();

      Logger.info('成功搜索到 ${podcasts.length} 个播客');

      return podcasts;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('搜索播客失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '搜索播客失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Episode>> searchEpisodes(String keyword) async {
    try {
      Logger.info('搜索节目: $keyword');

      final episodeModels = await _localDataSource.searchEpisodes(keyword);

      final episodes = episodeModels
          .map((model) => _convertEpisodeModelToEntity(model))
          .toList();

      Logger.info('成功搜索到 ${episodes.length} 个节目');

      return episodes;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('搜索节目失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '搜索节目失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Podcast _convertPodcastModelToEntity(model.Podcast model) {
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
    );
  }

  @override
  Future<void> updateIsPlayed(int episodeId, bool isPlayed) async {
    Logger.info(
      '📋 [PODCAST-REPO] updateIsPlayed 调用, episodeId: $episodeId, isPlayed: $isPlayed',
    );
    await _localDataSource.updateIsPlayed(episodeId, isPlayed);
  }

  Episode _convertEpisodeModelToEntity(model.Episode model) {
    return Episode(
      id: model.id,
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
      downloadedPath: model.downloadedPath,
      artworkPath: model.artworkPath,
      downloadProgress: model.downloadProgress,
      playProgress: model.playProgress,
      lastPlayedAt: model.lastPlayedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
