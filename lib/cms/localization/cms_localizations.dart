import 'package:flutter/material.dart';
import '../providers/cms_localization_provider.dart';

/// CMS localizations
class CMSLocalizations {
  /// Localization provider
  final CMSLocalizationProvider provider;
  
  /// Create a new CMS localizations
  CMSLocalizations(this.provider);
  
  /// Get the current instance from the context
  static CMSLocalizations of(BuildContext context) {
    return Localizations.of<CMSLocalizations>(context, CMSLocalizations)!;
  }
  
  /// Translate a key
  Future<String> translate(String key, {Map<String, String>? args}) {
    return provider.translate(key, args: args);
  }
  
  /// Translate a key synchronously
  String translateSync(String key, {Map<String, String>? args}) {
    if (!provider.translations.containsKey(key)) {
      return key;
    }
    
    String translation = provider.translations[key]!;
    
    // Replace arguments
    if (args != null) {
      args.forEach((argKey, argValue) {
        translation = translation.replaceAll('{$argKey}', argValue);
      });
    }
    
    return translation;
  }
}
