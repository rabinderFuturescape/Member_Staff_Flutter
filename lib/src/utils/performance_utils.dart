import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Utility class for performance optimization.
class PerformanceUtils {
  /// Checks if the device is a low-end device based on the device frame time.
  static bool isLowEndDevice() {
    final frameTime = SchedulerBinding.instance.currentFrameTimeStamp;
    final lastFrameTime = SchedulerBinding.instance.currentSystemFrameTimeStamp;
    
    // If the frame time is more than 16ms (60fps), it's a low-end device
    return (lastFrameTime - frameTime).inMilliseconds > 16;
  }
  
  /// Gets the appropriate animation duration based on the device performance.
  static Duration getAnimationDuration(Duration normalDuration) {
    if (isLowEndDevice()) {
      // Reduce animation duration for low-end devices
      return Duration(milliseconds: normalDuration.inMilliseconds ~/ 2);
    }
    
    return normalDuration;
  }
  
  /// Throttles a callback to prevent excessive calls.
  static Function throttle(Function callback, Duration duration) {
    DateTime lastCall = DateTime.now();
    
    return () {
      final now = DateTime.now();
      if (now.difference(lastCall) >= duration) {
        lastCall = now;
        callback();
      }
    };
  }
  
  /// Debounces a callback to delay execution until after a pause.
  static Function debounce(Function callback, Duration duration) {
    Timer? timer;
    
    return () {
      if (timer != null) {
        timer!.cancel();
      }
      
      timer = Timer(duration, () {
        callback();
      });
    };
  }
}

/// A widget that optimizes animations based on device performance.
class PerformanceOptimizedAnimations extends StatelessWidget {
  final Widget Function(BuildContext, bool) builder;
  
  const PerformanceOptimizedAnimations({
    Key? key,
    required this.builder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return builder(context, PerformanceUtils.isLowEndDevice());
  }
}

/// A widget that only rebuilds when necessary.
class OptimizedBuilder extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  final bool Function(OptimizedBuilderState oldState, OptimizedBuilderState newState)? shouldRebuild;
  
  const OptimizedBuilder({
    Key? key,
    required this.builder,
    this.shouldRebuild,
  }) : super(key: key);
  
  @override
  State<OptimizedBuilder> createState() => OptimizedBuilderState();
}

class OptimizedBuilderState extends State<OptimizedBuilder> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
  
  @override
  void didUpdateWidget(OptimizedBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final shouldRebuild = widget.shouldRebuild;
    if (shouldRebuild != null && !shouldRebuild(this as OptimizedBuilderState, this)) {
      return;
    }
  }
}
