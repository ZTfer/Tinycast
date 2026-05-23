import 'package:flutter/material.dart';
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

  TextStyle? _parseTextStyle(String path) {
    if (!_isHocon) return null;
    final style = _layoutStyle(path);
    if (style == null) return null;
    final colorStr = style['color']?.toString();
    Color? color;
    if (colorStr != null && colorStr.isNotEmpty) {
      color = Color(
        int.parse(
          colorStr.startsWith('#') ? '0x${colorStr.substring(1)}' : colorStr,
        ),
      );
    }
    return TextStyle(
      fontSize: double.tryParse(style['fontsize']?.toString() ?? '14.0'),
      fontWeight: style['fontweight'] != null
          ? FontWeight.values.firstWhere(
              (w) => w.toString() == 'FontWeight.w${style['fontweight']}',
              orElse: () => FontWeight.normal,
            )
          : null,
      letterSpacing: double.tryParse(
        style['letterspacing']?.toString() ?? '0.0',
      ),
      height: double.tryParse(style['lineheight']?.toString() ?? '1.0'),
      color: color,
    );
  }

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
      ? (_widgetStyle('widgets_episode_item_title') ??
            _hardcodedTextStyle(
              AppTextStyles.h3DesktopLight,
              AppTextStyles.h3DesktopDark,
            ))
      : (mode == AppThemeMode.light
            ? AppTextStyles.h3DesktopLight
            : AppTextStyles.h3DesktopDark);

  TextStyle get episodeItemDescription => _isHocon
      ? (() {
          final style = _widgetStyle('widgets_episode_item_description');
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
      ? (_widgetStyle('widgets_episode_item_pubDate') ??
            _hardcodedTextStyle(
              AppTextStyles.captionLight,
              AppTextStyles.captionDark,
            ))
      : (mode == AppThemeMode.light
            ? AppTextStyles.captionLight
            : AppTextStyles.captionDark);

  int get episodeItemTitleMaxLines {
    if (!_isHocon) return 1;
    final style = _layoutStyle('widgets.episode_item.title');
    if (style == null) return 1;
    return int.tryParse(style['maxLines']?.toString() ?? '1') ?? 1;
  }

  TextStyle get libraryShowTitle => _isHocon
      ? (_widgetStyle('page_library_list_item_title') ??
            _hardcodedTextStyle(
              AppTextStyles.h3DesktopLight,
              AppTextStyles.h3DesktopDark,
            ))
      : (mode == AppThemeMode.light
            ? AppTextStyles.h3DesktopLight
            : AppTextStyles.h3DesktopDark);

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

  Map<String, dynamic>? _layoutStyle(String path) {
    if (!_isHocon) return null;
    final stylesJson = ThemeLoader.cachedWidgetStyles['styles'];
    if (stylesJson == null) return null;

    final parts = path.split('.');
    Map<String, dynamic>? current = stylesJson;
    for (final part in parts) {
      if (current == null) return null;
      current = current[part] as Map<String, dynamic>?;
    }
    return current;
  }

  EdgeInsets? _layoutPadding(String path) {
    final style = _layoutStyle(path);
    if (style == null) return null;
    if (style['padding'] is Map<String, dynamic>) {
      final p = style['padding'] as Map<String, dynamic>;
      return EdgeInsets.only(
        top: double.tryParse(p['top']?.toString() ?? '0') ?? 0,
        bottom: double.tryParse(p['bottom']?.toString() ?? '0') ?? 0,
        left: double.tryParse(p['left']?.toString() ?? '0') ?? 0,
        right: double.tryParse(p['right']?.toString() ?? '0') ?? 0,
      );
    }
    final val = double.tryParse(style['padding']?.toString() ?? '');
    if (val != null) return EdgeInsets.all(val);
    return null;
  }

  Color? _layoutBackground(String path) {
    final style = _layoutStyle(path);
    if (style == null) return null;
    final colorStr = style['background']?.toString();
    if (colorStr == null || colorStr.isEmpty) return null;

    final int colorInt;
    if (colorStr.startsWith('#')) {
      final hex = colorStr.substring(1);
      if (hex.length == 6) {
        colorInt = int.parse('0xFF$hex');
      } else if (hex.length == 8) {
        colorInt = int.parse('0x$hex');
      } else {
        return null;
      }
    } else {
      colorInt = int.parse(colorStr);
    }
    return Color(colorInt);
  }

  BorderRadius? _layoutBorderRadius(String path) {
    final style = _layoutStyle(path);
    if (style == null) return null;
    if (style['radius'] is Map<String, dynamic>) {
      final r = style['radius'] as Map<String, dynamic>;
      return BorderRadius.only(
        topLeft: Radius.circular(
          double.tryParse(r['top_left']?.toString() ?? '0') ?? 0,
        ),
        topRight: Radius.circular(
          double.tryParse(r['top_right']?.toString() ?? '0') ?? 0,
        ),
        bottomLeft: Radius.circular(
          double.tryParse(r['bottom_left']?.toString() ?? '0') ?? 0,
        ),
        bottomRight: Radius.circular(
          double.tryParse(r['bottom_right']?.toString() ?? '0') ?? 0,
        ),
      );
    }
    final val = double.tryParse(style['radius']?.toString() ?? '');
    if (val != null) return BorderRadius.circular(val);
    return null;
  }

  EdgeInsets get homeToolbarPadding =>
      _layoutPadding('window_container.home_toolbar') ??
      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);

  Color get homeToolbarBackground =>
      _layoutBackground('window_container.home_toolbar') ?? Colors.transparent;

  EdgeInsets get miniPlayerPadding =>
      _layoutPadding('window_container.mini_player') ??
      const EdgeInsets.only(top: 8.0);

  Color get miniPlayerBackground =>
      _layoutBackground('window_container.mini_player') ??
      const Color(0x00FFFFFF);

  EdgeInsets get bodyPadding =>
      _layoutPadding('window_container.body') ??
      const EdgeInsets.all(12.0);

  Color get bodyBackground =>
      _layoutBackground('window_container.body') ??
      const Color(0xFFFFFFFF);

  EdgeInsets get bodySidebarPadding =>
      _layoutPadding('window_container.body.sidebar') ??
      EdgeInsets.zero;

  EdgeInsets get bodyContentPadding =>
      _layoutPadding('window_container.body.content') ??
      EdgeInsets.zero;

  Color get bodySidebarBackground =>
      _layoutBackground('window_container.body.sidebar') ??
      const Color(0xFFFFFFFF);

  Color get bodyContentBackground =>
      _layoutBackground('window_container.body.content') ??
      const Color(0xFFFFFFFF);

  BorderRadius get bodyContentBorderRadius =>
      _layoutBorderRadius('window_container.body.content') ??
      BorderRadius.zero;

  BorderRadius get bodyBorderRadius {
    final result =
        _layoutBorderRadius('window_container.body') ??
        BorderRadius.zero;
    debugPrint(
      '[ThemeData] bodyBorderRadius: $result, path=window_container.body',
    );
    return result;
  }

  Color? homeToolbarButtonBackground({
    bool pressed = false,
    bool hovered = false,
  }) {
    if (!_isHocon) return null;
    final style = _layoutStyle('widgets.home_toolbar.home_toolbar_button');
    if (style == null) return null;
    final bg = style['background'] as Map<String, dynamic>?;
    if (bg == null) return null;
    final key = pressed
        ? 'pressed'
        : hovered
        ? 'hover'
        : 'default';
    final colorStr = bg[key]?.toString();
    if (colorStr == null || colorStr.isEmpty) return null;
    return Color(
      int.parse(
        colorStr.startsWith('#') ? '0x${colorStr.substring(1)}' : colorStr,
      ),
    );
  }

  bool get dividerVisible {
    final style = _layoutStyle('window_container.divider');
    if (style == null) return true;
    final show = style['show'];
    if (show is bool) return show;
    if (show is String) return show.toLowerCase() == 'true';
    return true;
  }

  double get dividerHeight {
    final style = _layoutStyle('window_container.divider');
    if (style == null) return 0.5;
    return double.tryParse(style['height']?.toString() ?? '0.5') ?? 0.5;
  }

  double get dividerThickness {
    final style = _layoutStyle('window_container.divider');
    if (style == null) return 0.5;
    return double.tryParse(style['thickness']?.toString() ?? '0.5') ?? 0.5;
  }

  Color get dividerColor {
    final style = _layoutStyle('window_container.divider');
    if (style == null) return const Color(0xFFCCCCCC);
    final colorStr = style['color']?.toString();
    if (colorStr == null || colorStr.isEmpty) return const Color(0xFFCCCCCC);
    return Color(
      int.parse(
        colorStr.startsWith('#') ? '0x${colorStr.substring(1)}' : colorStr,
      ),
    );
  }

  Color get homeToolbarButtonDefaultBackground =>
      homeToolbarButtonBackground() ?? const Color(0x00F5F5F5);

  Color get homeToolbarButtonHoverBackground =>
      homeToolbarButtonBackground(hovered: true) ?? const Color(0xFFF5F5F5);

  Color get homeToolbarButtonPressedBackground =>
      homeToolbarButtonBackground(pressed: true) ?? const Color(0xFFE0E0E0);

  Color get homeToolbarButtonContentColor {
    if (!_isHocon) return const Color(0xFF000000);
    final style = _layoutStyle('widgets.home_toolbar.home_toolbar_button');
    if (style != null) {
      final cc = style['content_color'] as Map<String, dynamic>?;
      if (cc != null) {
        final colorStr = cc['text']?.toString();
        if (colorStr != null && colorStr.isNotEmpty) {
          return Color(
            int.parse(
              colorStr.startsWith('#')
                  ? '0x${colorStr.substring(1)}'
                  : colorStr,
            ),
          );
        }
      }
    }
    return _config.labelPrimary;
  }

  // ===== Mini Player: Episode Info =====

  Map<String, dynamic>? _episodeInfoStyle() {
    if (!_isHocon) return null;
    return _layoutStyle('widgets.mini_player.episode_info');
  }

  double get episodeInfoCoverWidth {
    final style = _episodeInfoStyle();
    if (style == null) return 54.0;
    final cover = style['cover'] as Map<String, dynamic>?;
    if (cover == null) return 54.0;
    return double.tryParse(cover['width']?.toString() ?? '54.0') ?? 54.0;
  }

  double get episodeInfoCoverHeight {
    final style = _episodeInfoStyle();
    if (style == null) return 54.0;
    final cover = style['cover'] as Map<String, dynamic>?;
    if (cover == null) return 54.0;
    return double.tryParse(cover['height']?.toString() ?? '54.0') ?? 54.0;
  }

  double get episodeInfoCoverBorderRadius {
    final style = _episodeInfoStyle();
    if (style == null) return 8.0;
    final cover = style['cover'] as Map<String, dynamic>?;
    if (cover == null) return 8.0;
    return double.tryParse(cover['borderRadius']?.toString() ?? '8.0') ?? 8.0;
  }

  BoxFit get episodeInfoCoverFit {
    final style = _episodeInfoStyle();
    if (style == null) return BoxFit.cover;
    final cover = style['cover'] as Map<String, dynamic>?;
    if (cover == null) return BoxFit.cover;
    final fitStr = cover['fit']?.toString();
    if (fitStr == null) return BoxFit.cover;
    switch (fitStr) {
      case 'BoxFit.cover':
        return BoxFit.cover;
      case 'BoxFit.contain':
        return BoxFit.contain;
      case 'BoxFit.fill':
        return BoxFit.fill;
      case 'BoxFit.fitHeight':
        return BoxFit.fitHeight;
      case 'BoxFit.fitWidth':
        return BoxFit.fitWidth;
      case 'BoxFit.scaleDown':
        return BoxFit.scaleDown;
      case 'BoxFit.none':
        return BoxFit.none;
      default:
        return BoxFit.cover;
    }
  }

  TextStyle get episodeInfoEpisodeTitle =>
      _parseTextStyle('widgets.mini_player.episode_info.episode_title') ??
      const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      );

  TextStyle get episodeInfoPodcastTitle =>
      _parseTextStyle('widgets.mini_player.episode_info.podcast_title') ??
      const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Color(0xFF888888),
      );

  // ===== Mini Player: Episode Control Bar =====

  Color? _episodeControlButtonBackground({
    bool pressed = false,
    bool hovered = false,
  }) {
    if (!_isHocon) return null;
    final style = _layoutStyle(
      'widgets.mini_player.episode_control_bar.control_button',
    );
    if (style == null) return null;
    final bg = style['background'] as Map<String, dynamic>?;
    if (bg == null) return null;
    final key = pressed
        ? 'pressed'
        : hovered
        ? 'hover'
        : 'default';
    final colorStr = bg[key]?.toString();
    if (colorStr == null || colorStr.isEmpty) return null;
    return Color(
      int.parse(
        colorStr.startsWith('#') ? '0x${colorStr.substring(1)}' : colorStr,
      ),
    );
  }

  Color get episodeControlButtonDefaultBackground =>
      _episodeControlButtonBackground() ?? const Color(0x00F5F5F5);

  Color get episodeControlButtonHoverBackground =>
      _episodeControlButtonBackground(hovered: true) ?? const Color(0xFFF5F5F5);

  Color get episodeControlButtonPressedBackground =>
      _episodeControlButtonBackground(pressed: true) ?? const Color(0xFFE0E0E0);

  Color get episodeControlButtonContentColor {
    if (!_isHocon) return const Color(0xFF000000);
    final style = _layoutStyle(
      'widgets.mini_player.episode_control_bar.control_button',
    );
    if (style != null) {
      final cc = style['content_color'] as Map<String, dynamic>?;
      if (cc != null) {
        final colorStr = cc['text']?.toString();
        if (colorStr != null && colorStr.isNotEmpty) {
          return Color(
            int.parse(
              colorStr.startsWith('#')
                  ? '0x${colorStr.substring(1)}'
                  : colorStr,
            ),
          );
        }
      }
    }
    return _config.labelPrimary;
  }

  // ===== Mini Player: Play/Pause Button =====

  Color? _playPauseButtonBackground({
    bool pressed = false,
    bool hovered = false,
  }) {
    if (!_isHocon) return null;
    final style = _layoutStyle(
      'widgets.mini_player.episode_control_bar.play_pause_button',
    );
    if (style == null) return null;
    final bg = style['background'] as Map<String, dynamic>?;
    if (bg == null) return null;
    final key = pressed
        ? 'pressed'
        : hovered
        ? 'hover'
        : 'default';
    final colorStr = bg[key]?.toString();
    if (colorStr == null || colorStr.isEmpty) return null;
    return Color(
      int.parse(
        colorStr.startsWith('#') ? '0x${colorStr.substring(1)}' : colorStr,
      ),
    );
  }

  Color get playPauseButtonDefaultBackground =>
      _playPauseButtonBackground() ?? const Color(0x00F5F5F5);

  Color get playPauseButtonHoverBackground =>
      _playPauseButtonBackground(hovered: true) ?? const Color(0xFFF5F5F5);

  Color get playPauseButtonPressedBackground =>
      _playPauseButtonBackground(pressed: true) ?? const Color(0xFFE0E0E0);

  Color get playPauseButtonContentColor {
    if (!_isHocon) return const Color(0xFF000000);
    final style = _layoutStyle(
      'widgets.mini_player.episode_control_bar.play_pause_button',
    );
    if (style != null) {
      final cc = style['content_color'] as Map<String, dynamic>?;
      if (cc != null) {
        final colorStr = cc['text']?.toString();
        if (colorStr != null && colorStr.isNotEmpty) {
          return Color(
            int.parse(
              colorStr.startsWith('#')
                  ? '0x${colorStr.substring(1)}'
                  : colorStr,
            ),
          );
        }
      }
    }
    return _config.labelPrimary;
  }

  // ===== Mini Player: Episode Progress Bar =====

  Map<String, dynamic>? _progressBarStyle() {
    if (!_isHocon) return null;
    return _layoutStyle('widgets.mini_player.episode_progress_bar');
  }

  double get episodeProgressTrackHeight {
    final style = _progressBarStyle();
    if (style == null) return 3.0;
    return double.tryParse(style['track_height']?.toString() ?? '3.0') ?? 3.0;
  }

  double get episodeProgressThumbRadius {
    final style = _progressBarStyle();
    if (style == null) return 6.0;
    return double.tryParse(style['thumb_radius']?.toString() ?? '6.0') ?? 6.0;
  }

  Color get episodeProgressTrackColor {
    final style = _progressBarStyle();
    if (style == null) return const Color(0xFFE0E0E0);
    final colorStr = style['track_color']?.toString();
    if (colorStr == null || colorStr.isEmpty) return const Color(0xFFE0E0E0);
    return Color(
      int.parse(
        colorStr.startsWith('#') ? '0x${colorStr.substring(1)}' : colorStr,
      ),
    );
  }

  Color get episodeProgressProgressColor {
    final style = _progressBarStyle();
    if (style == null) return const Color(0xFF333333);
    final colorStr = style['progress_color']?.toString();
    if (colorStr == null || colorStr.isEmpty) return const Color(0xFF333333);
    return Color(
      int.parse(
        colorStr.startsWith('#') ? '0x${colorStr.substring(1)}' : colorStr,
      ),
    );
  }

  Color get episodeProgressThumbColor {
    final style = _progressBarStyle();
    if (style == null) return const Color(0xFF333333);
    final colorStr = style['thumb_color']?.toString();
    if (colorStr == null || colorStr.isEmpty) return const Color(0xFF333333);
    return Color(
      int.parse(
        colorStr.startsWith('#') ? '0x${colorStr.substring(1)}' : colorStr,
      ),
    );
  }

  TextStyle get episodeProgressTimeLabelStyle =>
      _parseTextStyle('widgets.mini_player.episode_progress_bar.time_label') ??
      const TextStyle(fontSize: 11, color: Color(0xFF999999));
}
