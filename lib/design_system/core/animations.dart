import 'package:flutter/material.dart';

/// Design System Animations
///
/// This class defines the animation styles for the application.
/// All animation styles used in the application should be defined here.
class DSAnimations {
  // Duration
  static const Duration durationXxs = Duration(milliseconds: 50);
  static const Duration durationXs = Duration(milliseconds: 100);
  static const Duration durationSm = Duration(milliseconds: 150);
  static const Duration durationMd = Duration(milliseconds: 300);
  static const Duration durationLg = Duration(milliseconds: 500);
  static const Duration durationXl = Duration(milliseconds: 800);
  static const Duration durationXxl = Duration(milliseconds: 1200);

  // Standard Curves
  static const Curve curveStandard = Curves.easeInOut;
  static const Curve curveAccelerate = Curves.easeIn;
  static const Curve curveDecelerate = Curves.easeOut;
  static const Curve curveSharp = Curves.easeInOutCubic;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveSpring = Curves.elasticInOut;

  // Page Transitions
  static const Curve curvePageForward = Curves.easeInOut;
  static const Curve curvePageBackward = Curves.easeInOut;
  static const Duration durationPageTransition = Duration(milliseconds: 300);

  // Offsets for Slide Transitions
  static const Offset offsetSlideInRight = Offset(1.0, 0.0);
  static const Offset offsetSlideInLeft = Offset(-1.0, 0.0);
  static const Offset offsetSlideInUp = Offset(0.0, 1.0);
  static const Offset offsetSlideInDown = Offset(0.0, -1.0);
  static const Offset offsetCenter = Offset(0.0, 0.0);

  // Stagger Interval
  static const double staggerInterval = 0.05;

  // Helper method for creating a staggered animation
  static Duration staggeredDuration(int index, {double interval = staggerInterval}) {
    return Duration(milliseconds: (index * interval * 1000).toInt());
  }

  // Page Route Builders
  static PageRouteBuilder<T> fadeTransition<T>({
    required Widget page,
    Duration duration = durationPageTransition,
    Curve curve = curveStandard,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder<T> slideTransition<T>({
    required Widget page,
    Duration duration = durationPageTransition,
    Curve curve = curveStandard,
    Offset beginOffset = offsetSlideInRight,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: offsetCenter,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder<T> scaleTransition<T>({
    required Widget page,
    Duration duration = durationPageTransition,
    Curve curve = curveStandard,
    double beginScale = 0.8,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        return ScaleTransition(
          scale: Tween<double>(
            begin: beginScale,
            end: 1.0,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder<T> fadeAndScaleTransition<T>({
    required Widget page,
    Duration duration = durationPageTransition,
    Curve curve = curveStandard,
    double beginScale = 0.9,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: beginScale,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
}
