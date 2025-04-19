import 'package:flutter/material.dart';

/// Design system animations
class DSAnimations {
  /// Extra fast duration (100ms)
  static const Duration durationXFast = Duration(milliseconds: 100);
  
  /// Fast duration (200ms)
  static const Duration durationFast = Duration(milliseconds: 200);
  
  /// Medium duration (300ms)
  static const Duration durationMedium = Duration(milliseconds: 300);
  
  /// Slow duration (400ms)
  static const Duration durationSlow = Duration(milliseconds: 400);
  
  /// Extra slow duration (500ms)
  static const Duration durationXSlow = Duration(milliseconds: 500);
  
  /// Linear curve
  static const Curve linear = Curves.linear;
  
  /// Ease curve
  static const Curve ease = Curves.ease;
  
  /// Ease in curve
  static const Curve easeIn = Curves.easeIn;
  
  /// Ease out curve
  static const Curve easeOut = Curves.easeOut;
  
  /// Ease in out curve
  static const Curve easeInOut = Curves.easeInOut;
  
  /// Decelerate curve
  static const Curve decelerate = Curves.decelerate;
  
  /// Bounce in curve
  static const Curve bounceIn = Curves.bounceIn;
  
  /// Bounce out curve
  static const Curve bounceOut = Curves.bounceOut;
  
  /// Bounce in out curve
  static const Curve bounceInOut = Curves.bounceInOut;
  
  /// Elastic in curve
  static const Curve elasticIn = Curves.elasticIn;
  
  /// Elastic out curve
  static const Curve elasticOut = Curves.elasticOut;
  
  /// Elastic in out curve
  static const Curve elasticInOut = Curves.elasticInOut;
}
