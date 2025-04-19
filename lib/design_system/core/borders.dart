import 'package:flutter/material.dart';
import 'colors.dart';

/// Design System Borders
///
/// This class defines the border styles for the application.
/// All border styles used in the application should be defined here.
class DSBorders {
  // Border Radius Values
  static const double radiusNone = 0.0;
  static const double radiusXxs = 2.0;
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusXxl = 32.0;
  static const double radiusCircular = 999.0;

  // Border Radius
  static final BorderRadius borderRadiusNone = BorderRadius.circular(radiusNone);
  static final BorderRadius borderRadiusXxs = BorderRadius.circular(radiusXxs);
  static final BorderRadius borderRadiusXs = BorderRadius.circular(radiusXs);
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);
  static final BorderRadius borderRadiusXxl = BorderRadius.circular(radiusXxl);
  static final BorderRadius borderRadiusCircular = BorderRadius.circular(radiusCircular);

  // Border Width Values
  static const double borderWidthNone = 0.0;
  static const double borderWidthXs = 0.5;
  static const double borderWidthSm = 1.0;
  static const double borderWidthMd = 2.0;
  static const double borderWidthLg = 4.0;

  // Border Colors
  static const Color borderColorLight = DSColors.grey300;
  static const Color borderColorMedium = DSColors.grey400;
  static const Color borderColorDark = DSColors.grey500;
  static const Color borderColorPrimary = DSColors.primary;
  static const Color borderColorError = DSColors.error;
  static const Color borderColorSuccess = DSColors.success;
  static const Color borderColorWarning = DSColors.warning;

  // Border Styles
  static final Border borderNone = Border.all(
    width: borderWidthNone,
    color: Colors.transparent,
  );

  static final Border borderXs = Border.all(
    width: borderWidthXs,
    color: borderColorLight,
  );

  static final Border borderSm = Border.all(
    width: borderWidthSm,
    color: borderColorLight,
  );

  static final Border borderMd = Border.all(
    width: borderWidthMd,
    color: borderColorLight,
  );

  static final Border borderLg = Border.all(
    width: borderWidthLg,
    color: borderColorLight,
  );

  static final Border borderPrimary = Border.all(
    width: borderWidthSm,
    color: borderColorPrimary,
  );

  static final Border borderError = Border.all(
    width: borderWidthSm,
    color: borderColorError,
  );

  static final Border borderSuccess = Border.all(
    width: borderWidthSm,
    color: borderColorSuccess,
  );

  static final Border borderWarning = Border.all(
    width: borderWidthSm,
    color: borderColorWarning,
  );

  // Input Border Styles
  static final OutlineInputBorder inputBorderNormal = OutlineInputBorder(
    borderRadius: borderRadiusSm,
    borderSide: BorderSide(
      color: borderColorLight,
      width: borderWidthSm,
    ),
  );

  static final OutlineInputBorder inputBorderFocused = OutlineInputBorder(
    borderRadius: borderRadiusSm,
    borderSide: BorderSide(
      color: borderColorPrimary,
      width: borderWidthSm,
    ),
  );

  static final OutlineInputBorder inputBorderError = OutlineInputBorder(
    borderRadius: borderRadiusSm,
    borderSide: BorderSide(
      color: borderColorError,
      width: borderWidthSm,
    ),
  );

  static final OutlineInputBorder inputBorderDisabled = OutlineInputBorder(
    borderRadius: borderRadiusSm,
    borderSide: BorderSide(
      color: borderColorLight.withOpacity(0.5),
      width: borderWidthSm,
    ),
  );

  // Helper method to create custom border radius
  static BorderRadius borderRadius(double radius) => BorderRadius.circular(radius);

  // Helper method to create custom border
  static Border border({
    double width = borderWidthSm,
    Color color = borderColorLight,
  }) {
    return Border.all(
      width: width,
      color: color,
    );
  }

  // Helper method to create custom input border
  static OutlineInputBorder inputBorder({
    double radius = radiusSm,
    double width = borderWidthSm,
    Color color = borderColorLight,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}
