import 'package:flutter/widgets.dart';
import 'theme_data.dart';

class AppTheme {
  AppTheme._();

  static AppThemeData get light => const AppThemeData(mode: AppThemeMode.light);
  static AppThemeData get dark => const AppThemeData(mode: AppThemeMode.dark);

  static AppThemeData fromBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
