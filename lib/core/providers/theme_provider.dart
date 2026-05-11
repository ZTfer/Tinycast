import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme_config.dart';
import '../theme/theme_loader.dart';

final themeProvider = AsyncNotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);

class ThemeState {
  final AppThemeConfig lightConfig;
  final AppThemeConfig darkConfig;

  const ThemeState({
    required this.lightConfig,
    required this.darkConfig,
  });

  AppThemeConfig forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? darkConfig : lightConfig;

  factory ThemeState.defaults() => ThemeState(
        lightConfig: _defaultLight,
        darkConfig: _defaultDark,
      );

  static const _defaultLight = AppThemeConfig(
    name: 'Default Light',
    brandPrimary: Color(0xFF6200EE),
    brandSecondary: Color(0xFF03DAC6),
    brandBlue: Color(0xFF0088FF),
    backgroundPrimary: Color(0xFFFFFFFF),
    backgroundSecondary: Color(0xFFF2F2F7),
    backgroundTertiary: Color(0xFFFFFFFF),
    grayBlack: Color(0xFF000000),
    gray30: Color(0x30000000),
    labelPrimary: Color(0x95000000),
    labelSecondary: Color(0x603C3C43),
    labelTertiary: Color(0x303C3C43),
    labelQuaternary: Color(0x183C3C43),
    overlayDefault: Color(0x20000000),
    overlayTransparent: Color(0x00000000),
  );

  static const _defaultDark = AppThemeConfig(
    name: 'Default Dark',
    brandPrimary: Color(0xFFBB86FC),
    brandSecondary: Color(0xFF03DAC6),
    brandBlue: Color(0xFF0091FF),
    backgroundPrimary: Color(0xFF000000),
    backgroundSecondary: Color(0xFF1C1C1E),
    backgroundTertiary: Color(0xFF2C2C2E),
    grayBlack: Color(0xFF000000),
    gray30: Color(0x30FFFFFF),
    labelPrimary: Color(0x95FFFFFF),
    labelSecondary: Color(0x70EBEBF5),
    labelTertiary: Color(0x30EBEBF5),
    labelQuaternary: Color(0x16EBEBF5),
    overlayDefault: Color(0x48000000),
    overlayTransparent: Color(0x00FFFFFF),
  );
}

class ThemeNotifier extends AsyncNotifier<ThemeState> {
  @override
  Future<ThemeState> build() async {
    try {
      final configs = await ThemeLoader.loadAllThemeConfigs();
      return ThemeState(
        lightConfig: configs['light']!,
        darkConfig: configs['dark']!,
      );
    } catch (e) {
      return ThemeState.defaults();
    }
  }

  Future<void> loadFromJson(Map<String, dynamic> json) async {
    final light = AppThemeConfig.fromJsonWithMode(json, isDark: false);
    final dark = AppThemeConfig.fromJsonWithMode(json, isDark: true);
    state = AsyncData(
      ThemeState(lightConfig: light, darkConfig: dark),
    );
  }

  Future<void> loadFromRemoteJson(String jsonString) async {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    await loadFromJson(json);
  }
}
