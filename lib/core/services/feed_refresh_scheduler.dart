import 'dart:async';

import 'package:tinycast/core/services/network_connectivity_service.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/data/datasources/local_podcast_datasource.dart';
import 'package:tinycast/data/mappers/podcast_mapper.dart';
import 'package:tinycast/data/services/feed_refresh_service.dart';
import 'package:tinycast/data/services/settings_service.dart';
import 'package:tinycast/domain/entities/app_settings.dart';
import 'package:tinycast/domain/entities/podcast.dart';

class FeedRefreshScheduler {
  static const _logTag = '[FEED-REFRESH-SCHEDULER]';

  FeedRefreshScheduler._()
    : _feedRefreshService = FeedRefreshService.instance,
      _localPodcastDataSource = LocalPodcastDataSource(),
      _settingsService = SettingsService.instance,
      _networkConnectivityService = NetworkConnectivityService.instance;

  static final FeedRefreshScheduler _instance = FeedRefreshScheduler._();

  static FeedRefreshScheduler get instance => _instance;

  final FeedRefreshService _feedRefreshService;
  final LocalPodcastDataSource _localPodcastDataSource;
  final SettingsService _settingsService;
  final NetworkConnectivityService _networkConnectivityService;

  Timer? _timer;
  bool _isRunning = false;

  FeedRefreshScheduler({
    FeedRefreshService? feedRefreshService,
    LocalPodcastDataSource? localPodcastDataSource,
    SettingsService? settingsService,
    NetworkConnectivityService? networkConnectivityService,
  }) : _feedRefreshService = feedRefreshService ?? FeedRefreshService.instance,
       _localPodcastDataSource = localPodcastDataSource ?? LocalPodcastDataSource(),
       _settingsService = settingsService ?? SettingsService.instance,
       _networkConnectivityService = networkConnectivityService ??
           NetworkConnectivityService.instance;

  Future<void> start() async {
    if (_isRunning) {
      Logger.info('$_logTag 调度器已在运行，跳过启动');
      return;
    }

    final settings = await _settingsService.loadSettings();

    if (!settings.backgroundRefreshEnabled) {
      Logger.info('$_logTag 后台刷新已禁用，不启动调度器');
      return;
    }

    if (settings.feedRefreshInterval == FeedRefreshInterval.manual) {
      Logger.info('$_logTag 刷新间隔为手动模式，不启动定时器');
      return;
    }

    final interval = settings.feedRefreshInterval.toDuration;
    Logger.info('$_logTag 启动定时器，间隔: ${settings.feedRefreshInterval.name} ($interval)');

    _timer = Timer.periodic(interval, (_) => _onTimerTick());
    _isRunning = true;
  }

  void stop() {
    Logger.info('$_logTag 停止调度器');
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  Future<void> refreshNow() async {
    Logger.info('$_logTag 触发立即刷新');
    await _performRefresh();
  }

  bool get isRunning => _isRunning;

  Future<void> _onTimerTick() async {
    try {
      final settings = await _settingsService.loadSettings();

      if (!settings.backgroundRefreshEnabled) {
        Logger.info('$_logTag 定时器触发但后台刷新已禁用，停止调度器');
        stop();
        return;
      }

      final canRefresh = await _networkConnectivityService.canRefresh(
        settings.refreshOnCellular,
      );

      if (!canRefresh) {
        Logger.info('$_logTag 网络条件不满足刷新要求，跳过本次刷新');
        return;
      }

      await _performRefresh();
    } catch (e, stackTrace) {
      Logger.error(
        '$_logTag 定时器回调执行异常',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _performRefresh() async {
    try {
      final podcasts = await _getSubscribedPodcasts();

      if (podcasts.isEmpty) {
        Logger.info('$_logTag 无已订阅播客，跳过刷新');
        return;
      }

      Logger.info('$_logTag 开始刷新 ${podcasts.length} 个播客');

      final result = await _feedRefreshService.refreshAllFeeds(podcasts);

      Logger.info(
        '$_logTag 刷新完成: 总数 ${result.results.length}, '
        '成功 ${result.successCount}, '
        '失败 ${result.failureCount}, '
        '新剧集 ${result.totalNewEpisodes}',
      );
    } catch (e, stackTrace) {
      Logger.error(
        '$_logTag 刷新执行异常',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<Podcast>> _getSubscribedPodcasts() async {
    final podcastModels = await _localPodcastDataSource.getSubscribedPodcasts();
    return podcastModels.map((model) => PodcastMapper.toEntity(model)).toList();
  }

  void handleAppPaused() {
    Logger.info('$_logTag 应用进入后台，停止定时器');
    stop();
  }

  Future<void> handleAppResumed() async {
    Logger.info('$_logTag 应用恢复前台，重新启动定时器');
    stop();
    await start();
  }
}
