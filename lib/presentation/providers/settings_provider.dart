import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/settings_service.dart';
import '../../../domain/entities/app_settings.dart';
import '../../../core/utils/logger.dart';

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

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<SettingsState> {
  SettingsService get _service => SettingsService.instance;

  @override
  SettingsState build() {
    Future.microtask(() => loadSettings());
    return const SettingsState();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(status: SettingsStatus.loading, errorMessage: null);
    try {
      final settings = await _service.loadSettings();
      state = state.copyWith(status: SettingsStatus.success, settings: settings);
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to load settings', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        status: SettingsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateDownloadOnFavorite(bool value) async {
    try {
      await _service.setDownloadOnFavorite(value);
      state = state.copyWith(
        settings: state.settings.copyWith(downloadOnFavorite: value),
      );
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update downloadOnFavorite', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateRemovePlayedDownloads(bool value) async {
    try {
      await _service.setRemovePlayedDownloads(value);
      state = state.copyWith(
        settings: state.settings.copyWith(removePlayedDownloads: value),
      );
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update removePlayedDownloads', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateAutoDownloadPolicy(AutoDownloadPolicy value) async {
    try {
      await _service.setAutoDownloadPolicy(value);
      state = state.copyWith(
        settings: state.settings.copyWith(autoDownloadPolicy: value),
      );
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update autoDownloadPolicy', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updatePlaybackSpeed(double value) async {
    try {
      await _service.setPlaybackSpeed(value);
      state = state.copyWith(
        settings: state.settings.copyWith(playbackSpeed: value),
      );
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update playbackSpeed', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateSkipForwardTime(int value) async {
    try {
      await _service.setSkipForwardTime(value);
      state = state.copyWith(
        settings: state.settings.copyWith(skipForwardTime: value),
      );
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update skipForwardTime', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateSkipBackwardTime(int value) async {
    try {
      await _service.setSkipBackwardTime(value);
      state = state.copyWith(
        settings: state.settings.copyWith(skipBackwardTime: value),
      );
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update skipBackwardTime', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateContinuousPlay(bool value) async {
    try {
      await _service.setContinuousPlay(value);
      state = state.copyWith(
        settings: state.settings.copyWith(continuousPlay: value),
      );
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update continuousPlay', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateVolume(double value) async {
    try {
      await _service.setVolume(value);
      state = state.copyWith(
        settings: state.settings.copyWith(volume: value),
      );
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update volume', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateSleepTimer(SleepTimerOption value, {int? endTimeMillis}) async {
    try {
      await _service.setSleepTimer(value);
      await _service.setSleepTimerEndTimeMillis(endTimeMillis);
      state = state.copyWith(
        settings: state.settings.copyWith(
          sleepTimer: value,
          sleepTimerEndTimeMillis: endTimeMillis,
        ),
      );
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to update sleepTimer', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> clearSleepTimer() async {
    try {
      await _service.setSleepTimer(SleepTimerOption.off);
      await _service.setSleepTimerEndTimeMillis(null);
      state = state.copyWith(
        settings: state.settings.copyWith(
          sleepTimer: SleepTimerOption.off,
          sleepTimerEndTimeMillis: null,
        ),
      );
    } catch (e, stackTrace) {
      Logger.error('[SETTINGS-PROVIDER] Failed to clear sleepTimer', error: e, stackTrace: stackTrace);
    }
  }
}
