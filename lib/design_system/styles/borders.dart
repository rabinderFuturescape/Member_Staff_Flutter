import 'package:flutter/material.dart';
import 'colors.dart';

/// Design system borders
class DSBorders {
  /// Extra small border radius (4.0)
  static const double radiusXs = 4.0;
  
  /// Small border radius (8.0)
  static const double radiusSm = 8.0;
  
  /// Medium border radius (12.0)
  static const double radiusMd = 12.0;
  
  /// Large border radius (16.0)
  static const double radiusLg = 16.0;
  
  /// Extra large border radius (24.0)
  static const double radiusXl = 24.0;
  
  /// Circular border radius (1000.0)
  static const double radiusCircular = 1000.0;
  
  /// Extra small border width (0.5)
  static const double widthXs = 0.5;
  
  /// Small border width (1.0)
  static const double widthSm = 1.0;
  
  /// Medium border width (2.0)
  static const double widthMd = 2.0;
  
  /// Large border width (3.0)
  static const double widthLg = 3.0;
  
  /// Extra large border width (4.0)
  static const double widthXl = 4.0;
  
  /// Default border
  static Border get border => Border.all(
    color: DSColors.divider,
    width: widthSm,
  );
  
  /// Primary border
  static Border get primaryBorder => Border.all(
    color: DSColors.primary,
    width: widthSm,
  );
  
  /// Error border
  static Border get errorBorder => Border.all(
    color: DSColors.error,
    width: widthSm,
  );
  
  /// Success border
  static Border get successBorder => Border.all(
    color: DSColors.success,
    width: widthSm,
  );
  
  /// Warning border
  static Border get warningBorder => Border.all(
    color: DSColors.warning,
    width: widthSm,
  );
  
  /// Info border
  static Border get infoBorder => Border.all(
    color: DSColors.info,
    width: widthSm,
  );
}
