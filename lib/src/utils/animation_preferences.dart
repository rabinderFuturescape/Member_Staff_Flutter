import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility class for managing animation preferences.
class AnimationPreferences {
  static const String _animationsEnabledKey = 'animations_enabled';
  static const String _reducedMotionKey = 'reduced_motion';
  
  /// Checks if animations are enabled.
  static Future<bool> areAnimationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_animationsEnabledKey) ?? true;
  }
  
  /// Sets whether animations are enabled.
  static Future<void> setAnimationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_animationsEnabledKey, enabled);
  }
  
  /// Checks if reduced motion is enabled.
  static Future<bool> isReducedMotionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reducedMotionKey) ?? false;
  }
  
  /// Sets whether reduced motion is enabled.
  static Future<void> setReducedMotionEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reducedMotionKey, enabled);
  }
  
  /// Gets the appropriate animation duration based on preferences.
  static Future<Duration> getAnimationDuration(Duration normalDuration) async {
    final animationsEnabled = await areAnimationsEnabled();
    if (!animationsEnabled) {
      return Duration.zero;
    }
    
    final reducedMotion = await isReducedMotionEnabled();
    if (reducedMotion) {
      return Duration(milliseconds: normalDuration.inMilliseconds ~/ 2);
    }
    
    return normalDuration;
  }
}

/// A provider for animation preferences.
class AnimationPreferencesProvider extends ChangeNotifier {
  bool _animationsEnabled = true;
  bool _reducedMotion = false;
  bool _isLoading = true;
  
  AnimationPreferencesProvider() {
    _loadPreferences();
  }
  
  /// Whether animations are enabled.
  bool get animationsEnabled => _animationsEnabled;
  
  /// Whether reduced motion is enabled.
  bool get reducedMotion => _reducedMotion;
  
  /// Whether the preferences are still loading.
  bool get isLoading => _isLoading;
  
  /// Loads the preferences from shared preferences.
  Future<void> _loadPreferences() async {
    _isLoading = true;
    notifyListeners();
    
    _animationsEnabled = await AnimationPreferences.areAnimationsEnabled();
    _reducedMotion = await AnimationPreferences.isReducedMotionEnabled();
    
    _isLoading = false;
    notifyListeners();
  }
  
  /// Sets whether animations are enabled.
  Future<void> setAnimationsEnabled(bool enabled) async {
    await AnimationPreferences.setAnimationsEnabled(enabled);
    _animationsEnabled = enabled;
    notifyListeners();
  }
  
  /// Sets whether reduced motion is enabled.
  Future<void> setReducedMotionEnabled(bool enabled) async {
    await AnimationPreferences.setReducedMotionEnabled(enabled);
    _reducedMotion = enabled;
    notifyListeners();
  }
  
  /// Gets the appropriate animation duration based on preferences.
  Duration getAnimationDuration(Duration normalDuration) {
    if (!_animationsEnabled) {
      return Duration.zero;
    }
    
    if (_reducedMotion) {
      return Duration(milliseconds: normalDuration.inMilliseconds ~/ 2);
    }
    
    return normalDuration;
  }
}
