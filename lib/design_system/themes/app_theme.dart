import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/core.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

/// App Theme
///
/// This class provides the application themes and theme-related utilities.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Get the light theme
  static ThemeData get lightTheme => LightTheme.themeData;

  /// Get the dark theme
  static ThemeData get darkTheme => DarkTheme.themeData;

  /// Get the theme based on the brightness
  static ThemeData getThemeByBrightness(Brightness brightness) {
    return brightness == Brightness.light ? lightTheme : darkTheme;
  }

  /// Update system UI overlay style based on the theme brightness
  static void updateSystemUIOverlayStyle(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark ? DSColors.darkBackground : DSColors.white,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  /// Get the appropriate text style based on the brightness
  static TextStyle getTextStyleByBrightness(
    TextStyle lightStyle,
    TextStyle darkStyle,
    Brightness brightness,
  ) {
    return brightness == Brightness.light ? lightStyle : darkStyle;
  }

  /// Get the appropriate color based on the brightness
  static Color getColorByBrightness(
    Color lightColor,
    Color darkColor,
    Brightness brightness,
  ) {
    return brightness == Brightness.light ? lightColor : darkColor;
  }

  /// Get the current theme's brightness
  static Brightness getCurrentBrightness(BuildContext context) {
    return Theme.of(context).brightness;
  }

  /// Check if the current theme is dark
  static bool isDarkMode(BuildContext context) {
    return getCurrentBrightness(context) == Brightness.dark;
  }

  /// Get the appropriate color scheme based on the brightness
  static ColorScheme getColorScheme(Brightness brightness) {
    return brightness == Brightness.light
        ? const ColorScheme.light(
            primary: DSColors.primary,
            secondary: DSColors.secondary,
            surface: DSColors.surface,
            background: DSColors.background,
            error: DSColors.error,
          )
        : const ColorScheme.dark(
            primary: DSColors.primary,
            secondary: DSColors.secondary,
            surface: DSColors.darkSurface,
            background: DSColors.darkBackground,
            error: DSColors.darkError,
          );
  }
}
