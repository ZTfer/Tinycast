import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/app_settings.dart';

class SettingsService {
  SettingsService._();

  static final SettingsService _instance = SettingsService._();

  static SettingsService get instance => _instance;

  static const String _settingsKey = 'app_settings';

  SharedPreferences? _prefs;

  Future<void> init() async {
    Logger.info('⚙️ [SETTINGS-SERVICE] ====== Initializing SharedPreferences ======');
    try {
      _prefs ??= await SharedPreferences.getInstance();
      Logger.info('⚙️ [SETTINGS-SERVICE] SharedPreferences initialized successfully');
    } catch (e, stackTrace) {
      Logger.error('⚙️ [SETTINGS-SERVICE] Failed to initialize SharedPreferences', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<AppSettings> loadSettings() async {
    Logger.info('⚙️ [SETTINGS-SERVICE] ====== Loading settings ======');
    await _ensureInitialized();

    try {
      final jsonString = _prefs!.getString(_settingsKey);
      if (jsonString != null) {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        final settings = AppSettings.fromJson(jsonMap);
        Logger.info('⚙️ [SETTINGS-SERVICE] Settings loaded from storage');
        return settings;
      }
    } catch (e) {
      Logger.warning('⚙️ [SETTINGS-SERVICE] Failed to load settings, returning defaults: $e');
    }

    final defaults = AppSettings();
    Logger.info('⚙️ [SETTINGS-SERVICE] Returning default settings');
    return defaults;
  }

  Future<void> saveSettings(AppSettings settings) async {
    Logger.info('⚙️ [SETTINGS-SERVICE] ====== Saving settings ======');
    await _ensureInitialized();

    try {
      final jsonString = jsonEncode(settings.toJson());
      await _prefs!.setString(_settingsKey, jsonString);
      Logger.info('⚙️ [SETTINGS-SERVICE] Settings saved successfully');
    } catch (e, stackTrace) {
      Logger.error('⚙️ [SETTINGS-SERVICE] Failed to save settings', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<bool> getDownloadOnFavorite() async {
    await _ensureInitialized();
    return _prefs!.getBool('download_on_favorite') ?? false;
  }

  Future<void> setDownloadOnFavorite(bool value) async {
    await _ensureInitialized();
    await _prefs!.setBool('download_on_favorite', value);
    Logger.info('⚙️ [SETTINGS-SERVICE] downloadOnFavorite set to: $value');
  }

  Future<bool> getRemovePlayedDownloads() async {
    await _ensureInitialized();
    return _prefs!.getBool('remove_played_downloads') ?? false;
  }

  Future<void> setRemovePlayedDownloads(bool value) async {
    await _ensureInitialized();
    await _prefs!.setBool('remove_played_downloads', value);
    Logger.info('⚙️ [SETTINGS-SERVICE] removePlayedDownloads set to: $value');
  }

  Future<AutoDownloadPolicy> getAutoDownloadPolicy() async {
    await _ensureInitialized();
    final raw = _prefs!.getString('auto_download_policy') ?? AutoDownloadPolicy.latest3.name;
    try {
      return AutoDownloadPolicy.values.byName(raw);
    } catch (_) {
      return AutoDownloadPolicy.latest3;
    }
  }

  Future<void> setAutoDownloadPolicy(AutoDownloadPolicy value) async {
    await _ensureInitialized();
    await _prefs!.setString('auto_download_policy', value.name);
    Logger.info('⚙️ [SETTINGS-SERVICE] autoDownloadPolicy set to: ${value.name}');
  }

  Future<double> getPlaybackSpeed() async {
    await _ensureInitialized();
    return _prefs!.getDouble('playback_speed') ?? 1.0;
  }

  Future<void> setPlaybackSpeed(double value) async {
    await _ensureInitialized();
    await _prefs!.setDouble('playback_speed', value);
    Logger.info('⚙️ [SETTINGS-SERVICE] playbackSpeed set to: $value');
  }

  Future<int> getSkipForwardTime() async {
    await _ensureInitialized();
    return _prefs!.getInt('skip_forward_time') ?? 30;
  }

  Future<void> setSkipForwardTime(int value) async {
    await _ensureInitialized();
    await _prefs!.setInt('skip_forward_time', value);
    Logger.info('⚙️ [SETTINGS-SERVICE] skipForwardTime set to: $value');
  }

  Future<int> getSkipBackwardTime() async {
    await _ensureInitialized();
    return _prefs!.getInt('skip_backward_time') ?? 15;
  }

  Future<void> setSkipBackwardTime(int value) async {
    await _ensureInitialized();
    await _prefs!.setInt('skip_backward_time', value);
    Logger.info('⚙️ [SETTINGS-SERVICE] skipBackwardTime set to: $value');
  }

  Future<bool> getContinuousPlay() async {
    await _ensureInitialized();
    return _prefs!.getBool('continuous_play') ?? true;
  }

  Future<void> setContinuousPlay(bool value) async {
    await _ensureInitialized();
    await _prefs!.setBool('continuous_play', value);
    Logger.info('⚙️ [SETTINGS-SERVICE] continuousPlay set to: $value');
  }

  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }
}
