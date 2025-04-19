# CMS Localization

This module provides localization support for the CMS integration, allowing for multi-language content and UI.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Setup](#setup)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Customization](#customization)

## Overview

The CMS Localization module allows for translating content and UI elements into multiple languages. It uses the Strapi CMS i18n plugin to fetch translations and provides a Flutter-friendly way to use them in the app.

## Features

- **Multiple Languages**: Support for multiple languages
- **Dynamic Content**: Translate dynamic content from the CMS
- **UI Translation**: Translate UI elements
- **Language Switching**: Switch between languages at runtime
- **Caching**: Cache translations for offline use
- **Fallback**: Fallback to default language if translation is not available

## Setup

### 1. Strapi CMS Setup

1. Install the i18n plugin for Strapi:
   ```bash
   cd my-project
   npm install @strapi/plugin-i18n
   ```

2. Configure the i18n plugin in Strapi:
   - Go to Settings > Internationalization
   - Add the languages you want to support
   - Set the default language

3. Create translations for your content:
   - Create content in the default language
   - Use the "Localize" button to create translations for other languages
   - Fill in the translated content

### 2. Flutter App Setup

1. Add the required dependencies to `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter_localizations:
       sdk: flutter
     shared_preferences: ^2.2.0
     provider: ^6.0.5
   ```

2. Initialize the localization provider in your app:
   ```dart
   final localizationProvider = CMSLocalizationProvider();
   await localizationProvider.initialize();
   ```

3. Add the localization provider to your widget tree:
   ```dart
   MultiProvider(
     providers: [
       ChangeNotifierProvider(create: (_) => CMSLocalizationProvider()),
       // Other providers...
     ],
     child: MyApp(),
   )
   ```

4. Add the localization delegate to your MaterialApp:
   ```dart
   MaterialApp(
     localizationsDelegates: [
       GlobalMaterialLocalizations.delegate,
       GlobalWidgetsLocalizations.delegate,
       GlobalCupertinoLocalizations.delegate,
       CMSLocalizationsDelegate(provider: localizationProvider),
     ],
     supportedLocales: localizationProvider.availableLocales,
     // ...
   )
   ```

## Usage

### Translating Text

```dart
// Using the CMSLocalizedText widget
CMSLocalizedText(
  'welcome_message',
  style: Theme.of(context).textTheme.headline4,
);

// Using the CMSLocalizations class
final localizations = CMSLocalizations.of(context);
Text(
  await localizations.translate('welcome_message'),
  style: Theme.of(context).textTheme.headline4,
);

// Using the synchronous version
Text(
  localizations.translateSync('welcome_message'),
  style: Theme.of(context).textTheme.headline4,
);
```

### Translating with Arguments

```dart
// Using the CMSLocalizedText widget
CMSLocalizedText(
  'hello_name',
  args: {'name': 'John'},
  style: Theme.of(context).textTheme.headline4,
);

// Using the CMSLocalizations class
final localizations = CMSLocalizations.of(context);
Text(
  await localizations.translate('hello_name', args: {'name': 'John'}),
  style: Theme.of(context).textTheme.headline4,
);
```

### Switching Languages

```dart
// Using the CMSLanguageSelector widget
CMSLanguageSelector();

// Using the CMSLocalizationProvider
final provider = Provider.of<CMSLocalizationProvider>(context, listen: false);
provider.setLocale(const Locale('fr', 'FR'));
```

## API Reference

### CMSLocalizationService

```dart
// Initialize the localization service
Future<void> initialize();

// Get the current locale
Locale? getCurrentLocale();

// Set the current locale
Future<void> setCurrentLocale(Locale locale);

// Get all available locales
Future<List<Locale>> getLocales({bool forceRefresh = false});

// Get translations for a locale
Future<Map<String, String>> getTranslations(Locale locale, {bool forceRefresh = false});

// Translate a key
Future<String> translate(String key, {Map<String, String>? args, Locale? locale});

// Clear all cache
Future<void> clearCache();
```

### CMSLocalizationProvider

```dart
// Initialize the provider
Future<void> initialize();

// Load available locales
Future<void> loadLocales({bool forceRefresh = false});

// Load translations for a locale
Future<void> loadTranslations(Locale locale, {bool forceRefresh = false});

// Set the current locale
Future<void> setLocale(Locale locale);

// Translate a key
Future<String> translate(String key, {Map<String, String>? args});

// Clear cache
Future<void> clearCache();
```

### CMSLocalizations

```dart
// Get the current instance from the context
static CMSLocalizations of(BuildContext context);

// Translate a key
Future<String> translate(String key, {Map<String, String>? args});

// Translate a key synchronously
String translateSync(String key, {Map<String, String>? args});
```

## Customization

### Adding New Languages

1. Add the language in Strapi:
   - Go to Settings > Internationalization
   - Add the new language

2. Create translations for your content:
   - Create content in the default language
   - Use the "Localize" button to create translations for the new language
   - Fill in the translated content

3. The app will automatically detect the new language and add it to the available locales.

### Customizing the Language Selector

You can create a custom language selector by using the CMSLocalizationProvider:

```dart
Consumer<CMSLocalizationProvider>(
  builder: (context, provider, child) {
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
```

### Adding Fallback Translations

You can add fallback translations by modifying the `translate` method in the CMSLocalizationService:

```dart
Future<String> translate(String key, {Map<String, String>? args, Locale? locale}) async {
  final currentLocale = locale ?? getCurrentLocale() ?? const Locale('en', 'US');
  final translations = await getTranslations(currentLocale);
  
  if (!translations.containsKey(key)) {
    // Try to get the translation from the default locale
    if (currentLocale.languageCode != 'en') {
      final defaultTranslations = await getTranslations(const Locale('en', 'US'));
      if (defaultTranslations.containsKey(key)) {
        String translation = defaultTranslations[key]!;
        
        // Replace arguments
        if (args != null) {
          args.forEach((argKey, argValue) {
            translation = translation.replaceAll('{$argKey}', argValue);
          });
        }
        
        return translation;
      }
    }
    
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
