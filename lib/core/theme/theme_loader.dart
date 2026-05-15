import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'app_colors.dart';
import 'app_theme_config.dart';

void _debug(String msg) {
  debugPrint('[ThemeLoader] $msg');
}

/// HOCON 轻量解析器
/// 支持：# 和 // 单行注释、嵌套对象语法、点号路径、include、${} 引用
class HoconParser {
  static Map<String, dynamic> parse(String content) {
    final tokens = _tokenize(content);
    final result = _parseObject(tokens);
    return _resolveReferences(result);
  }

  static List<_Token> _tokenize(String content) {
    final lines = content.split('\n');
    final tokens = <_Token>[];

    for (final rawLine in lines) {
      final line = _stripComment(rawLine).trim();
      if (line.isEmpty) continue;

      if (line.startsWith('include')) {
        final match = RegExp(r'include\s+"([^"]+)"').firstMatch(line);
        if (match != null) {
          tokens.add(_IncludeToken(match.group(1)!));
        }
        continue;
      }

      final hasOpenBrace =
          line.contains('{') && !_isInsideRef(line, line.indexOf('{'));
      final hasCloseBrace =
          line.contains('}') && !_isInsideRef(line, line.indexOf('}'));

      if (hasOpenBrace) {
        final before = line.substring(0, line.indexOf('{')).trim();
        if (before.isNotEmpty) {
          tokens.add(_KeyToken(before));
        }
        tokens.add(_OpenBraceToken());

        final after = line.substring(line.indexOf('{') + 1).trim();
        if (after.isNotEmpty && !after.startsWith('}')) {
          final kv = RegExp(r'^([\w-]+)\s*=\s*(.+)$').firstMatch(after);
          if (kv != null) {
            tokens.add(_KeyValueToken(kv.group(1)!, kv.group(2)!.trim()));
          }
        }
      } else if (hasCloseBrace) {
        final before = line.substring(0, line.indexOf('}')).trim();
        if (before.isNotEmpty) {
          final kv = RegExp(r'^([\w-]+)\s*=\s*(.+)$').firstMatch(before);
          if (kv != null) {
            tokens.add(_KeyValueToken(kv.group(1)!, kv.group(2)!.trim()));
          }
        }
        tokens.add(_CloseBraceToken());
      } else {
        final kv = RegExp(r'^([\w-]+)\s*=\s*(.+)$').firstMatch(line);
        if (kv != null) {
          tokens.add(_KeyValueToken(kv.group(1)!, kv.group(2)!.trim()));
        }
      }
    }

    return tokens;
  }

  static bool _isInsideRef(String line, int braceIndex) {
    bool foundOpenRef = false;
    for (int i = 0; i < braceIndex; i++) {
      if (line.codeUnitAt(i) == 36 &&
          i + 1 < line.length &&
          line.codeUnitAt(i + 1) == 123) {
        foundOpenRef = true;
      } else if (line.codeUnitAt(i) == 125 && foundOpenRef) {
        foundOpenRef = false;
      }
    }
    return foundOpenRef;
  }

  static String _stripComment(String line) {
    bool inString = false;
    bool inRef = false;
    for (int i = 0; i < line.length; i++) {
      if (line[i] == '"' && (i == 0 || line[i - 1] != '\\')) {
        inString = !inString;
      }
      if (!inString) {
        if (line[i] == '\$' && i + 1 < line.length && line[i + 1] == '{') {
          inRef = true;
        }
        if (inRef && line[i] == '}') {
          inRef = false;
        }
        if (!inRef && i + 1 < line.length) {
          if (line[i] == '/' && line[i + 1] == '/') {
            return line.substring(0, i);
          }
          if (line[i] == '#') {
            return line.substring(0, i);
          }
        }
      }
    }
    return line;
  }

  static String _stripQuotes(String value) {
    if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }

  static Map<String, dynamic> _parseObject(List<_Token> tokens) {
    final result = <String, dynamic>{};
    var i = 0;
    final stack = [result];
    final keys = <String?>[];

    while (i < tokens.length) {
      final token = tokens[i];
      if (token is _IncludeToken) {
        i++;
        continue;
      } else if (token is _OpenBraceToken) {
        if (keys.isNotEmpty) {
          final parent = stack.last;
          final key = keys.removeLast();
          if (key != null) {
            final child = <String, dynamic>{};
            parent[key] = child;
            stack.add(child);
          }
        }
      } else if (token is _CloseBraceToken) {
        if (stack.length > 1) stack.removeLast();
      } else if (token is _KeyToken) {
        keys.add(token.key);
      } else if (token is _KeyValueToken) {
        stack.last[token.key] = _stripQuotes(token.value);
      }
      i++;
    }

    return result;
  }

  static Future<Map<String, dynamic>> _loadWithIncludes(String rootPath) async {
    final content = await rootBundle.loadString(rootPath);
    final tokens = HoconParser._tokenize(content);

    Map<String, dynamic> merged = {};

    for (final token in tokens) {
      if (token is _IncludeToken) {
        final includePath = token.path;
        final basePath = rootPath.substring(0, rootPath.lastIndexOf('/'));
        final fullPath = '$basePath/$includePath';
        try {
          final includeContent = await rootBundle.loadString(fullPath);
          final includeTokens = HoconParser._tokenize(includeContent);
          final included = HoconParser._parseObject(includeTokens);
          _deepMerge(merged, included);
        } catch (e) {
          _debug('include error: $e');
        }
      }
    }

    final parsed = HoconParser._parseObject(tokens);
    _deepMerge(merged, parsed);

    final resolved = HoconParser._resolveReferences(merged);

    if (resolved.containsKey('widgets')) {
      final widgets = resolved['widgets'] as Map<String, dynamic>;
      for (final wEntry in widgets.entries) {
        final widgetName = wEntry.key;
        final sections = wEntry.value as Map<String, dynamic>;
        for (final sEntry in sections.entries) {
          _debug('$widgetName.${sEntry.key}: ${sEntry.value}');
        }
      }
    }

    return resolved;
  }

  static void _deepMerge(
    Map<String, dynamic> target,
    Map<String, dynamic> source,
  ) {
    for (final entry in source.entries) {
      if (entry.value is Map<String, dynamic> &&
          target[entry.key] is Map<String, dynamic>) {
        _deepMerge(
          target[entry.key] as Map<String, dynamic>,
          entry.value as Map<String, dynamic>,
        );
      } else {
        target[entry.key] = entry.value;
      }
    }
  }

  static Map<String, dynamic> _resolveReferences(Map<String, dynamic> root) {
    return _resolveRefsInMap(root, root, null);
  }

  static dynamic _resolveRefsInMap(
    Map<String, dynamic> map,
    Map<String, dynamic> root,
    String? currentPath,
  ) {
    final result = <String, dynamic>{};

    for (final entry in map.entries) {
      final path = currentPath != null
          ? '$currentPath.${entry.key}'
          : entry.key;

      if (entry.value is Map<String, dynamic>) {
        result[entry.key] = _resolveRefsInMap(
          entry.value as Map<String, dynamic>,
          root,
          path,
        );
      } else if (entry.value is String) {
        result[entry.key] = _resolveRefValue(entry.value as String, root);
      } else {
        result[entry.key] = entry.value;
      }
    }

    return result;
  }

  static String _resolveRefValue(String value, Map<String, dynamic> root) {
    final refMatch = RegExp(r'^\$\{([^}]+)\}$').firstMatch(value);
    if (refMatch != null) {
      final refPath = refMatch.group(1)!;
      final result = _lookupPath(root, refPath.split('.'));
      _debug('  resolve: $value -> $refPath -> "$result"');
      return result;
    }
    return value;
  }

  static String _lookupPath(Map<String, dynamic> root, List<String> parts) {
    dynamic current = root;
    for (final part in parts) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        _debug('    lookup failed at: ${parts.join('.')} (current key: $part)');
        return '';
      }
    }
    return current is String ? current : current.toString();
  }
}

sealed class _Token {}

class _IncludeToken extends _Token {
  final String path;
  _IncludeToken(this.path);
}

class _KeyToken extends _Token {
  final String key;
  _KeyToken(this.key);
}

class _KeyValueToken extends _Token {
  final String key;
  final String value;
  _KeyValueToken(this.key, this.value);
}

class _OpenBraceToken extends _Token {}

class _CloseBraceToken extends _Token {}

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

      Color resolveColor(String colorKey, String brightness) {
        final config = themeConfigs[brightness]!;
        switch (colorKey) {
          case 'labelPrimary':
            return config.labelPrimary;
          case 'labelSecondary':
            return config.labelSecondary;
          case 'labelTertiary':
            return config.labelTertiary;
          case 'labelQuaternary':
            return config.labelQuaternary;
          case 'brandPrimary':
            return config.brandPrimary;
          case 'brandSecondary':
            return config.brandSecondary;
          case 'backgroundPrimary':
            return config.backgroundPrimary;
          case 'backgroundSecondary':
            return config.backgroundSecondary;
          default:
            return brightness == 'light'
                ? AppColors.labelPrimaryLight
                : AppColors.labelPrimaryDark;
        }
      }

      TextStyle buildStyle(Map<String, dynamic> values, String brightness) {
        final fontSize = double.tryParse(values['fontsize'] as String) ?? 14.0;
        final fontWeight = int.tryParse(values['fontweight'] as String) ?? 400;
        final lineHeight =
            double.tryParse(values['lineheight'] as String) ?? 1.4;
        final letterSpacing =
            double.tryParse(values['letterspacing'] as String) ?? 0.0;

        final colorKey = styleDef['color'] as String? ?? 'labelPrimary';

        return TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.values.firstWhere(
            (w) => w.value == fontWeight,
            orElse: () => FontWeight.w400,
          ),
          height: lineHeight,
          letterSpacing: letterSpacing,
          color: resolveColor(colorKey, brightness),
        );
      }

      void addStylePair(String suffix, Map<String, dynamic> values) {
        final lightStyle = buildStyle(values, 'light');
        final darkStyle = buildStyle(values, 'dark');

        if (suffix.isEmpty) {
          styles['${styleName}_light'] = lightStyle;
          styles['${styleName}_dark'] = darkStyle;
        } else {
          styles['${styleName}_${suffix}_light'] = lightStyle;
          styles['${styleName}_${suffix}_dark'] = darkStyle;
        }
      }

      if (styleDef.containsKey('desktop')) {
        addStylePair('desktop', styleDef['desktop'] as Map<String, dynamic>);
        if (styleDef.containsKey('tablet')) {
          addStylePair('tablet', styleDef['tablet'] as Map<String, dynamic>);
        }
        if (styleDef.containsKey('mobile')) {
          addStylePair('mobile', styleDef['mobile'] as Map<String, dynamic>);
        }
      } else {
        addStylePair('', styleDef);
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
      final stylesJson = await loadStyles();
      _debug('stylesJson keys: ${stylesJson?.keys.toList()}');

      if (stylesJson != null) {
        _cachedWidgetStyles = {'styles': stylesJson};

        final widgetTextStyles = _buildWidgetTextStyles(
          stylesJson,
          _cachedThemeConfigs!,
        );
        _debug('widgetTextStyles keys: ${widgetTextStyles.keys.toList()}');
        _cachedWidgetStyles!['widgetTextStyles'] = widgetTextStyles;
      }
    } catch (e, stack) {
      _debug('preload error: $e\n$stack');
    }
  }

  static Map<String, TextStyle> _buildWidgetTextStyles(
    Map<String, dynamic> stylesJson,
    Map<String, AppThemeConfig> themeConfigs,
  ) {
    final result = <String, TextStyle>{};

    for (final entry in stylesJson.entries) {
      final topLevelKey = entry.key;
      final topLevelValue = entry.value;

      if (topLevelValue is Map<String, dynamic>) {
        _processNode(
          path: topLevelKey,
          node: topLevelValue,
          result: result,
          themeConfigs: themeConfigs,
        );
      }
    }

    return result;
  }

  static void _processNode({
    required String path,
    required Map<String, dynamic> node,
    required Map<String, TextStyle> result,
    required Map<String, AppThemeConfig> themeConfigs,
  }) {
    final hasStyleValues =
        node.containsKey('fontsize') || node.containsKey('color');

    if (hasStyleValues) {
      _debug('building style: $path');
      _debug('values: $node');

      final fontSizeStr = node['fontsize']?.toString();
      final fontWeightStr = node['fontweight']?.toString();
      final lineHeightStr = node['lineheight']?.toString();
      final letterSpacingStr = node['letterspacing']?.toString();
      final colorStr = node['color']?.toString();

      final fontSize = double.tryParse(fontSizeStr ?? '') ?? 14.0;
      final fontWeight = int.tryParse(fontWeightStr ?? '') ?? 400;
      final lineHeight = double.tryParse(lineHeightStr ?? '') ?? 1.4;
      final letterSpacing = double.tryParse(letterSpacingStr ?? '') ?? 0.0;

      _debug(
        'parsed: fontSize=$fontSize fontWeight=$fontWeight color=$colorStr',
      );

      Color? color;
      if (colorStr != null && colorStr.isNotEmpty) {
        color = Color(
          int.parse(
            colorStr.startsWith('#') ? '0x${colorStr.substring(1)}' : colorStr,
          ),
        );
      }

      final lightStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.values.firstWhere(
          (w) => w.value == fontWeight,
          orElse: () => FontWeight.w400,
        ),
        height: lineHeight,
        letterSpacing: letterSpacing,
        color: color,
      );

      final styleKey = path.replaceAll('.', '_');
      result['${styleKey}_light'] = lightStyle;
      result['${styleKey}_dark'] = lightStyle.copyWith(
        color: color ?? themeConfigs['dark']!.labelPrimary,
      );
    } else {
      for (final childEntry in node.entries) {
        if (childEntry.value is Map<String, dynamic>) {
          _processNode(
            path: '$path.${childEntry.key}',
            node: childEntry.value as Map<String, dynamic>,
            result: result,
            themeConfigs: themeConfigs,
          );
        }
      }
    }
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
      final json = await HoconParser._loadWithIncludes(_stylesPath);
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
