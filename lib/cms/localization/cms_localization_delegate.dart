import 'package:flutter/material.dart';
import '../providers/cms_localization_provider.dart';
import 'cms_localizations.dart';

/// Delegate for CMS localizations
class CMSLocalizationsDelegate extends LocalizationsDelegate<CMSLocalizations> {
  /// Localization provider
  final CMSLocalizationProvider provider;
  
  /// Create a new CMS localizations delegate
  const CMSLocalizationsDelegate({required this.provider});
  
  @override
  bool isSupported(Locale locale) {
    return provider.availableLocales.any((supportedLocale) =>
        supportedLocale.languageCode == locale.languageCode);
  }
  
  @override
  Future<CMSLocalizations> load(Locale locale) async {
    // If the locale is not the current locale, load translations for it
    if (provider.currentLocale?.languageCode != locale.languageCode) {
      await provider.setLocale(locale);
    }
    
    return CMSLocalizations(provider);
  }
  
  @override
  bool shouldReload(CMSLocalizationsDelegate old) {
    return old.provider != provider;
  }
}
