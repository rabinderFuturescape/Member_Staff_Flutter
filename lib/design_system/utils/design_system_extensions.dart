import 'package:flutter/material.dart';
import '../core/core.dart';
import '../providers/providers.dart';
import 'responsive.dart';

/// Extension methods for BuildContext
extension BuildContextExtensions on BuildContext {
  /// Get the theme from the context
  ThemeData get theme => Theme.of(this);
  
  /// Get the text theme from the context
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Get the color scheme from the context
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Get the media query from the context
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  
  /// Get the screen size from the context
  Size get screenSize => mediaQuery.size;
  
  /// Get the screen width from the context
  double get screenWidth => screenSize.width;
  
  /// Get the screen height from the context
  double get screenHeight => screenSize.height;
  
  /// Get the screen orientation from the context
  Orientation get orientation => mediaQuery.orientation;
  
  /// Check if the screen is in portrait orientation
  bool get isPortrait => orientation == Orientation.portrait;
  
  /// Check if the screen is in landscape orientation
  bool get isLandscape => orientation == Orientation.landscape;
  
  /// Get the theme mode from the context
  ThemeMode get themeMode => Theme.of(this).brightness == Brightness.light
      ? ThemeMode.light
      : ThemeMode.dark;
  
  /// Check if the theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// Check if the theme is light
  bool get isLightMode => Theme.of(this).brightness == Brightness.light;
  
  /// Get the theme provider from the context
  ThemeProvider get themeProvider => ThemeProvider.of(this);
  
  /// Get the design system provider from the context
  DesignSystemProvider get designSystemProvider => DesignSystemProvider.of(this);
  
  /// Get the appropriate color based on the theme brightness
  Color getColorByBrightness(Color lightColor, Color darkColor) {
    return isDarkMode ? darkColor : lightColor;
  }
  
  /// Get the appropriate text style based on the theme brightness
  TextStyle getTextStyleByBrightness(TextStyle lightStyle, TextStyle darkStyle) {
    return isDarkMode ? darkStyle : lightStyle;
  }
  
  /// Check if the screen is extra small
  bool get isExtraSmallScreen => DSResponsive.isExtraSmallScreen(this);
  
  /// Check if the screen is small
  bool get isSmallScreen => DSResponsive.isSmallScreen(this);
  
  /// Check if the screen is medium
  bool get isMediumScreen => DSResponsive.isMediumScreen(this);
  
  /// Check if the screen is large
  bool get isLargeScreen => DSResponsive.isLargeScreen(this);
  
  /// Check if the screen is extra large
  bool get isExtraLargeScreen => DSResponsive.isExtraLargeScreen(this);
  
  /// Get the screen size category
  String get screenSizeCategory => DSResponsive.getScreenSizeCategory(this);
  
  /// Get a value based on the screen size
  T getValueForScreenSize<T>({
    required T defaultValue,
    T? xs,
    T? sm,
    T? md,
    T? lg,
    T? xl,
  }) {
    return DSResponsive.getValueForScreenSize(
      context: this,
      defaultValue: defaultValue,
      xs: xs,
      sm: sm,
      md: md,
      lg: lg,
      xl: xl,
    );
  }
  
  /// Get a responsive value based on the screen width
  double getResponsiveValue({
    required double defaultValue,
    double? multiplier,
    double? max,
    double? min,
  }) {
    return DSResponsive.getResponsiveValue(
      context: this,
      defaultValue: defaultValue,
      multiplier: multiplier,
      max: max,
      min: min,
    );
  }
  
  /// Get a responsive font size
  double getResponsiveFontSize({
    required double fontSize,
    double? minFontSize,
    double? maxFontSize,
  }) {
    return DSResponsive.getResponsiveFontSize(
      context: this,
      fontSize: fontSize,
      minFontSize: minFontSize,
      maxFontSize: maxFontSize,
    );
  }
  
  /// Get a responsive padding
  EdgeInsets getResponsivePadding({
    required EdgeInsets defaultPadding,
    EdgeInsets? xs,
    EdgeInsets? sm,
    EdgeInsets? md,
    EdgeInsets? lg,
    EdgeInsets? xl,
  }) {
    return DSResponsive.getResponsivePadding(
      context: this,
      defaultPadding: defaultPadding,
      xs: xs,
      sm: sm,
      md: md,
      lg: lg,
      xl: xl,
    );
  }
  
  /// Get a responsive margin
  EdgeInsets getResponsiveMargin({
    required EdgeInsets defaultMargin,
    EdgeInsets? xs,
    EdgeInsets? sm,
    EdgeInsets? md,
    EdgeInsets? lg,
    EdgeInsets? xl,
  }) {
    return DSResponsive.getResponsiveMargin(
      context: this,
      defaultMargin: defaultMargin,
      xs: xs,
      sm: sm,
      md: md,
      lg: lg,
      xl: xl,
    );
  }
  
  /// Get a responsive width
  double getResponsiveWidth({
    required double percentageOfScreenWidth,
    double? max,
    double? min,
  }) {
    return DSResponsive.getResponsiveWidth(
      context: this,
      percentageOfScreenWidth: percentageOfScreenWidth,
      max: max,
      min: min,
    );
  }
  
  /// Get a responsive height
  double getResponsiveHeight({
    required double percentageOfScreenHeight,
    double? max,
    double? min,
  }) {
    return DSResponsive.getResponsiveHeight(
      context: this,
      percentageOfScreenHeight: percentageOfScreenHeight,
      max: max,
      min: min,
    );
  }
}

/// Extension methods for ThemeProvider
extension ThemeProviderExtensions on ThemeProvider {
  /// Get the ThemeProvider from the context
  static ThemeProvider of(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: false);
  }
}

/// Extension methods for DesignSystemProvider
extension DesignSystemProviderExtensions on DesignSystemProvider {
  /// Get the DesignSystemProvider from the context
  static DesignSystemProvider of(BuildContext context) {
    return Provider.of<DesignSystemProvider>(context, listen: false);
  }
}

/// Extension methods for TextStyle
extension TextStyleExtensions on TextStyle {
  /// Apply the font size scale
  TextStyle withFontSizeScale(double scale) {
    return copyWith(
      fontSize: fontSize != null ? fontSize! * scale : null,
    );
  }
  
  /// Apply the font weight
  TextStyle withWeight(FontWeight weight) {
    return copyWith(
      fontWeight: weight,
    );
  }
  
  /// Apply the font color
  TextStyle withColor(Color color) {
    return copyWith(
      color: color,
    );
  }
  
  /// Apply the font family
  TextStyle withFontFamily(String fontFamily) {
    return copyWith(
      fontFamily: fontFamily,
    );
  }
  
  /// Apply the letter spacing
  TextStyle withLetterSpacing(double letterSpacing) {
    return copyWith(
      letterSpacing: letterSpacing,
    );
  }
  
  /// Apply the line height
  TextStyle withHeight(double height) {
    return copyWith(
      height: height,
    );
  }
  
  /// Apply the text decoration
  TextStyle withDecoration(TextDecoration decoration) {
    return copyWith(
      decoration: decoration,
    );
  }
  
  /// Apply the text decoration color
  TextStyle withDecorationColor(Color decorationColor) {
    return copyWith(
      decorationColor: decorationColor,
    );
  }
  
  /// Apply the text decoration style
  TextStyle withDecorationStyle(TextDecorationStyle decorationStyle) {
    return copyWith(
      decorationStyle: decorationStyle,
    );
  }
  
  /// Apply the text decoration thickness
  TextStyle withDecorationThickness(double decorationThickness) {
    return copyWith(
      decorationThickness: decorationThickness,
    );
  }
  
  /// Apply the text shadow
  TextStyle withShadow(Shadow shadow) {
    return copyWith(
      shadows: [shadow],
    );
  }
  
  /// Apply multiple text shadows
  TextStyle withShadows(List<Shadow> shadows) {
    return copyWith(
      shadows: shadows,
    );
  }
}

/// Extension methods for Color
extension ColorExtensions on Color {
  /// Darken the color by the given percentage
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    
    return hslDark.toColor();
  }
  
  /// Lighten the color by the given percentage
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    
    return hslLight.toColor();
  }
  
  /// Get the color with the given opacity
  Color withOpacity(double opacity) {
    return Color.fromRGBO(red, green, blue, opacity);
  }
  
  /// Check if the color is light
  bool get isLight {
    return computeLuminance() > 0.5;
  }
  
  /// Check if the color is dark
  bool get isDark {
    return !isLight;
  }
  
  /// Get the contrasting color (black or white) based on the color's luminance
  Color get contrast {
    return isLight ? Colors.black : Colors.white;
  }
  
  /// Get the color as a material color
  MaterialColor get asMaterialColor {
    final int r = red;
    final int g = green;
    final int b = blue;
    
    return MaterialColor(value, {
      50: Color.fromRGBO(r, g, b, 0.1),
      100: Color.fromRGBO(r, g, b, 0.2),
      200: Color.fromRGBO(r, g, b, 0.3),
      300: Color.fromRGBO(r, g, b, 0.4),
      400: Color.fromRGBO(r, g, b, 0.5),
      500: Color.fromRGBO(r, g, b, 0.6),
      600: Color.fromRGBO(r, g, b, 0.7),
      700: Color.fromRGBO(r, g, b, 0.8),
      800: Color.fromRGBO(r, g, b, 0.9),
      900: Color.fromRGBO(r, g, b, 1.0),
    });
  }
}

/// Extension methods for EdgeInsets
extension EdgeInsetsExtensions on EdgeInsets {
  /// Add another EdgeInsets to this EdgeInsets
  EdgeInsets add(EdgeInsets other) {
    return EdgeInsets.fromLTRB(
      left + other.left,
      top + other.top,
      right + other.right,
      bottom + other.bottom,
    );
  }
  
  /// Subtract another EdgeInsets from this EdgeInsets
  EdgeInsets subtract(EdgeInsets other) {
    return EdgeInsets.fromLTRB(
      (left - other.left).clamp(0.0, double.infinity),
      (top - other.top).clamp(0.0, double.infinity),
      (right - other.right).clamp(0.0, double.infinity),
      (bottom - other.bottom).clamp(0.0, double.infinity),
    );
  }
  
  /// Scale this EdgeInsets by a factor
  EdgeInsets scale(double factor) {
    return EdgeInsets.fromLTRB(
      left * factor,
      top * factor,
      right * factor,
      bottom * factor,
    );
  }
  
  /// Get a copy of this EdgeInsets with the given values
  EdgeInsets copyWith({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.fromLTRB(
      left ?? this.left,
      top ?? this.top,
      right ?? this.right,
      bottom ?? this.bottom,
    );
  }
}
