import 'package:flutter/material.dart';
import 'colors.dart';

/// Design System Typography
///
/// This class defines the typography styles for the application.
/// All text styles used in the application should be defined here.
class DSTypography {
  // Font Families
  static const String primaryFontFamily = 'Roboto';
  static const String secondaryFontFamily = 'Roboto';

  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Font Sizes
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;

  // Line Heights
  static const double displayLineHeight = 1.2;
  static const double headlineLineHeight = 1.3;
  static const double titleLineHeight = 1.4;
  static const double bodyLineHeight = 1.5;
  static const double labelLineHeight = 1.4;

  // Letter Spacing
  static const double displayLetterSpacing = -0.25;
  static const double headlineLetterSpacing = 0.0;
  static const double titleLetterSpacing = 0.15;
  static const double bodyLetterSpacing = 0.5;
  static const double labelLetterSpacing = 0.1;

  // Text Styles - Display
  static TextStyle get displayLargeStyle => TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: displayLarge,
        fontWeight: regular,
        letterSpacing: displayLetterSpacing,
        height: displayLineHeight,
        color: DSColors.grey900,
      );

  static TextStyle get displayMediumStyle => TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: displayMedium,
        fontWeight: regular,
        letterSpacing: displayLetterSpacing,
        height: displayLineHeight,
        color: DSColors.grey900,
      );

  static TextStyle get displaySmallStyle => TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: displaySmall,
        fontWeight: regular,
        letterSpacing: displayLetterSpacing,
        height: displayLineHeight,
        color: DSColors.grey900,
      );

  // Text Styles - Headline
  static TextStyle get headlineLargeStyle => TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: headlineLarge,
        fontWeight: medium,
        letterSpacing: headlineLetterSpacing,
        height: headlineLineHeight,
        color: DSColors.grey900,
      );

  static TextStyle get headlineMediumStyle => TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: headlineMedium,
        fontWeight: medium,
        letterSpacing: headlineLetterSpacing,
        height: headlineLineHeight,
        color: DSColors.grey900,
      );

  static TextStyle get headlineSmallStyle => TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: headlineSmall,
        fontWeight: medium,
        letterSpacing: headlineLetterSpacing,
        height: headlineLineHeight,
        color: DSColors.grey900,
      );

  // Text Styles - Title
  static TextStyle get titleLargeStyle => TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: titleLarge,
        fontWeight: medium,
        letterSpacing: titleLetterSpacing,
        height: titleLineHeight,
        color: DSColors.grey900,
      );

  static TextStyle get titleMediumStyle => TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: titleMedium,
        fontWeight: medium,
        letterSpacing: titleLetterSpacing,
        height: titleLineHeight,
        color: DSColors.grey900,
      );

  static TextStyle get titleSmallStyle => TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: titleSmall,
        fontWeight: medium,
        letterSpacing: titleLetterSpacing,
        height: titleLineHeight,
        color: DSColors.grey900,
      );

  // Text Styles - Body
  static TextStyle get bodyLargeStyle => TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: bodyLarge,
        fontWeight: regular,
        letterSpacing: bodyLetterSpacing,
        height: bodyLineHeight,
        color: DSColors.grey900,
      );

  static TextStyle get bodyMediumStyle => TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: bodyMedium,
        fontWeight: regular,
        letterSpacing: bodyLetterSpacing,
        height: bodyLineHeight,
        color: DSColors.grey900,
      );

  static TextStyle get bodySmallStyle => TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: bodySmall,
        fontWeight: regular,
        letterSpacing: bodyLetterSpacing,
        height: bodyLineHeight,
        color: DSColors.grey900,
      );

  // Text Styles - Label
  static TextStyle get labelLargeStyle => TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: labelLarge,
        fontWeight: medium,
        letterSpacing: labelLetterSpacing,
        height: labelLineHeight,
        color: DSColors.grey900,
      );

  static TextStyle get labelMediumStyle => TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: labelMedium,
        fontWeight: medium,
        letterSpacing: labelLetterSpacing,
        height: labelLineHeight,
        color: DSColors.grey900,
      );

  static TextStyle get labelSmallStyle => TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: labelSmall,
        fontWeight: medium,
        letterSpacing: labelLetterSpacing,
        height: labelLineHeight,
        color: DSColors.grey900,
      );

  // Dark Theme Text Styles
  static TextStyle get displayLargeStyleDark => displayLargeStyle.copyWith(color: DSColors.white);
  static TextStyle get displayMediumStyleDark => displayMediumStyle.copyWith(color: DSColors.white);
  static TextStyle get displaySmallStyleDark => displaySmallStyle.copyWith(color: DSColors.white);
  static TextStyle get headlineLargeStyleDark => headlineLargeStyle.copyWith(color: DSColors.white);
  static TextStyle get headlineMediumStyleDark => headlineMediumStyle.copyWith(color: DSColors.white);
  static TextStyle get headlineSmallStyleDark => headlineSmallStyle.copyWith(color: DSColors.white);
  static TextStyle get titleLargeStyleDark => titleLargeStyle.copyWith(color: DSColors.white);
  static TextStyle get titleMediumStyleDark => titleMediumStyle.copyWith(color: DSColors.white);
  static TextStyle get titleSmallStyleDark => titleSmallStyle.copyWith(color: DSColors.white);
  static TextStyle get bodyLargeStyleDark => bodyLargeStyle.copyWith(color: DSColors.white);
  static TextStyle get bodyMediumStyleDark => bodyMediumStyle.copyWith(color: DSColors.white);
  static TextStyle get bodySmallStyleDark => bodySmallStyle.copyWith(color: DSColors.white);
  static TextStyle get labelLargeStyleDark => labelLargeStyle.copyWith(color: DSColors.white);
  static TextStyle get labelMediumStyleDark => labelMediumStyle.copyWith(color: DSColors.white);
  static TextStyle get labelSmallStyleDark => labelSmallStyle.copyWith(color: DSColors.white);
}
