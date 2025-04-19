import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/cms_config.dart';
import 'cms_auth_service.dart';

/// Service for handling CMS localization
class CMSLocalizationService {
  /// Authentication service
  final CMSAuthService _authService = CMSAuthService();
  
  /// Shared preferences instance
  late final SharedPreferences _prefs;
  
  /// Base URL for the Strapi CMS API
  final String _baseUrl = CMSConfig.baseUrl;
  
  /// Cache keys
  static const String _localesKey = 'cms_locales';
  static const String _translationsKey = 'cms_translations';
  static const String _currentLocaleKey = 'cms_current_locale';
  static const String _lastUpdatedKey = 'cms_localization_last_updated';
  
  /// Cache expiration time (24 hours)
  static const Duration _cacheExpiration = Duration(hours: 24);
  
  /// Initialize the localization service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Set default locale if not set
    if (getCurrentLocale() == null) {
      await setCurrentLocale(const Locale('en', 'US'));
    }
  }
  
  /// Check if the cache is expired
  bool isCacheExpired(String key) {
    final lastUpdated = _prefs.getString('${_lastUpdatedKey}_$key');
    if (lastUpdated == null) {
      return true;
    }
    
    final lastUpdatedTime = DateTime.parse(lastUpdated);
    final now = DateTime.now();
    
    return now.difference(lastUpdatedTime) > _cacheExpiration;
  }
  
  /// Update the last updated time
  Future<void> updateLastUpdated(String key) async {
    await _prefs.setString('${_lastUpdatedKey}_$key', DateTime.now().toIso8601String());
  }
  
  /// Get the current locale
  Locale? getCurrentLocale() {
    final localeString = _prefs.getString(_currentLocaleKey);
    if (localeString == null) {
      return null;
    }
    
    final parts = localeString.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    } else {
      return Locale(parts[0]);
    }
  }
  
  /// Set the current locale
  Future<void> setCurrentLocale(Locale locale) async {
    final localeString = locale.countryCode != null
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
    
    await _prefs.setString(_currentLocaleKey, localeString);
  }
  
  /// Get all available locales
  Future<List<Locale>> getLocales({bool forceRefresh = false}) async {
    // Check cache first if not forcing refresh
    if (!forceRefresh && !isCacheExpired(_localesKey)) {
      final cachedLocales = _prefs.getStringList(_localesKey);
      if (cachedLocales != null) {
        return cachedLocales.map((localeString) {
          final parts = localeString.split('_');
          if (parts.length == 2) {
            return Locale(parts[0], parts[1]);
          } else {
            return Locale(parts[0]);
          }
        }).toList();
      }
    }
    
    try {
      // Get headers with authentication token
      final headers = await _authService.getHeaders();
      
      // Build the URL
      final url = '$_baseUrl/api/i18n/locales';
      
      // Make the HTTP request
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to load locales: ${response.statusCode}');
      }
      
      // Parse the response
      final List<dynamic> data = jsonDecode(response.body);
      final locales = data.map((item) {
        final code = item['code'] as String;
        final parts = code.split('-');
        if (parts.length == 2) {
          return Locale(parts[0], parts[1]);
        } else {
          return Locale(parts[0]);
        }
      }).toList();
      
      // Cache the locales
      await _prefs.setStringList(
        _localesKey,
        locales.map((locale) {
          return locale.countryCode != null
              ? '${locale.languageCode}_${locale.countryCode}'
              : locale.languageCode;
        }).toList(),
      );
      
      await updateLastUpdated(_localesKey);
      
      return locales;
    } catch (e) {
      print('Error getting locales: $e');
      
      // Try to return cached data even if it's expired
      final cachedLocales = _prefs.getStringList(_localesKey);
      if (cachedLocales != null) {
        return cachedLocales.map((localeString) {
          final parts = localeString.split('_');
          if (parts.length == 2) {
            return Locale(parts[0], parts[1]);
          } else {
            return Locale(parts[0]);
          }
        }).toList();
      }
      
      // Return default locale if no cached data
      return [const Locale('en', 'US')];
    }
  }
  
  /// Get translations for a locale
  Future<Map<String, String>> getTranslations(Locale locale, {bool forceRefresh = false}) async {
    final localeString = locale.countryCode != null
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
    
    final key = '${_translationsKey}_$localeString';
    
    // Check cache first if not forcing refresh
    if (!forceRefresh && !isCacheExpired(key)) {
      final cachedTranslations = _prefs.getString(key);
      if (cachedTranslations != null) {
        final Map<String, dynamic> decodedTranslations = jsonDecode(cachedTranslations);
        return decodedTranslations.map((key, value) => MapEntry(key, value.toString()));
      }
    }
    
    try {
      // Get headers with authentication token
      final headers = await _authService.getHeaders();
      
      // Build the URL
      final localeCode = locale.countryCode != null
          ? '${locale.languageCode}-${locale.countryCode}'
          : locale.languageCode;
      
      final url = '$_baseUrl/api/i18n/translations/$localeCode';
      
      // Make the HTTP request
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to load translations: ${response.statusCode}');
      }
      
      // Parse the response
      final Map<String, dynamic> data = jsonDecode(response.body);
      final translations = data.map((key, value) => MapEntry(key, value.toString()));
      
      // Cache the translations
      await _prefs.setString(key, jsonEncode(translations));
      await updateLastUpdated(key);
      
      return translations;
    } catch (e) {
      print('Error getting translations: $e');
      
      // Try to return cached data even if it's expired
      final cachedTranslations = _prefs.getString(key);
      if (cachedTranslations != null) {
        final Map<String, dynamic> decodedTranslations = jsonDecode(cachedTranslations);
        return decodedTranslations.map((key, value) => MapEntry(key, value.toString()));
      }
      
      // Return empty map if no cached data
      return {};
    }
  }
  
  /// Translate a key
  Future<String> translate(String key, {Map<String, String>? args, Locale? locale}) async {
    final currentLocale = locale ?? getCurrentLocale() ?? const Locale('en', 'US');
    final translations = await getTranslations(currentLocale);
    
    if (!translations.containsKey(key)) {
      return key;
    }
    
    String translation = translations[key]!;
    
    // Replace arguments
    if (args != null) {
      args.forEach((argKey, argValue) {
        translation = translation.replaceAll('{$argKey}', argValue);
      });
    }
    
    return translation;
  }
  
  /// Clear all cache
  Future<void> clearCache() async {
    await _prefs.remove(_localesKey);
    await _prefs.remove(_currentLocaleKey);
    
    // Remove all translation keys
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_translationsKey)) {
        await _prefs.remove(key);
      }
    }
    
    // Remove all last updated keys
    for (final key in keys) {
      if (key.startsWith(_lastUpdatedKey)) {
        await _prefs.remove(key);
      }
    }
  }
}
