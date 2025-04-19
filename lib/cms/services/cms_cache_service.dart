import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cms_models.dart';

/// Service for caching CMS content
class CMSCacheService {
  /// Shared preferences instance
  late final SharedPreferences _prefs;
  
  /// Cache keys
  static const String _pagesKey = 'cms_pages';
  static const String _featuresKey = 'cms_features';
  static const String _settingsKey = 'cms_settings';
  static const String _notificationsKey = 'cms_notifications';
  static const String _faqsKey = 'cms_faqs';
  static const String _faqCategoriesKey = 'cms_faq_categories';
  static const String _lastUpdatedKey = 'cms_last_updated';
  
  /// Cache expiration time (24 hours)
  static const Duration _cacheExpiration = Duration(hours: 24);
  
  /// Initialize the cache service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
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
  
  /// Cache pages
  Future<void> cachePages(List<CMSPage> pages) async {
    final pagesJson = pages.map((page) => page.toJson()).toList();
    await _prefs.setString(_pagesKey, jsonEncode(pagesJson));
    await updateLastUpdated(_pagesKey);
  }
  
  /// Get cached pages
  List<CMSPage>? getCachedPages() {
    if (isCacheExpired(_pagesKey)) {
      return null;
    }
    
    final pagesJson = _prefs.getString(_pagesKey);
    if (pagesJson == null) {
      return null;
    }
    
    final List<dynamic> decodedPages = jsonDecode(pagesJson);
    return decodedPages.map((page) => CMSPage.fromJson(page)).toList();
  }
  
  /// Cache page by slug
  Future<void> cachePageBySlug(String slug, CMSPage page) async {
    final key = '${_pagesKey}_$slug';
    await _prefs.setString(key, jsonEncode(page.toJson()));
    await updateLastUpdated(key);
  }
  
  /// Get cached page by slug
  CMSPage? getCachedPageBySlug(String slug) {
    final key = '${_pagesKey}_$slug';
    if (isCacheExpired(key)) {
      return null;
    }
    
    final pageJson = _prefs.getString(key);
    if (pageJson == null) {
      return null;
    }
    
    return CMSPage.fromJson(jsonDecode(pageJson));
  }
  
  /// Cache features
  Future<void> cacheFeatures(List<CMSFeature> features) async {
    final featuresJson = features.map((feature) => feature.toJson()).toList();
    await _prefs.setString(_featuresKey, jsonEncode(featuresJson));
    await updateLastUpdated(_featuresKey);
  }
  
  /// Get cached features
  List<CMSFeature>? getCachedFeatures() {
    if (isCacheExpired(_featuresKey)) {
      return null;
    }
    
    final featuresJson = _prefs.getString(_featuresKey);
    if (featuresJson == null) {
      return null;
    }
    
    final List<dynamic> decodedFeatures = jsonDecode(featuresJson);
    return decodedFeatures.map((feature) => CMSFeature.fromJson(feature)).toList();
  }
  
  /// Cache settings
  Future<void> cacheSettings(CMSSettings settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
    await updateLastUpdated(_settingsKey);
  }
  
  /// Get cached settings
  CMSSettings? getCachedSettings() {
    if (isCacheExpired(_settingsKey)) {
      return null;
    }
    
    final settingsJson = _prefs.getString(_settingsKey);
    if (settingsJson == null) {
      return null;
    }
    
    return CMSSettings.fromJson(jsonDecode(settingsJson));
  }
  
  /// Cache notifications
  Future<void> cacheNotifications(List<CMSNotification> notifications) async {
    final notificationsJson = notifications.map((notification) => notification.toJson()).toList();
    await _prefs.setString(_notificationsKey, jsonEncode(notificationsJson));
    await updateLastUpdated(_notificationsKey);
  }
  
  /// Get cached notifications
  List<CMSNotification>? getCachedNotifications() {
    if (isCacheExpired(_notificationsKey)) {
      return null;
    }
    
    final notificationsJson = _prefs.getString(_notificationsKey);
    if (notificationsJson == null) {
      return null;
    }
    
    final List<dynamic> decodedNotifications = jsonDecode(notificationsJson);
    return decodedNotifications.map((notification) => CMSNotification.fromJson(notification)).toList();
  }
  
  /// Cache FAQs
  Future<void> cacheFAQs(List<CMSFAQ> faqs) async {
    final faqsJson = faqs.map((faq) => faq.toJson()).toList();
    await _prefs.setString(_faqsKey, jsonEncode(faqsJson));
    await updateLastUpdated(_faqsKey);
  }
  
  /// Get cached FAQs
  List<CMSFAQ>? getCachedFAQs() {
    if (isCacheExpired(_faqsKey)) {
      return null;
    }
    
    final faqsJson = _prefs.getString(_faqsKey);
    if (faqsJson == null) {
      return null;
    }
    
    final List<dynamic> decodedFAQs = jsonDecode(faqsJson);
    return decodedFAQs.map((faq) => CMSFAQ.fromJson(faq)).toList();
  }
  
  /// Cache FAQ categories
  Future<void> cacheFAQCategories(List<String> categories) async {
    await _prefs.setStringList(_faqCategoriesKey, categories);
    await updateLastUpdated(_faqCategoriesKey);
  }
  
  /// Get cached FAQ categories
  List<String>? getCachedFAQCategories() {
    if (isCacheExpired(_faqCategoriesKey)) {
      return null;
    }
    
    return _prefs.getStringList(_faqCategoriesKey);
  }
  
  /// Clear all cache
  Future<void> clearCache() async {
    await _prefs.remove(_pagesKey);
    await _prefs.remove(_featuresKey);
    await _prefs.remove(_settingsKey);
    await _prefs.remove(_notificationsKey);
    await _prefs.remove(_faqsKey);
    await _prefs.remove(_faqCategoriesKey);
    
    // Remove all last updated keys
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_lastUpdatedKey)) {
        await _prefs.remove(key);
      }
    }
  }
  
  /// Clear cache for a specific key
  Future<void> clearCacheForKey(String key) async {
    await _prefs.remove(key);
    await _prefs.remove('${_lastUpdatedKey}_$key');
  }
}
