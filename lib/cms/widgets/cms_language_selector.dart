import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cms_localization_provider.dart';

/// Widget for selecting a language
class CMSLanguageSelector extends StatelessWidget {
  /// Create a new CMS language selector
  const CMSLanguageSelector({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<CMSLocalizationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (provider.errorMessage != null) {
          return Center(
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        if (provider.availableLocales.isEmpty) {
          return const Center(
            child: Text('No languages available'),
          );
        }
        
        return DropdownButton<Locale>(
          value: provider.currentLocale,
          onChanged: (Locale? newLocale) {
            if (newLocale != null) {
              provider.setLocale(newLocale);
            }
          },
          items: provider.availableLocales.map((locale) {
            return DropdownMenuItem<Locale>(
              value: locale,
              child: Text(_getLanguageName(locale)),
            );
          }).toList(),
        );
      },
    );
  }
  
  /// Get the language name for a locale
  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      case 'ru':
        return 'Русский';
      case 'zh':
        return '中文';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'ar':
        return 'العربية';
      case 'hi':
        return 'हिन्दी';
      default:
        return locale.languageCode;
    }
  }
}
