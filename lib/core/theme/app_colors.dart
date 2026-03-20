import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6750A4);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFEADDFF);
  static const Color onPrimaryContainer = Color(0xFF21005D);
  static const Color secondary = Color(0xFF625B71);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE8DEF8);
  static const Color onSecondaryContainer = Color(0xFF1D192B);
  static const Color tertiary = Color(0xFF7D5260);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFD8E4);
  static const Color onTertiaryContainer = Color(0xFF31111D);
  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);
  static const Color background = Color(0xFFFFFBFE);
  static const Color onBackground = Color(0xFF1C1B1F);
  static const Color surface = Color(0xFFFFFBFE);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);
  static const Color inverseSurface = Color(0xFF313033);
  static const Color onInverseSurface = Color(0xFFF4EFF4);
  static const Color inversePrimary = Color(0xFFD0BCFF);
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
  static const Color surfaceTint = Color(0xFF6750A4);
  static const Color success = Color(0xFF4CAF50);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFFF9800);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color info = Color(0xFF2196F3);
  static const Color onInfo = Color(0xFFFFFFFF);

  static ColorScheme get lightColorScheme => const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        inverseSurface: inverseSurface,
        onInverseSurface: onInverseSurface,
        inversePrimary: inversePrimary,
        shadow: shadow,
        scrim: scrim,
        surfaceTint: surfaceTint,
      );

  static ColorScheme get darkColorScheme => const ColorScheme.dark(
        primary: Color(0xFFD0BCFF),
        onPrimary: Color(0xFF381E72),
        primaryContainer: Color(0xFF4F378B),
        onPrimaryContainer: Color(0xFFEADDFF),
        secondary: Color(0xFFCCC2DC),
        onSecondary: Color(0xFF332D41),
        secondaryContainer: Color(0xFF4A4458),
        onSecondaryContainer: Color(0xFFE8DEF8),
        tertiary: Color(0xFFEFB8C8),
        onTertiary: Color(0xFF492532),
        tertiaryContainer: Color(0xFF633B48),
        onTertiaryContainer: Color(0xFFFFD8E4),
        error: Color(0xFFF2B8B5),
        onError: Color(0xFF601410),
        errorContainer: Color(0xFF8C1D18),
        surface: Color(0xFF1C1B1F),
        onSurface: Color(0xFFE6E1E5),
        surfaceContainerHighest: Color(0xFF49454F),
        outline: Color(0xFF938F99),
        outlineVariant: Color(0xFF49454F),
        inverseSurface: Color(0xFFE6E1E5),
        onInverseSurface: Color(0xFF313033),
        inversePrimary: Color(0xFF6750A4),
        shadow: shadow,
        scrim: scrim,
        surfaceTint: surfaceTint,
      );
}
