import 'dart:convert';
import 'package:flutter/services.dart';
import 'app_theme_config.dart';

/// HOCON 轻量解析器
/// 支持：# 和 // 单行注释、点号路径展开（a.b.c = "x" → {a:{b:{c:"x"}}}）
class HoconParser {
  static Map<String, dynamic> parse(String content) {
    final lines = content.split('\n');
    final buffer = StringBuffer();

    for (final line in lines) {
      buffer.writeln(_stripComment(line));
    }

    final cleaned = buffer.toString().trim();
    final String jsonStr = cleaned.startsWith('{') ? cleaned : '{$cleaned}';
    return _expandDottedKeys(jsonDecode(jsonStr) as Map<String, dynamic>);
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

  static Map<String, dynamic> _expandDottedKeys(Map<String, dynamic> map) {
    final result = <String, dynamic>{};

    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is Map) {
        final expanded = _expandDottedKeys(value as Map<String, dynamic>);
        result[key] = _merge(result[key], expanded);
      } else if (key.contains('.')) {
        final parts = key.split('.');
        _setNested(result, parts, value);
      } else {
        result[key] = value;
      }
    }

    return result;
  }

  static void _setNested(
    Map<String, dynamic> target,
    List<String> parts,
    dynamic value,
  ) {
    Map<String, dynamic> current = target;
    for (int i = 0; i < parts.length - 1; i++) {
      if (!current.containsKey(parts[i]) ||
          current[parts[i]] is! Map<String, dynamic>) {
        current[parts[i]] = <String, dynamic>{};
      }
      current = current[parts[i]] as Map<String, dynamic>;
    }
    current[parts.last] = value;
  }

  static dynamic _merge(dynamic existing, dynamic incoming) {
    if (existing is Map<String, dynamic> && incoming is Map<String, dynamic>) {
      final merged = Map<String, dynamic>.from(existing);
      for (final entry in incoming.entries) {
        merged[entry.key] = _merge(merged[entry.key], entry.value);
      }
      return merged;
    }
    return incoming;
  }
}

class ThemeLoader {
  static const String _themePath = 'assets/themes/colors.conf';

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
