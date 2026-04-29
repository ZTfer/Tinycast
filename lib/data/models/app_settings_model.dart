import 'package:isar_community/isar.dart';

part 'app_settings_model.g.dart';

@collection
class AppSettingsModel {
  Id id = 0;

  bool downloadOnFavorite = false;
  bool removePlayedDownloads = false;

  @Enumerated(EnumType.ordinal)
  AutoDownloadPolicyEnum autoDownloadPolicy = AutoDownloadPolicyEnum.latest3;

  double playbackSpeed = 1.0;
  double volume = 0.3;
  int skipForwardTime = 30;
  int skipBackwardTime = 15;
  bool continuousPlay = true;

  @Enumerated(EnumType.ordinal)
  SleepTimerEnum sleepTimer = SleepTimerEnum.off;

  int? sleepTimerEndTimeMillis;
}

enum AutoDownloadPolicyEnum {
  off,
  latest1,
  latest2,
  latest3,
  latest5,
  latest10,
  past24h,
  past7d,
  past14d,
  past30d,
  all,
}

enum SleepTimerEnum {
  off,
  min5,
  min10,
  min15,
  min30,
  min45,
  min60,
  episodeEnd;

  int? get minutes {
    switch (this) {
      case SleepTimerEnum.min5: return 5;
      case SleepTimerEnum.min10: return 10;
      case SleepTimerEnum.min15: return 15;
      case SleepTimerEnum.min30: return 30;
      case SleepTimerEnum.min45: return 45;
      case SleepTimerEnum.min60: return 60;
      default: return null;
    }
  }
}
