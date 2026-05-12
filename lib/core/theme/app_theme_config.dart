import 'package:flutter/widgets.dart';

class AppThemeConfig {
  final String name;
  final Color brandPrimary;
  final Color brandSecondary;
  final Color brandBlue;
  final Color backgroundPrimary;
  final Color backgroundSecondary;
  final Color backgroundTertiary;
  final Color grayBlack;
  final Color gray30;
  final Color labelPrimary;
  final Color labelSecondary;
  final Color labelTertiary;
  final Color labelQuaternary;
  final Color overlayDefault;
  final Color overlayTransparent;

  const AppThemeConfig({
    required this.name,
    required this.brandPrimary,
    required this.brandSecondary,
    required this.brandBlue,
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.backgroundTertiary,
    required this.grayBlack,
    required this.gray30,
    required this.labelPrimary,
    required this.labelSecondary,
    required this.labelTertiary,
    required this.labelQuaternary,
    required this.overlayDefault,
    required this.overlayTransparent,
  });

  factory AppThemeConfig.fromJson(Map<String, dynamic> json) {
    final palettes = json['palettes'] as Map<String, dynamic>;

    Map<String, dynamic> _color(String palette, String name) {
      return (palettes[palette] as Map<String, dynamic>)[name]
          as Map<String, dynamic>;
    }

    Color _parse(String palette, String name) {
      final entry = _color(palette, name);
      final hex = (entry['light'] as String).replaceFirst('#', '');
      final value = int.parse(hex, radix: 16);
      return hex.length == 8 ? Color(value) : Color(0xFF000000 | value);
    }

    return AppThemeConfig(
      name: json['name'] as String? ?? 'Unknown',
      brandPrimary: _parse('brand', 'primary'),
      brandSecondary: _parse('brand', 'secondary'),
      brandBlue: _parse('brand', 'blue'),
      backgroundPrimary: _parse('background', 'primary'),
      backgroundSecondary: _parse('background', 'secondary'),
      backgroundTertiary: _parse('background', 'tertiary'),
      grayBlack: _parse('gray', 'black'),
      gray30: _parse('gray', 'gray-30'),
      labelPrimary: _parse('label', 'primary'),
      labelSecondary: _parse('label', 'secondary'),
      labelTertiary: _parse('label', 'tertiary'),
      labelQuaternary: _parse('label', 'quaternary'),
      overlayDefault: _parse('overlay', 'default'),
      overlayTransparent: _parse('overlay', 'transparent'),
    );
  }

  static AppThemeConfig fromJsonWithMode(
    Map<String, dynamic> json, {
    required bool isDark,
  }) {
    final palettes = json['palettes'] as Map<String, dynamic>;

    Map<String, dynamic> _color(String palette, String name) {
      return (palettes[palette] as Map<String, dynamic>)[name]
          as Map<String, dynamic>;
    }

    Color _parse(String palette, String name) {
      final entry = _color(palette, name);
      final mode = isDark ? 'dark' : 'light';
      final hex = (entry[mode] as String).replaceFirst('#', '');
      final value = int.parse(hex, radix: 16);
      return hex.length == 8 ? Color(value) : Color(0xFF000000 | value);
    }

    return AppThemeConfig(
      name: isDark ? 'Dark' : 'Light',
      brandPrimary: _parse('brand', 'primary'),
      brandSecondary: _parse('brand', 'secondary'),
      brandBlue: _parse('brand', 'blue'),
      backgroundPrimary: _parse('background', 'primary'),
      backgroundSecondary: _parse('background', 'secondary'),
      backgroundTertiary: _parse('background', 'tertiary'),
      grayBlack: _parse('gray', 'black'),
      gray30: _parse('gray', 'gray-30'),
      labelPrimary: _parse('label', 'primary'),
      labelSecondary: _parse('label', 'secondary'),
      labelTertiary: _parse('label', 'tertiary'),
      labelQuaternary: _parse('label', 'quaternary'),
      overlayDefault: _parse('overlay', 'default'),
      overlayTransparent: _parse('overlay', 'transparent'),
    );
  }

  AppThemeConfig copyWith({
    String? name,
    Color? brandPrimary,
    Color? brandSecondary,
    Color? brandBlue,
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? backgroundTertiary,
    Color? grayBlack,
    Color? gray30,
    Color? labelPrimary,
    Color? labelSecondary,
    Color? labelTertiary,
    Color? labelQuaternary,
    Color? overlayDefault,
    Color? overlayTransparent,
  }) {
    return AppThemeConfig(
      name: name ?? this.name,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      brandBlue: brandBlue ?? this.brandBlue,
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      backgroundTertiary: backgroundTertiary ?? this.backgroundTertiary,
      grayBlack: grayBlack ?? this.grayBlack,
      gray30: gray30 ?? this.gray30,
      labelPrimary: labelPrimary ?? this.labelPrimary,
      labelSecondary: labelSecondary ?? this.labelSecondary,
      labelTertiary: labelTertiary ?? this.labelTertiary,
      labelQuaternary: labelQuaternary ?? this.labelQuaternary,
      overlayDefault: overlayDefault ?? this.overlayDefault,
      overlayTransparent: overlayTransparent ?? this.overlayTransparent,
    );
  }
}
