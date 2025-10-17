import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/localization_service.dart';

final localizationServiceProvider = Provider<LocalizationService>((ref) {
  return LocalizationService();
});

final currentLocaleProvider = StateNotifierProvider<CurrentLocaleNotifier, Locale>((ref) {
  return CurrentLocaleNotifier(ref.read(localizationServiceProvider));
});

class CurrentLocaleNotifier extends StateNotifier<Locale> {
  final LocalizationService _localizationService;

  CurrentLocaleNotifier(this._localizationService) : super(LocalizationService.defaultLocale) {
    _loadCurrentLocale();
  }

  Future<void> _loadCurrentLocale() async {
    final locale = await _localizationService.getCurrentLocale();
    state = locale;
  }

  Future<void> setLocale(Locale locale) async {
    await _localizationService.setLocale(locale);
    state = locale;
  }

  Future<void> toggleLocale() async {
    final nextLocale = _localizationService.getNextLocale(state);
    await setLocale(nextLocale);
  }

  String getLocaleName(Locale locale) {
    return _localizationService.getLocaleName(locale);
  }

  String getLocaleFlag(Locale locale) {
    return _localizationService.getLocaleFlag(locale);
  }
}
