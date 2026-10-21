import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/data/services/settings_service.dart';
import 'package:tinycast/domain/entities/app_settings.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/core/services/feed_refresh_scheduler.dart';
import 'package:tinycast/core/utils/app_window_context.dart';

enum SettingsStatus { initial, loading, success, error }

class SettingsState {
  final SettingsStatus status;
  final AppSettings settings;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.settings = const AppSettings(),
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    AppSettings? settings,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  final SettingsService _service = SettingsService.instance;
  StreamSubscription<AppSettings>? _subscription;

  @override
  Future<AppSettings> build() async {
    await _service.migrateFromSharedPreferences();

    _subscription = _service.watchSettings().listen(
      (settings) {
        state = AsyncData(settings);
      },
      onError: (error, stackTrace) {
        Logger.error('[SETTINGS-PROVIDER] Failed to watch settings', error: error, stackTrace: stackTrace);
      },
    );

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return _service.loadSettings();
  }

  Future<void> _restartFeedRefreshScheduler() async {
    if (!AppWindowContext.isMainWindow) return;
    FeedRefreshScheduler.instance.stop();
    await FeedRefreshScheduler.instance.start();
  }

  Future<void> updateDownloadOnFavorite(bool value) async {
    try {
      await _service.setDownloadOnFavorite(value);
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update downloadOnFavorite', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateRemovePlayedDownloads(bool value) async {
    try {
      await _service.setRemovePlayedDownloads(value);
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update removePlayedDownloads', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateAutoDownloadPolicy(AutoDownloadPolicy value) async {
    try {
      await _service.setAutoDownloadPolicy(value);
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update autoDownloadPolicy', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updatePlaybackSpeed(double value) async {
    try {
      await _service.setPlaybackSpeed(value);
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update playbackSpeed', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateSkipForwardTime(int value) async {
    try {
      await _service.setSkipForwardTime(value);
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update skipForwardTime', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateSkipBackwardTime(int value) async {
    try {
      await _service.setSkipBackwardTime(value);
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update skipBackwardTime', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateContinuousPlay(bool value) async {
    try {
      await _service.setContinuousPlay(value);
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update continuousPlay', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateVolume(double value) async {
    try {
      await _service.setVolume(value);
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update volume', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateSleepTimer(SleepTimerOption value, {int? endTimeMillis}) async {
    try {
      await _service.setSleepTimer(value);
      await _service.setSleepTimerEndTimeMillis(endTimeMillis);
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update sleepTimer', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateFeedRefreshInterval(FeedRefreshInterval value) async {
    try {
      await _service.setFeedRefreshInterval(value);
      await _restartFeedRefreshScheduler();
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update feedRefreshInterval', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateRefreshOnCellular(bool value) async {
    try {
      await _service.setRefreshOnCellular(value);
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update refreshOnCellular', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateNotifyOnNewEpisodes(bool value) async {
    try {
      await _service.setNotifyOnNewEpisodes(value);
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update notifyOnNewEpisodes', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateBackgroundRefreshEnabled(bool value) async {
    try {
      await _service.setBackgroundRefreshEnabled(value);
      await _restartFeedRefreshScheduler();
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update backgroundRefreshEnabled', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> clearSleepTimer() async {
    try {
      await _service.setSleepTimer(SleepTimerOption.off);
      await _service.setSleepTimerEndTimeMillis(null);
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to clear sleepTimer', error: e, stackTrace: stackTrace);
    }
  }
}
