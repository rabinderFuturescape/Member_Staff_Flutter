import 'package:flutter/material.dart';
import '../services/cms_localization_service.dart';

/// Provider for CMS localization
class CMSLocalizationProvider extends ChangeNotifier {
  /// Localization service
  final CMSLocalizationService _localizationService = CMSLocalizationService();
  
  /// Current locale
  Locale? _currentLocale;
  
  /// Available locales
  List<Locale> _availableLocales = [];
  
  /// Translations for the current locale
  Map<String, String> _translations = {};
  
  /// Loading state
  bool _isLoading = false;
  
  /// Error message
  String? _errorMessage;
  
  /// Get the current locale
  Locale? get currentLocale => _currentLocale;
  
  /// Get available locales
  List<Locale> get availableLocales => _availableLocales;
  
  /// Get translations
  Map<String, String> get translations => _translations;
  
  /// Get loading state
  bool get isLoading => _isLoading;
  
  /// Get error message
  String? get errorMessage => _errorMessage;
  
  /// Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      await _localizationService.initialize();
      
      // Get current locale
      _currentLocale = _localizationService.getCurrentLocale();
      
      // Get available locales
      await loadLocales();
      
      // Get translations for current locale
      if (_currentLocale != null) {
        await loadTranslations(_currentLocale!);
      }
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to initialize localization: $e');
    }
  }
  
  /// Load available locales
  Future<void> loadLocales({bool forceRefresh = false}) async {
    _setLoading(true);
    
    try {
      _availableLocales = await _localizationService.getLocales(forceRefresh: forceRefresh);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load locales: $e');
    }
  }
  
  /// Load translations for a locale
  Future<void> loadTranslations(Locale locale, {bool forceRefresh = false}) async {
    _setLoading(true);
    
    try {
      _translations = await _localizationService.getTranslations(locale, forceRefresh: forceRefresh);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load translations: $e');
    }
  }
  
  /// Set the current locale
  Future<void> setLocale(Locale locale) async {
    _setLoading(true);
    
    try {
      await _localizationService.setCurrentLocale(locale);
      _currentLocale = locale;
      await loadTranslations(locale);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to set locale: $e');
    }
  }
  
  /// Translate a key
  Future<String> translate(String key, {Map<String, String>? args}) async {
    if (_currentLocale == null) {
      return key;
    }
    
    return await _localizationService.translate(key, args: args, locale: _currentLocale);
  }
  
  /// Clear cache
  Future<void> clearCache() async {
    _setLoading(true);
    
    try {
      await _localizationService.clearCache();
      await initialize();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to clear cache: $e');
    }
  }
  
  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Set error message
  void _setError(String error) {
    _isLoading = false;
    _errorMessage = error;
    notifyListeners();
  }
}
