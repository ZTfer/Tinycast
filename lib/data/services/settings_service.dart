import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/app_settings.dart';

class SettingsService {
  SettingsService._();

  static final SettingsService _instance = SettingsService._();

  static SettingsService get instance => _instance;

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

  /// 从磁盘重新加载 SharedPreferences 数据（多窗口场景下确保读取最新值）
  /// 注意：使用 SharedPreferences.reload() 比重新创建实例更高效
  Future<void> _reloadPrefs() async {
    if (_prefs == null) {
      Logger.warning('⚙️ [SETTINGS-SERVICE] SharedPreferences not initialized, skipping reload');
      return;
    }
    Logger.info('⚙️ [SETTINGS-SERVICE] ====== Reloading SharedPreferences from disk ======');
    await _prefs!.reload();
    Logger.info('⚙️ [SETTINGS-SERVICE] SharedPreferences reloaded');
  }

  Future<AppSettings> loadSettings() async {
    Logger.info('⚙️ [SETTINGS-SERVICE] ====== Loading settings ======');
    await _ensureInitialized();
    
    // 多窗口场景下，从磁盘重新加载以读取最新值
    await _reloadPrefs();

    final rawPolicy = _prefs!.getString('auto_download_policy');
    Logger.info('⚙️ [SETTINGS-SERVICE] Raw auto_download_policy from prefs: $rawPolicy');

    return AppSettings(
      downloadOnFavorite: _prefs!.getBool('download_on_favorite') ?? false,
      removePlayedDownloads: _prefs!.getBool('remove_played_downloads') ?? false,
      autoDownloadPolicy: _parseAutoDownloadPolicy(rawPolicy),
      playbackSpeed: _prefs!.getDouble('playback_speed') ?? 1.0,
      volume: _prefs!.getDouble('volume') ?? 0.3,
      skipForwardTime: _prefs!.getInt('skip_forward_time') ?? 30,
      skipBackwardTime: _prefs!.getInt('skip_backward_time') ?? 15,
      continuousPlay: _prefs!.getBool('continuous_play') ?? true,
    );
  }

  Future<void> setDownloadOnFavorite(bool value) async {
    await _ensureInitialized();
    await _prefs!.setBool('download_on_favorite', value);
    Logger.info('⚙️ [SETTINGS-SERVICE] downloadOnFavorite set to: $value');
  }

  Future<void> setRemovePlayedDownloads(bool value) async {
    await _ensureInitialized();
    await _prefs!.setBool('remove_played_downloads', value);
    Logger.info('⚙️ [SETTINGS-SERVICE] removePlayedDownloads set to: $value');
  }

  Future<void> setAutoDownloadPolicy(AutoDownloadPolicy value) async {
    await _ensureInitialized();
    final key = 'auto_download_policy';
    final oldValue = _prefs!.getString(key);
    await _prefs!.setString(key, value.name);
    final newValue = _prefs!.getString(key);
    Logger.info('⚙️ [SETTINGS-SERVICE] autoDownloadPolicy: old=$oldValue, new=$newValue');
  }

  Future<void> setPlaybackSpeed(double value) async {
    await _ensureInitialized();
    await _prefs!.setDouble('playback_speed', value);
    Logger.info('⚙️ [SETTINGS-SERVICE] playbackSpeed set to: $value');
  }

  Future<void> setVolume(double value) async {
    await _ensureInitialized();
    await _prefs!.setDouble('volume', value);
    Logger.info('⚙️ [SETTINGS-SERVICE] volume set to: $value');
  }

  Future<double> getVolume() async {
    await _ensureInitialized();
    await _reloadPrefs();
    return _prefs!.getDouble('volume') ?? 0.3;
  }

  Future<void> setSkipForwardTime(int value) async {
    await _ensureInitialized();
    await _prefs!.setInt('skip_forward_time', value);
    Logger.info('⚙️ [SETTINGS-SERVICE] skipForwardTime set to: $value');
  }

  Future<int> getSkipForwardTime() async {
    await _ensureInitialized();
    // 多窗口场景下，从磁盘重新加载以读取最新值
    await _reloadPrefs();
    return _prefs!.getInt('skip_forward_time') ?? 30;
  }

  Future<void> setSkipBackwardTime(int value) async {
    await _ensureInitialized();
    await _prefs!.setInt('skip_backward_time', value);
    Logger.info('⚙️ [SETTINGS-SERVICE] skipBackwardTime set to: $value');
  }

  Future<int> getSkipBackwardTime() async {
    await _ensureInitialized();
    // 多窗口场景下，从磁盘重新加载以读取最新值
    await _reloadPrefs();
    return _prefs!.getInt('skip_backward_time') ?? 15;
  }

  Future<void> setContinuousPlay(bool value) async {
    await _ensureInitialized();
    await _prefs!.setBool('continuous_play', value);
    Logger.info('⚙️ [SETTINGS-SERVICE] continuousPlay set to: $value');
  }

  Future<bool> getRemovePlayedDownloads() async {
    await _ensureInitialized();
    // 多窗口场景下，从磁盘重新加载以读取最新值
    await _reloadPrefs();
    return _prefs!.getBool('remove_played_downloads') ?? false;
  }

  Future<bool> getDownloadOnFavorite() async {
    await _ensureInitialized();
    // 多窗口场景下，从磁盘重新加载以读取最新值
    await _reloadPrefs();
    return _prefs!.getBool('download_on_favorite') ?? false;
  }

  AutoDownloadPolicy _parseAutoDownloadPolicy(String? raw) {
    if (raw == null) return AutoDownloadPolicy.latest3;
    try {
      return AutoDownloadPolicy.values.byName(raw);
    } catch (_) {
      return AutoDownloadPolicy.latest3;
    }
  }

  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }
}
