import 'package:flutter/material.dart';

/// Constants for animations throughout the app.
class AnimationConstants {
  /// Duration for short animations (e.g., micro-interactions)
  static const Duration shortDuration = Duration(milliseconds: 150);
  
  /// Duration for medium animations (e.g., page transitions)
  static const Duration mediumDuration = Duration(milliseconds: 300);
  
  /// Duration for long animations (e.g., complex sequences)
  static const Duration longDuration = Duration(milliseconds: 500);
  
  /// Standard curve for most animations
  static const Curve standardCurve = Curves.easeInOut;
  
  /// Curve for entrance animations
  static const Curve entranceCurve = Curves.easeOutQuint;
  
  /// Curve for exit animations
  static const Curve exitCurve = Curves.easeInQuint;
  
  /// Curve for bounce animations
  static const Curve bounceCurve = Curves.elasticOut;
  
  /// Offset for slide-in animations (from right)
  static const Offset slideInRightOffset = Offset(1.0, 0.0);
  
  /// Offset for slide-in animations (from left)
  static const Offset slideInLeftOffset = Offset(-1.0, 0.0);
  
  /// Offset for slide-in animations (from bottom)
  static const Offset slideInBottomOffset = Offset(0.0, 1.0);
  
  /// Offset for slide-in animations (from top)
  static const Offset slideInTopOffset = Offset(0.0, -1.0);
  
  /// Default stagger interval for list animations
  static const double staggerInterval = 0.05;
}
