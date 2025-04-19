import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/core.dart';

/// Design System Provider
///
/// This class provides the design system state and methods to customize the design system.
class DesignSystemProvider extends ChangeNotifier {
  // Keys for shared preferences
  static const String _fontSizeScaleKey = 'font_size_scale';
  static const String _animationsEnabledKey = 'animations_enabled';
  static const String _reducedMotionKey = 'reduced_motion';
  static const String _highContrastKey = 'high_contrast';
  
  // Default values
  double _fontSizeScale = 1.0;
  bool _animationsEnabled = true;
  bool _reducedMotion = false;
  bool _highContrast = false;
  
  /// Get the font size scale
  double get fontSizeScale => _fontSizeScale;
  
  /// Check if animations are enabled
  bool get animationsEnabled => _animationsEnabled;
  
  /// Check if reduced motion is enabled
  bool get reducedMotion => _reducedMotion;
  
  /// Check if high contrast is enabled
  bool get highContrast => _highContrast;
  
  /// Initialize the design system provider
  Future<void> initialize() async {
    await _loadPreferences();
  }
  
  /// Set the font size scale
  Future<void> setFontSizeScale(double scale) async {
    if (scale < 0.8 || scale > 1.5) {
      return;
    }
    
    _fontSizeScale = scale;
    await _saveFontSizeScale();
    notifyListeners();
  }
  
  /// Increase the font size scale
  Future<void> increaseFontSize() async {
    await setFontSizeScale(_fontSizeScale + 0.1);
  }
  
  /// Decrease the font size scale
  Future<void> decreaseFontSize() async {
    await setFontSizeScale(_fontSizeScale - 0.1);
  }
  
  /// Reset the font size scale to default
  Future<void> resetFontSize() async {
    await setFontSizeScale(1.0);
  }
  
  /// Set whether animations are enabled
  Future<void> setAnimationsEnabled(bool enabled) async {
    _animationsEnabled = enabled;
    await _saveAnimationsEnabled();
    notifyListeners();
  }
  
  /// Toggle animations enabled
  Future<void> toggleAnimations() async {
    await setAnimationsEnabled(!_animationsEnabled);
  }
  
  /// Set whether reduced motion is enabled
  Future<void> setReducedMotion(bool enabled) async {
    _reducedMotion = enabled;
    await _saveReducedMotion();
    notifyListeners();
  }
  
  /// Toggle reduced motion
  Future<void> toggleReducedMotion() async {
    await setReducedMotion(!_reducedMotion);
  }
  
  /// Set whether high contrast is enabled
  Future<void> setHighContrast(bool enabled) async {
    _highContrast = enabled;
    await _saveHighContrast();
    notifyListeners();
  }
  
  /// Toggle high contrast
  Future<void> toggleHighContrast() async {
    await setHighContrast(!_highContrast);
  }
  
  /// Load preferences from shared preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    _fontSizeScale = prefs.getDouble(_fontSizeScaleKey) ?? 1.0;
    _animationsEnabled = prefs.getBool(_animationsEnabledKey) ?? true;
    _reducedMotion = prefs.getBool(_reducedMotionKey) ?? false;
    _highContrast = prefs.getBool(_highContrastKey) ?? false;
  }
  
  /// Save font size scale to shared preferences
  Future<void> _saveFontSizeScale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeScaleKey, _fontSizeScale);
  }
  
  /// Save animations enabled to shared preferences
  Future<void> _saveAnimationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_animationsEnabledKey, _animationsEnabled);
  }
  
  /// Save reduced motion to shared preferences
  Future<void> _saveReducedMotion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reducedMotionKey, _reducedMotion);
  }
  
  /// Save high contrast to shared preferences
  Future<void> _saveHighContrast() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, _highContrast);
  }
  
  /// Get the appropriate animation duration based on the current settings
  Duration getAnimationDuration(Duration defaultDuration) {
    if (!_animationsEnabled) {
      return Duration.zero;
    }
    
    if (_reducedMotion) {
      return Duration(milliseconds: (defaultDuration.inMilliseconds * 0.5).round());
    }
    
    return defaultDuration;
  }
  
  /// Get the appropriate text style with the current font size scale applied
  TextStyle getScaledTextStyle(TextStyle style) {
    return style.copyWith(
      fontSize: style.fontSize != null ? style.fontSize! * _fontSizeScale : null,
    );
  }
  
  /// Get the appropriate color based on the high contrast setting
  Color getAccessibleColor(Color color, Color highContrastColor) {
    return _highContrast ? highContrastColor : color;
  }
}
