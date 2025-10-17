import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const _storage = FlutterSecureStorage();
  static const _themeKey = 'theme_mode';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final themeString = await _storage.read(key: _themeKey);
      if (themeString != null) {
        state = ThemeMode.values.firstWhere(
          (mode) => mode.name == themeString,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      // If there's an error, default to system theme
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      await _storage.write(key: _themeKey, value: mode.name);
      state = mode;
    } catch (e) {
      // Handle error silently or show a snackbar
    }
  }

  void toggleTheme() {
    switch (state) {
      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setThemeMode(ThemeMode.system);
        break;
      case ThemeMode.system:
        setThemeMode(ThemeMode.light);
        break;
    }
  }

  String get themeModeName {
    switch (state) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.system:
        return 'Système';
    }
  }
}
