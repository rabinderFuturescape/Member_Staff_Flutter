import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/themes.dart';

/// Theme Provider
///
/// This class provides the theme state and methods to change the theme.
class ThemeProvider extends ChangeNotifier {
  // Theme mode key for shared preferences
  static const String _themeModeKey = 'theme_mode';
  
  // Default theme mode
  ThemeMode _themeMode = ThemeMode.system;
  
  /// Get the current theme mode
  ThemeMode get themeMode => _themeMode;
  
  /// Get the light theme
  ThemeData get lightTheme => AppTheme.lightTheme;
  
  /// Get the dark theme
  ThemeData get darkTheme => AppTheme.darkTheme;
  
  /// Check if the current theme is dark
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  /// Check if the current theme is light
  bool get isLightMode => _themeMode == ThemeMode.light;
  
  /// Check if the current theme is system
  bool get isSystemMode => _themeMode == ThemeMode.system;
  
  /// Initialize the theme provider
  Future<void> initialize() async {
    await _loadThemeMode();
  }
  
  /// Set the theme mode to light
  Future<void> setLightMode() async {
    _themeMode = ThemeMode.light;
    await _saveThemeMode();
    AppTheme.updateSystemUIOverlayStyle(Brightness.light);
    notifyListeners();
  }
  
  /// Set the theme mode to dark
  Future<void> setDarkMode() async {
    _themeMode = ThemeMode.dark;
    await _saveThemeMode();
    AppTheme.updateSystemUIOverlayStyle(Brightness.dark);
    notifyListeners();
  }
  
  /// Set the theme mode to system
  Future<void> setSystemMode() async {
    _themeMode = ThemeMode.system;
    await _saveThemeMode();
    // System UI overlay style will be updated based on the system brightness
    notifyListeners();
  }
  
  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setDarkMode();
    } else if (_themeMode == ThemeMode.dark) {
      await setLightMode();
    } else {
      // If system mode, check the current system brightness
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      if (brightness == Brightness.light) {
        await setDarkMode();
      } else {
        await setLightMode();
      }
    }
  }
  
  /// Load the theme mode from shared preferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(_themeModeKey);
    
    if (themeModeIndex != null) {
      _themeMode = ThemeMode.values[themeModeIndex];
    }
  }
  
  /// Save the theme mode to shared preferences
  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, _themeMode.index);
  }
  
  /// Get the current theme based on the theme mode and system brightness
  ThemeData getCurrentTheme(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      final brightness = MediaQuery.of(context).platformBrightness;
      return brightness == Brightness.light ? lightTheme : darkTheme;
    }
    
    return _themeMode == ThemeMode.light ? lightTheme : darkTheme;
  }
}
