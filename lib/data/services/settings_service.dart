import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/data/database/isar_service.dart';
import 'package:tinycast/data/models/app_settings_model.dart';
import 'package:tinycast/domain/entities/app_settings.dart';

class SettingsService {
  SettingsService._();

  static final SettingsService _instance = SettingsService._();

  static SettingsService get instance => _instance;

  Isar get _isar => IsarService.instance.isar;

  /// 读取设置（从 Isar 读取，无需 reload）
  Future<AppSettings> loadSettings() async {
    final model = await _isar.appSettingsModels.where().findFirst();
    if (model == null) {
      return const AppSettings();
    }

    return AppSettings(
      downloadOnFavorite: model.downloadOnFavorite,
      removePlayedDownloads: model.removePlayedDownloads,
      autoDownloadPolicy: _mapAutoDownloadPolicy(model.autoDownloadPolicy),
      playbackSpeed: model.playbackSpeed,
      volume: model.volume,
      skipForwardTime: model.skipForwardTime,
      skipBackwardTime: model.skipBackwardTime,
      continuousPlay: model.continuousPlay,
      sleepTimer: _mapSleepTimer(model.sleepTimer),
      sleepTimerEndTimeMillis: model.sleepTimerEndTimeMillis,
    );
  }

  /// 监听设置变更（Stream，用于多窗口自动同步）
  Stream<AppSettings> watchSettings() {
    return _isar.appSettingsModels.where().watch(fireImmediately: true).map((models) {
      final model = models.isEmpty ? AppSettingsModel() : models.first;
      return AppSettings(
        downloadOnFavorite: model.downloadOnFavorite,
        removePlayedDownloads: model.removePlayedDownloads,
        autoDownloadPolicy: _mapAutoDownloadPolicy(model.autoDownloadPolicy),
        playbackSpeed: model.playbackSpeed,
        volume: model.volume,
        skipForwardTime: model.skipForwardTime,
        skipBackwardTime: model.skipBackwardTime,
        continuousPlay: model.continuousPlay,
        sleepTimer: _mapSleepTimer(model.sleepTimer),
        sleepTimerEndTimeMillis: model.sleepTimerEndTimeMillis,
      );
    });
  }

  Future<void> _saveModel(AppSettingsModel model) async {
    await _isar.writeTxn(() async {
      await _isar.appSettingsModels.put(model);
    });
  }

  Future<AppSettingsModel> _getOrCreateModel() async {
    var model = await _isar.appSettingsModels.where().findFirst();
    if (model == null) {
      model = AppSettingsModel();
      await _saveModel(model);
    }
    return model;
  }

  Future<void> setDownloadOnFavorite(bool value) async {
    final model = await _getOrCreateModel();
    model.downloadOnFavorite = value;
    await _saveModel(model);
    Logger.info('⚙️ [SETTINGS-SERVICE] downloadOnFavorite set to: $value');
  }

  Future<void> setRemovePlayedDownloads(bool value) async {
    final model = await _getOrCreateModel();
    model.removePlayedDownloads = value;
    await _saveModel(model);
    Logger.info('⚙️ [SETTINGS-SERVICE] removePlayedDownloads set to: $value');
  }

  Future<void> setAutoDownloadPolicy(AutoDownloadPolicy value) async {
    final model = await _getOrCreateModel();
    model.autoDownloadPolicy = _mapAutoDownloadPolicyToIsar(value);
    await _saveModel(model);
    Logger.info('⚙️ [SETTINGS-SERVICE] autoDownloadPolicy set to: ${value.name}');
  }

  Future<void> setPlaybackSpeed(double value) async {
    final model = await _getOrCreateModel();
    model.playbackSpeed = value;
    await _saveModel(model);
    Logger.info('⚙️ [SETTINGS-SERVICE] playbackSpeed set to: $value');
  }

  Future<void> setVolume(double value) async {
    final model = await _getOrCreateModel();
    model.volume = value;
    await _saveModel(model);
    Logger.info('⚙️ [SETTINGS-SERVICE] volume set to: $value');
  }

  Future<void> setSkipForwardTime(int value) async {
    final model = await _getOrCreateModel();
    model.skipForwardTime = value;
    await _saveModel(model);
    Logger.info('⚙️ [SETTINGS-SERVICE] skipForwardTime set to: $value');
  }

  Future<void> setSkipBackwardTime(int value) async {
    final model = await _getOrCreateModel();
    model.skipBackwardTime = value;
    await _saveModel(model);
    Logger.info('⚙️ [SETTINGS-SERVICE] skipBackwardTime set to: $value');
  }

  Future<void> setContinuousPlay(bool value) async {
    final model = await _getOrCreateModel();
    model.continuousPlay = value;
    await _saveModel(model);
    Logger.info('⚙️ [SETTINGS-SERVICE] continuousPlay set to: $value');
  }

  Future<void> setSleepTimer(SleepTimerOption value) async {
    final model = await _getOrCreateModel();
    model.sleepTimer = _mapSleepTimerToIsar(value);
    await _saveModel(model);
    Logger.info('⚙️ [SETTINGS-SERVICE] sleepTimer set to: ${value.name}');
  }

  Future<void> setSleepTimerEndTimeMillis(int? value) async {
    final model = await _getOrCreateModel();
    model.sleepTimerEndTimeMillis = value;
    await _saveModel(model);
    Logger.info('⚙️ [SETTINGS-SERVICE] sleepTimerEndTimeMillis set to: $value');
  }

  /// 首次启动时从 SharedPreferences 迁移数据到 Isar
  Future<void> migrateFromSharedPreferences() async {
    final existing = await _isar.appSettingsModels.where().findFirst();
    if (existing != null) {
      return; // 已迁移过，跳过
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final model = AppSettingsModel()
        ..downloadOnFavorite = prefs.getBool('download_on_favorite') ?? false
        ..removePlayedDownloads = prefs.getBool('remove_played_downloads') ?? false
        ..autoDownloadPolicy = _parseAutoDownloadPolicy(
            prefs.getString('auto_download_policy'))
        ..playbackSpeed = prefs.getDouble('playback_speed') ?? AppSettings.defaultPlaybackSpeed
        ..volume = prefs.getDouble('volume') ?? AppSettings.defaultVolume
        ..skipForwardTime = prefs.getInt('skip_forward_time') ?? AppSettings.defaultSkipForwardTime
        ..skipBackwardTime = prefs.getInt('skip_backward_time') ?? AppSettings.defaultSkipBackwardTime
        ..continuousPlay = prefs.getBool('continuous_play') ?? true
        ..sleepTimer = _parseSleepTimer(prefs.getString('sleep_timer'))
        ..sleepTimerEndTimeMillis = prefs.getInt('sleep_timer_end_time_millis');

      await _saveModel(model);
      Logger.info('⚙️ [SETTINGS-SERVICE] Migrated settings from SharedPreferences to Isar');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to migrate settings from SharedPreferences',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  AutoDownloadPolicyEnum _mapAutoDownloadPolicyToIsar(AutoDownloadPolicy policy) {
    return AutoDownloadPolicyEnum.values.byName(policy.name);
  }

  AutoDownloadPolicy _mapAutoDownloadPolicy(AutoDownloadPolicyEnum policy) {
    return AutoDownloadPolicy.values.byName(policy.name);
  }

  AutoDownloadPolicyEnum _parseAutoDownloadPolicy(String? raw) {
    if (raw == null) return AutoDownloadPolicyEnum.latest3;
    try {
      return AutoDownloadPolicyEnum.values.byName(raw);
    } catch (_) {
      return AutoDownloadPolicyEnum.latest3;
    }
  }

  SleepTimerEnum _mapSleepTimerToIsar(SleepTimerOption option) {
    return SleepTimerEnum.values.byName(option.name);
  }

  SleepTimerOption _mapSleepTimer(SleepTimerEnum option) {
    return SleepTimerOption.values.byName(option.name);
  }

  SleepTimerEnum _parseSleepTimer(String? raw) {
    if (raw == null) return SleepTimerEnum.off;
    try {
      return SleepTimerEnum.values.byName(raw);
    } catch (_) {
      return SleepTimerEnum.off;
    }
  }
}
