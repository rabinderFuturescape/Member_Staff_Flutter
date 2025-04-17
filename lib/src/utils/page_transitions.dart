import 'package:flutter/material.dart';
import 'animation_constants.dart';

/// Custom page route that slides and fades in from the right
class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  
  SlideRightRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: AnimationConstants.entranceCurve,
            );
            
            return SlideTransition(
              position: Tween<Offset>(
                begin: AnimationConstants.slideInRightOffset,
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
                child: child,
              ),
            );
          },
          transitionDuration: AnimationConstants.mediumDuration,
        );
}

/// Custom page route that slides and fades in from the bottom
class SlideUpRoute extends PageRouteBuilder {
  final Widget page;
  
  SlideUpRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: AnimationConstants.entranceCurve,
            );
            
            return SlideTransition(
              position: Tween<Offset>(
                begin: AnimationConstants.slideInBottomOffset,
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
                child: child,
              ),
            );
          },
          transitionDuration: AnimationConstants.mediumDuration,
        );
}

/// Custom page route with a fade transition
class FadeRoute extends PageRouteBuilder {
  final Widget page;
  
  FadeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: AnimationConstants.standardCurve,
                ),
              ),
              child: child,
            );
          },
          transitionDuration: AnimationConstants.mediumDuration,
        );
}

/// Extension on Navigator to add custom transitions
extension NavigatorExtension on NavigatorState {
  /// Push a route with a slide right animation
  Future<T?> pushSlideRight<T extends Object?>(Widget page) {
    return push<T>(SlideRightRoute(page: page));
  }
  
  /// Push a route with a slide up animation
  Future<T?> pushSlideUp<T extends Object?>(Widget page) {
    return push<T>(SlideUpRoute(page: page));
  }
  
  /// Push a route with a fade animation
  Future<T?> pushFade<T extends Object?>(Widget page) {
    return push<T>(FadeRoute(page: page));
  }
}
