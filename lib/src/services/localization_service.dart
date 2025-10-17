import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final localizationServiceProvider = Provider<LocalizationService>((ref) {
  return LocalizationService();
});

class LocalizationService {
  static const _storage = FlutterSecureStorage();
  static const String _localeKey = 'app_locale';

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('fr', ''), // French
    Locale('en', ''), // English
  ];

  // Default locale
  static const Locale defaultLocale = Locale('fr', '');

  // Get current locale
  Future<Locale> getCurrentLocale() async {
    try {
      final localeString = await _storage.read(key: _localeKey);
      if (localeString != null) {
        final parts = localeString.split('_');
        if (parts.length == 2) {
          return Locale(parts[0], parts[1]);
        } else {
          return Locale(parts[0]);
        }
      }
    } catch (e) {
      print('Error reading locale: $e');
    }
    return defaultLocale;
  }

  // Set locale
  Future<void> setLocale(Locale locale) async {
    try {
      final localeString = '${locale.languageCode}_${locale.countryCode ?? ''}';
      await _storage.write(key: _localeKey, value: localeString);
    } catch (e) {
      print('Error saving locale: $e');
    }
  }

  // Get locale name
  String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      default:
        return 'Français';
    }
  }

  // Get locale flag emoji
  String getLocaleFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return '🇫🇷';
      case 'en':
        return '🇺🇸';
      default:
        return '🇫🇷';
    }
  }

  // Check if locale is supported
  bool isLocaleSupported(Locale locale) {
    return supportedLocales.any((supportedLocale) => 
      supportedLocale.languageCode == locale.languageCode);
  }

  // Get next locale in cycle
  Locale getNextLocale(Locale currentLocale) {
    final currentIndex = supportedLocales.indexWhere(
      (locale) => locale.languageCode == currentLocale.languageCode,
    );
    
    if (currentIndex == -1) {
      return supportedLocales.first;
    }
    
    final nextIndex = (currentIndex + 1) % supportedLocales.length;
    return supportedLocales[nextIndex];
  }
}

// Localization delegates
final localizationDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

// Locale resolution callback
Locale? localeResolutionCallback(
  List<Locale>? locales,
  Iterable<Locale> supportedLocales,
) {
  if (locales == null || locales.isEmpty) {
    return LocalizationService.defaultLocale;
  }

  // Check if any of the device locales are supported
  for (final locale in locales) {
    if (LocalizationService.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    )) {
      return locale;
    }
  }

  // Return default locale if none are supported
  return LocalizationService.defaultLocale;
}
