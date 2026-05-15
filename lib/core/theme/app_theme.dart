import 'package:flutter/widgets.dart';
import 'theme_data.dart';
import 'theme_source_flag.dart';

class AppTheme {
  AppTheme._();

  static AppThemeData get light => AppThemeData.fromSource(
        mode: AppThemeMode.light,
        useHardcoded: ThemeSource.useHardcoded,
      );

  static AppThemeData get dark => AppThemeData.fromSource(
        mode: AppThemeMode.dark,
        useHardcoded: ThemeSource.useHardcoded,
      );

  static AppThemeData fromBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
