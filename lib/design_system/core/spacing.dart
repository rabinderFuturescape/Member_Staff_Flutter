import 'package:flutter/material.dart';

/// Design System Spacing
///
/// This class defines the spacing values for the application.
/// All spacing used in the application should be defined here.
class DSSpacing {
  // Base spacing unit (4.0)
  static const double unit = 4.0;

  // Spacing values
  static const double none = 0.0;
  static const double xxxs = unit * 0.5; // 2.0
  static const double xxs = unit; // 4.0
  static const double xs = unit * 2; // 8.0
  static const double sm = unit * 3; // 12.0
  static const double md = unit * 4; // 16.0
  static const double lg = unit * 6; // 24.0
  static const double xl = unit * 8; // 32.0
  static const double xxl = unit * 12; // 48.0
  static const double xxxl = unit * 16; // 64.0

  // Insets
  static const EdgeInsets insetNone = EdgeInsets.zero;
  
  static const EdgeInsets insetXxxs = EdgeInsets.all(xxxs);
  static const EdgeInsets insetXxs = EdgeInsets.all(xxs);
  static const EdgeInsets insetXs = EdgeInsets.all(xs);
  static const EdgeInsets insetSm = EdgeInsets.all(sm);
  static const EdgeInsets insetMd = EdgeInsets.all(md);
  static const EdgeInsets insetLg = EdgeInsets.all(lg);
  static const EdgeInsets insetXl = EdgeInsets.all(xl);
  static const EdgeInsets insetXxl = EdgeInsets.all(xxl);
  static const EdgeInsets insetXxxl = EdgeInsets.all(xxxl);

  // Horizontal Insets
  static const EdgeInsets insetHorizontalXxxs = EdgeInsets.symmetric(horizontal: xxxs);
  static const EdgeInsets insetHorizontalXxs = EdgeInsets.symmetric(horizontal: xxs);
  static const EdgeInsets insetHorizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets insetHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets insetHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets insetHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets insetHorizontalXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets insetHorizontalXxl = EdgeInsets.symmetric(horizontal: xxl);
  static const EdgeInsets insetHorizontalXxxl = EdgeInsets.symmetric(horizontal: xxxl);

  // Vertical Insets
  static const EdgeInsets insetVerticalXxxs = EdgeInsets.symmetric(vertical: xxxs);
  static const EdgeInsets insetVerticalXxs = EdgeInsets.symmetric(vertical: xxs);
  static const EdgeInsets insetVerticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets insetVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets insetVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets insetVerticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets insetVerticalXl = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets insetVerticalXxl = EdgeInsets.symmetric(vertical: xxl);
  static const EdgeInsets insetVerticalXxxl = EdgeInsets.symmetric(vertical: xxxl);

  // Gaps
  static const SizedBox gapNone = SizedBox.shrink();
  
  static const SizedBox gapHorizontalXxxs = SizedBox(width: xxxs);
  static const SizedBox gapHorizontalXxs = SizedBox(width: xxs);
  static const SizedBox gapHorizontalXs = SizedBox(width: xs);
  static const SizedBox gapHorizontalSm = SizedBox(width: sm);
  static const SizedBox gapHorizontalMd = SizedBox(width: md);
  static const SizedBox gapHorizontalLg = SizedBox(width: lg);
  static const SizedBox gapHorizontalXl = SizedBox(width: xl);
  static const SizedBox gapHorizontalXxl = SizedBox(width: xxl);
  static const SizedBox gapHorizontalXxxl = SizedBox(width: xxxl);
  
  static const SizedBox gapVerticalXxxs = SizedBox(height: xxxs);
  static const SizedBox gapVerticalXxs = SizedBox(height: xxs);
  static const SizedBox gapVerticalXs = SizedBox(height: xs);
  static const SizedBox gapVerticalSm = SizedBox(height: sm);
  static const SizedBox gapVerticalMd = SizedBox(height: md);
  static const SizedBox gapVerticalLg = SizedBox(height: lg);
  static const SizedBox gapVerticalXl = SizedBox(height: xl);
  static const SizedBox gapVerticalXxl = SizedBox(height: xxl);
  static const SizedBox gapVerticalXxxl = SizedBox(height: xxxl);

  // Helper method to create custom horizontal gap
  static SizedBox gapHorizontal(double width) => SizedBox(width: width);
  
  // Helper method to create custom vertical gap
  static SizedBox gapVertical(double height) => SizedBox(height: height);
  
  // Helper method to create custom insets
  static EdgeInsets insets({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(all);
    }
    
    return EdgeInsets.only(
      left: left ?? horizontal ?? 0.0,
      top: top ?? vertical ?? 0.0,
      right: right ?? horizontal ?? 0.0,
      bottom: bottom ?? vertical ?? 0.0,
    );
  }
}
