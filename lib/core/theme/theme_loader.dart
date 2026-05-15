import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_theme_config.dart';

/// HOCON 轻量解析器
/// 支持：# 和 // 单行注释、嵌套对象语法、点号路径
class HoconParser {
  static Map<String, dynamic> parse(String content) {
    final lines = content.split('\n');
    final buffer = StringBuffer();

    for (final line in lines) {
      buffer.writeln(_stripComment(line));
    }

    final cleaned = buffer.toString().trim();
    final String jsonStr = cleaned.startsWith('{') ? cleaned : '{$cleaned}';

    final Map<String, dynamic> result =
        jsonDecode(jsonStr) as Map<String, dynamic>;
    return _expandDottedKeys(result);
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
  static const String _colorsPath = 'assets/themes/colors.conf';
  static const String _typographyPath = 'assets/themes/typography.conf';
  static const String _stylesPath = 'assets/themes/styles.conf';

  static Map<String, dynamic>? _cachedColorsJson;
  static Map<String, dynamic>? _cachedTypographyJson;
  static Map<String, dynamic>? _cachedStylesJson;

  static Map<String, AppThemeConfig>? _cachedThemeConfigs;
  static Map<String, Map<String, dynamic>>? _cachedWidgetStyles;

  static Map<String, AppThemeConfig> get cachedThemeConfigs =>
      _cachedThemeConfigs ?? _defaultThemeConfigs;

  static Map<String, Map<String, dynamic>> get cachedWidgetStyles =>
      _cachedWidgetStyles ?? {};

  static final Map<String, AppThemeConfig> _defaultThemeConfigs = {
    'light': const AppThemeConfig(
      name: 'Light',
      brandPrimary: AppColors.brandPrimaryLight,
      brandSecondary: AppColors.brandSecondaryLight,
      brandBlue: AppColors.brandBlueLight,
      backgroundPrimary: AppColors.backgroundPrimaryLight,
      backgroundSecondary: AppColors.backgroundSecondaryLight,
      backgroundTertiary: AppColors.backgroundTertiaryLight,
      grayBlack: AppColors.grayBlackLight,
      gray30: AppColors.gray30Light,
      labelPrimary: AppColors.labelPrimaryLight,
      labelSecondary: AppColors.labelSecondaryLight,
      labelTertiary: AppColors.labelTertiaryLight,
      labelQuaternary: AppColors.labelQuaternaryLight,
      overlayDefault: AppColors.overlayDefaultLight,
      overlayTransparent: AppColors.overlayTransparentLight,
    ),
    'dark': const AppThemeConfig(
      name: 'Dark',
      brandPrimary: AppColors.brandPrimaryDark,
      brandSecondary: AppColors.brandSecondaryDark,
      brandBlue: AppColors.brandBlueDark,
      backgroundPrimary: AppColors.backgroundPrimaryDark,
      backgroundSecondary: AppColors.backgroundSecondaryDark,
      backgroundTertiary: AppColors.backgroundTertiaryDark,
      grayBlack: AppColors.grayBlackDark,
      gray30: AppColors.gray30Dark,
      labelPrimary: AppColors.labelPrimaryDark,
      labelSecondary: AppColors.labelSecondaryDark,
      labelTertiary: AppColors.labelTertiaryDark,
      labelQuaternary: AppColors.labelQuaternaryDark,
      overlayDefault: AppColors.overlayDefaultDark,
      overlayTransparent: AppColors.overlayTransparentDark,
    ),
  };

  static Map<String, TextStyle> _buildTextStyles(
    Map<String, dynamic> typography,
    Map<String, AppThemeConfig> themeConfigs,
  ) {
    final textstyles = typography['textstyles'] as Map<String, dynamic>;
    final styles = <String, TextStyle>{};

    for (final entry in textstyles.entries) {
      final styleName = entry.key;
      final styleDef = entry.value as Map<String, dynamic>;

      Color getColorFromConfig(String palette, String name, bool isDark) {
        final theme = isDark ? 'dark' : 'light';
        return isDark
            ? themeConfigs['dark']!._getColorByName(palette, name)
            : themeConfigs['light']!._getColorByName(palette, name);
      }

      Color resolveColor(String colorKey) {
        final isDark = false;
        switch (colorKey) {
          case 'labelPrimary':
            return themeConfigs['light']!.labelPrimary;
          case 'labelSecondary':
            return themeConfigs['light']!.labelSecondary;
          case 'labelTertiary':
            return themeConfigs['light']!.labelTertiary;
          case 'labelQuaternary':
            return themeConfigs['light']!.labelQuaternary;
          case 'brandPrimary':
            return themeConfigs['light']!.brandPrimary;
          case 'brandSecondary':
            return themeConfigs['light']!.brandSecondary;
          case 'backgroundPrimary':
            return themeConfigs['light']!.backgroundPrimary;
          case 'backgroundSecondary':
            return themeConfigs['light']!.backgroundSecondary;
          default:
            return AppColors.labelPrimaryLight;
        }
      }

      void addStyle(String suffix, Map<String, dynamic> values) {
        final fontSize = double.tryParse(values['fontsize'] as String) ?? 14.0;
        final fontWeight = int.tryParse(values['fontweight'] as String) ?? 400;
        final lineHeight =
            double.tryParse(values['lineheight'] as String) ?? 1.4;
        final letterSpacing =
            double.tryParse(values['letterspacing'] as String) ?? 0.0;

        final colorKey = styleDef['color'] as String? ?? 'labelPrimary';

        if (suffix.isEmpty) {
          styles[styleName] = TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.values.firstWhere(
              (w) => w.index == fontWeight,
              orElse: () => FontWeight.w400,
            ),
            height: lineHeight,
            letterSpacing: letterSpacing,
            color: resolveColor(colorKey),
          );
        } else {
          styles['${styleName}_$suffix'] = TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.values.firstWhere(
              (w) => w.index == fontWeight,
              orElse: () => FontWeight.w400,
            ),
            height: lineHeight,
            letterSpacing: letterSpacing,
            color: resolveColor(colorKey),
          );
        }
      }

      if (styleDef.containsKey('desktop')) {
        addStyle('desktop', styleDef['desktop'] as Map<String, dynamic>);
        if (styleDef.containsKey('tablet')) {
          addStyle('tablet', styleDef['tablet'] as Map<String, dynamic>);
        }
        if (styleDef.containsKey('mobile')) {
          addStyle('mobile', styleDef['mobile'] as Map<String, dynamic>);
        }
      } else {
        addStyle('', styleDef);
      }
    }

    return styles;
  }

  static Map<String, AppThemeConfig> _buildThemeConfigs(
    Map<String, dynamic> json,
  ) {
    return {
      'light': AppThemeConfig.fromJsonWithMode(json, isDark: false),
      'dark': AppThemeConfig.fromJsonWithMode(json, isDark: true),
    };
  }

  static Future<void> preloadThemeConfigs() async {
    final colorsJson = await loadColors();
    _cachedThemeConfigs = _buildThemeConfigs(colorsJson);
    _cachedWidgetStyles = {};

    try {
      final typographyJson = await loadTypography();
      _cachedWidgetStyles!['textStyles'] = _buildTextStyles(
        typographyJson,
        _cachedThemeConfigs!,
      );
    } catch (_) {}

    try {
      _cachedStylesJson = await loadStyles();
      if (_cachedStylesJson != null &&
          _cachedStylesJson!.containsKey('widgets')) {
        _cachedWidgetStyles!['widgets'] =
            _cachedStylesJson!['widgets'] as Map<String, dynamic>;
      }
    } catch (_) {}
  }

  static Future<Map<String, dynamic>> loadColors() async {
    if (_cachedColorsJson != null) {
      return _cachedColorsJson!;
    }
    final String content = await rootBundle.loadString(_colorsPath);
    final Map<String, dynamic> json = HoconParser.parse(content);
    _cachedColorsJson = json;
    return json;
  }

  static Future<Map<String, dynamic>> loadTypography() async {
    if (_cachedTypographyJson != null) {
      return _cachedTypographyJson!;
    }
    final String content = await rootBundle.loadString(_typographyPath);
    final Map<String, dynamic> json = HoconParser.parse(content);
    _cachedTypographyJson = json;
    return json;
  }

  static Future<Map<String, dynamic>?> loadStyles() async {
    if (_cachedStylesJson != null) {
      return _cachedStylesJson!;
    }
    try {
      final String content = await rootBundle.loadString(_stylesPath);
      final Map<String, dynamic> json = HoconParser.parse(content);
      _cachedStylesJson = json;
      return json;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> load() async {
    return loadColors();
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
    _cachedColorsJson = null;
    _cachedTypographyJson = null;
    _cachedStylesJson = null;
    _cachedThemeConfigs = null;
    _cachedWidgetStyles = null;
  }
}

extension on AppThemeConfig {
  Color _getColorByName(String palette, String name) {
    switch ('$palette.$name') {
      case 'brand.primary':
        return brandPrimary;
      case 'brand.secondary':
        return brandSecondary;
      case 'brand.blue':
        return brandBlue;
      case 'background.primary':
        return backgroundPrimary;
      case 'background.secondary':
        return backgroundSecondary;
      case 'background.tertiary':
        return backgroundTertiary;
      case 'gray.black':
        return grayBlack;
      case 'gray.gray-30':
        return gray30;
      case 'label.primary':
        return labelPrimary;
      case 'label.secondary':
        return labelSecondary;
      case 'label.tertiary':
        return labelTertiary;
      case 'label.quaternary':
        return labelQuaternary;
      case 'overlay.default':
        return overlayDefault;
      case 'overlay.transparent':
        return overlayTransparent;
      default:
        return labelPrimary;
    }
  }
}
