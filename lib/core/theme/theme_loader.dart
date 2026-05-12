import 'dart:convert';
import 'package:flutter/services.dart';
import 'app_theme_config.dart';

/// HOCON 轻量解析器：移除注释后按 JSON 解析
/// 支持 # 和 // 单行注释，不支持多行注释和 include
class HoconParser {
  static Map<String, dynamic> parse(String content) {
    final lines = content.split('\n');
    final buffer = StringBuffer();

    for (final line in lines) {
      buffer.writeln(_stripComment(line));
    }

    final cleaned = buffer.toString();
    return jsonDecode(cleaned) as Map<String, dynamic>;
  }

  static String _stripComment(String line) {
    bool inString = false;
    for (int i = 0; i < line.length; i++) {
      if (line[i] == '"' && (i == 0 || line[i - 1] != '\\')) {
        inString = !inString;
      } else if (!inString && i + 1 < line.length) {
        if (line[i] == '/' && line[i + 1] == '/') {
          return line.substring(0, i);
        }
        if (line[i] == '#') {
          return line.substring(0, i);
        }
      }
    }
    return line;
  }
}

class ThemeLoader {
  static const String _themePath = 'assets/themes/colors.hocon';

  static Map<String, dynamic>? _cachedJson;

  static Future<Map<String, dynamic>> load() async {
    if (_cachedJson != null) {
      return _cachedJson!;
    }

    final String content = await rootBundle.loadString(_themePath);
    final Map<String, dynamic> json = HoconParser.parse(content);
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
