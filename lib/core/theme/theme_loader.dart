import 'dart:convert';
import 'package:flutter/services.dart';
import 'app_theme_config.dart';

class ThemeLoader {
  static const String _themePath = 'assets/themes/colors.json';

  static Map<String, dynamic>? _cachedJson;

  static Future<Map<String, dynamic>> load() async {
    if (_cachedJson != null) {
      return _cachedJson!;
    }

    final String jsonString = await rootBundle.loadString(_themePath);
    final Map<String, dynamic> json =
        jsonDecode(jsonString) as Map<String, dynamic>;
    _cachedJson = json;
    return json;
  }

  static Map<String, dynamic> _getColor(
    Map<String, dynamic> json,
    String palette,
    String name,
  ) {
    final Map<String, dynamic> palettes =
        json['palettes'] as Map<String, dynamic>;
    return palettes[palette][name] as Map<String, dynamic>;
  }

  static String getLightColor(
    Map<String, dynamic> json,
    String palette,
    String name,
  ) {
    final Map<String, dynamic> colorEntry = _getColor(json, palette, name);
    return colorEntry['light'] as String;
  }

  static String getDarkColor(
    Map<String, dynamic> json,
    String palette,
    String name,
  ) {
    final Map<String, dynamic> colorEntry = _getColor(json, palette, name);
    return colorEntry['dark'] as String;
  }

  static Future<AppThemeConfig> loadThemeConfig({bool isDark = false}) async {
    final json = await load();
    return AppThemeConfig.fromJsonWithMode(json, isDark: isDark);
  }

  static Future<Map<String, AppThemeConfig>> loadAllThemeConfigs() async {
    final json = await load();
    return {
      'light': AppThemeConfig.fromJsonWithMode(json, isDark: false),
      'dark': AppThemeConfig.fromJsonWithMode(json, isDark: true),
    };
  }

  static void clearCache() {
    _cachedJson = null;
  }
}
