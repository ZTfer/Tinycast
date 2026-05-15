import 'package:flutter/widgets.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_theme_config.dart';
import 'theme_loader.dart';

enum AppThemeMode { light, dark }

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppBorderRadius {
  AppBorderRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 9999;
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x1E000000), blurRadius: 16, offset: Offset(0, 8)),
  ];
}

class AppThemeData {
  final AppThemeMode mode;
  final bool _useHardcoded;
  final String _brightnessKey;

  const AppThemeData({required this.mode})
    : _useHardcoded = true,
      _brightnessKey = 'const';

  AppThemeData.fromSource({required this.mode, required bool useHardcoded})
    : _useHardcoded = useHardcoded,
      _brightnessKey = mode == AppThemeMode.light ? 'light' : 'dark';

  bool get _isHocon => !_useHardcoded;

  AppThemeConfig get _config => ThemeLoader.cachedThemeConfigs[_brightnessKey]!;

  TextStyle? _widgetTextStyle(String key) {
    if (!_isHocon) return null;
    final styles = ThemeLoader.cachedWidgetStyles['textStyles'];
    if (styles == null) return null;
    final suffix = mode == AppThemeMode.light ? 'light' : 'dark';
    return styles['${key}_$suffix'] as TextStyle?;
  }

  TextStyle? _widgetStyle(String key) {
    if (!_isHocon) return null;
    final styles = ThemeLoader.cachedWidgetStyles['widgetTextStyles'];
    if (styles == null) return null;
    final suffix = mode == AppThemeMode.light ? 'light' : 'dark';
    return styles['${key}_$suffix'] as TextStyle?;
  }

  Color get backgroundPrimary => _isHocon
      ? _config.backgroundPrimary
      : mode == AppThemeMode.light
      ? AppColors.backgroundPrimaryLight
      : AppColors.backgroundPrimaryDark;

  Color get backgroundSecondary => _isHocon
      ? _config.backgroundSecondary
      : mode == AppThemeMode.light
      ? AppColors.backgroundSecondaryLight
      : AppColors.backgroundSecondaryDark;

  Color get backgroundTertiary => _isHocon
      ? _config.backgroundTertiary
      : mode == AppThemeMode.light
      ? AppColors.backgroundTertiaryLight
      : AppColors.backgroundTertiaryDark;

  Color get labelPrimary => _isHocon
      ? _config.labelPrimary
      : mode == AppThemeMode.light
      ? AppColors.labelPrimaryLight
      : AppColors.labelPrimaryDark;

  Color get labelSecondary => _isHocon
      ? _config.labelSecondary
      : mode == AppThemeMode.light
      ? AppColors.labelSecondaryLight
      : AppColors.labelSecondaryDark;

  Color get labelTertiary => _isHocon
      ? _config.labelTertiary
      : mode == AppThemeMode.light
      ? AppColors.labelTertiaryLight
      : AppColors.labelTertiaryDark;

  Color get labelQuaternary => _isHocon
      ? _config.labelQuaternary
      : mode == AppThemeMode.light
      ? AppColors.labelQuaternaryLight
      : AppColors.labelQuaternaryDark;

  Color get brandPrimary => _isHocon
      ? _config.brandPrimary
      : mode == AppThemeMode.light
      ? AppColors.brandPrimaryLight
      : AppColors.brandPrimaryDark;

  Color get brandSecondary => _isHocon
      ? _config.brandSecondary
      : mode == AppThemeMode.light
      ? AppColors.brandSecondaryLight
      : AppColors.brandSecondaryDark;

  Color get brandBlue => _isHocon
      ? _config.brandBlue
      : mode == AppThemeMode.light
      ? AppColors.brandBlueLight
      : AppColors.brandBlueDark;

  Color get overlayDefault => _isHocon
      ? _config.overlayDefault
      : mode == AppThemeMode.light
      ? AppColors.overlayDefaultLight
      : AppColors.overlayDefaultDark;

  Color get gray30 => _isHocon
      ? _config.gray30
      : mode == AppThemeMode.light
      ? AppColors.gray30Light
      : AppColors.gray30Dark;

  TextStyle get h1 => _isHocon
      ? (_widgetTextStyle('h1') ??
            _hardcodedTextStyle(AppTextStyles.h1Light, AppTextStyles.h1Dark))
      : (mode == AppThemeMode.light
            ? AppTextStyles.h1Light
            : AppTextStyles.h1Dark);

  TextStyle get h2 => _isHocon
      ? (_widgetTextStyle('h2') ??
            _hardcodedTextStyle(AppTextStyles.h2Light, AppTextStyles.h2Dark))
      : (mode == AppThemeMode.light
            ? AppTextStyles.h2Light
            : AppTextStyles.h2Dark);

  TextStyle get h3 => _isHocon
      ? (_widgetTextStyle('h3') ??
            _hardcodedTextStyle(AppTextStyles.h3Light, AppTextStyles.h3Dark))
      : (mode == AppThemeMode.light
            ? AppTextStyles.h3Light
            : AppTextStyles.h3Dark);

  TextStyle get bodyLarge => _isHocon
      ? (_widgetTextStyle('bodylarge') ??
            _hardcodedTextStyle(
              AppTextStyles.bodyLargeLight,
              AppTextStyles.bodyLargeDark,
            ))
      : (mode == AppThemeMode.light
            ? AppTextStyles.bodyLargeLight
            : AppTextStyles.bodyLargeDark);

  TextStyle get bodyMedium => _isHocon
      ? (_widgetTextStyle('bodymedium') ??
            _hardcodedTextStyle(
              AppTextStyles.bodyMediumLight,
              AppTextStyles.bodyMediumDark,
            ))
      : (mode == AppThemeMode.light
            ? AppTextStyles.bodyMediumLight
            : AppTextStyles.bodyMediumDark);

  TextStyle get bodySmall => _isHocon
      ? (_widgetTextStyle('bodysmall') ??
            _hardcodedTextStyle(
              AppTextStyles.bodySmallLight,
              AppTextStyles.bodySmallDark,
            ))
      : (mode == AppThemeMode.light
            ? AppTextStyles.bodySmallLight
            : AppTextStyles.bodySmallDark);

  TextStyle get caption => _isHocon
      ? (_widgetTextStyle('caption') ??
            _hardcodedTextStyle(
              AppTextStyles.captionLight,
              AppTextStyles.captionDark,
            ))
      : (mode == AppThemeMode.light
            ? AppTextStyles.captionLight
            : AppTextStyles.captionDark);

  TextStyle get button => _isHocon
      ? (_widgetTextStyle('button') ??
            _hardcodedTextStyle(
              AppTextStyles.buttonLight,
              AppTextStyles.buttonDark,
            ))
      : (mode == AppThemeMode.light
            ? AppTextStyles.buttonLight
            : AppTextStyles.buttonDark);

  TextStyle get episodeItemTitle => _isHocon
      ? (_widgetStyle('episode_item_title') ??
            _hardcodedTextStyle(
              AppTextStyles.h3DesktopLight,
              AppTextStyles.h3DesktopDark,
            ))
      : (mode == AppThemeMode.light
            ? AppTextStyles.h3DesktopLight
            : AppTextStyles.h3DesktopDark);

  TextStyle get episodeItemDescription => _isHocon
      ? (() {
          final style = _widgetStyle('episode_item_description');
          return style ??
              _hardcodedTextStyle(
                AppTextStyles.captionLight,
                AppTextStyles.captionDark,
              );
        })()
      : (mode == AppThemeMode.light
            ? AppTextStyles.captionLight
            : AppTextStyles.captionDark);

  TextStyle get episodeItemPubDate => _isHocon
      ? (_widgetStyle('episode_item_pubDate') ??
            _hardcodedTextStyle(
              AppTextStyles.captionLight,
              AppTextStyles.captionDark,
            ))
      : (mode == AppThemeMode.light
            ? AppTextStyles.captionLight
            : AppTextStyles.captionDark);

  TextStyle get libraryShowTitle {
    final style = _widgetStyle('page_library_list_item_title');
    if (style != null) return style;
    return mode == AppThemeMode.light
        ? AppTextStyles.h3DesktopLight
        : AppTextStyles.h3DesktopDark;
  }

  TextStyle _hardcodedTextStyle(TextStyle light, TextStyle dark) =>
      mode == AppThemeMode.light ? light : dark;

  double get spacingXxs => AppSpacing.xxs;
  double get spacingXs => AppSpacing.xs;
  double get spacingSm => AppSpacing.sm;
  double get spacingMd => AppSpacing.md;
  double get spacingLg => AppSpacing.lg;
  double get spacingXl => AppSpacing.xl;
  double get spacingXxl => AppSpacing.xxl;

  double get borderRadiusXs => AppBorderRadius.xs;
  double get borderRadiusSm => AppBorderRadius.sm;
  double get borderRadiusMd => AppBorderRadius.md;
  double get borderRadiusLg => AppBorderRadius.lg;
  double get borderRadiusXl => AppBorderRadius.xl;
  double get borderRadiusFull => AppBorderRadius.full;

  List<BoxShadow> get shadowSm => AppShadows.sm;
  List<BoxShadow> get shadowMd => AppShadows.md;
  List<BoxShadow> get shadowLg => AppShadows.lg;
}
