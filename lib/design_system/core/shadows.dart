import 'package:flutter/material.dart';

/// Design System Shadows
///
/// This class defines the shadow styles for the application.
/// All shadow styles used in the application should be defined here.
class DSShadows {
  // Shadow Colors
  static const Color _shadowColor = Color(0x33000000); // 20% opacity
  static const Color _shadowColorDark = Color(0x66000000); // 40% opacity

  // Shadow Offsets
  static const Offset _offsetXs = Offset(0, 1);
  static const Offset _offsetSm = Offset(0, 2);
  static const Offset _offsetMd = Offset(0, 3);
  static const Offset _offsetLg = Offset(0, 4);
  static const Offset _offsetXl = Offset(0, 6);

  // Shadow Blur Radius
  static const double _blurXs = 2.0;
  static const double _blurSm = 4.0;
  static const double _blurMd = 8.0;
  static const double _blurLg = 16.0;
  static const double _blurXl = 24.0;

  // Shadow Spread Radius
  static const double _spreadXs = 0.0;
  static const double _spreadSm = 0.0;
  static const double _spreadMd = 1.0;
  static const double _spreadLg = 2.0;
  static const double _spreadXl = 3.0;

  // Shadow Styles
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> xs = [
    BoxShadow(
      color: _shadowColor,
      offset: _offsetXs,
      blurRadius: _blurXs,
      spreadRadius: _spreadXs,
    ),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: _shadowColor,
      offset: _offsetSm,
      blurRadius: _blurSm,
      spreadRadius: _spreadSm,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: _shadowColor,
      offset: _offsetMd,
      blurRadius: _blurMd,
      spreadRadius: _spreadMd,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: _shadowColor,
      offset: _offsetLg,
      blurRadius: _blurLg,
      spreadRadius: _spreadLg,
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: _shadowColor,
      offset: _offsetXl,
      blurRadius: _blurXl,
      spreadRadius: _spreadXl,
    ),
  ];

  // Dark Shadow Styles
  static const List<BoxShadow> xsDark = [
    BoxShadow(
      color: _shadowColorDark,
      offset: _offsetXs,
      blurRadius: _blurXs,
      spreadRadius: _spreadXs,
    ),
  ];

  static const List<BoxShadow> smDark = [
    BoxShadow(
      color: _shadowColorDark,
      offset: _offsetSm,
      blurRadius: _blurSm,
      spreadRadius: _spreadSm,
    ),
  ];

  static const List<BoxShadow> mdDark = [
    BoxShadow(
      color: _shadowColorDark,
      offset: _offsetMd,
      blurRadius: _blurMd,
      spreadRadius: _spreadMd,
    ),
  ];

  static const List<BoxShadow> lgDark = [
    BoxShadow(
      color: _shadowColorDark,
      offset: _offsetLg,
      blurRadius: _blurLg,
      spreadRadius: _spreadLg,
    ),
  ];

  static const List<BoxShadow> xlDark = [
    BoxShadow(
      color: _shadowColorDark,
      offset: _offsetXl,
      blurRadius: _blurXl,
      spreadRadius: _spreadXl,
    ),
  ];

  // Helper method to create custom shadow
  static List<BoxShadow> custom({
    Color color = const Color(0x33000000),
    Offset offset = const Offset(0, 2),
    double blurRadius = 4.0,
    double spreadRadius = 0.0,
  }) {
    return [
      BoxShadow(
        color: color,
        offset: offset,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }
}
