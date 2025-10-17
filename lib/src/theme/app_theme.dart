import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme Provider
final appThemeProvider = Provider<ThemeData>((ref) {
  final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
  return isDark ? _darkTheme : _lightTheme;
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);
  
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

// OneSave Brand Colors
class OneSaveColors {
  // Primary Colors
  static const Color primary = Color(0xFF0175C2);
  static const Color primaryVariant = Color(0xFF0056B3);
  static const Color onPrimary = Colors.white;
  
  // Secondary Colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);
  static const Color onSecondary = Colors.black;
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color onBackground = Color(0xFF1C1B1F);
  
  // Surface Colors
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF1C1B1F);
  
  // Error Colors
  static const Color error = Color(0xFFB00020);
  static const Color onError = Colors.white;
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF0175C2),
    Color(0xFF0056B3),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFF03DAC6),
    Color(0xFF018786),
  ];
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // Surface Variants
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // Glass Effects
  static const List<Color> glassGradient = [
    Color(0x40FFFFFF),
    Color(0x20FFFFFF),
  ];
  static const Color glassBorder = Color(0x30FFFFFF);
  
  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderFocused = Color(0xFF0175C2);
  
  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0A000000);
}

// Light Theme
final ThemeData _lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: OneSaveColors.primary,
    onPrimary: OneSaveColors.onPrimary,
    secondary: OneSaveColors.secondary,
    onSecondary: OneSaveColors.onSecondary,
    surface: OneSaveColors.surface,
    onSurface: OneSaveColors.onSurface,
    background: OneSaveColors.background,
    onBackground: OneSaveColors.onBackground,
    error: OneSaveColors.error,
    onError: OneSaveColors.onError,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: OneSaveColors.primary,
    foregroundColor: OneSaveColors.onPrimary,
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: OneSaveColors.surface,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: OneSaveColors.primary,
      foregroundColor: OneSaveColors.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: OneSaveColors.primary,
      side: const BorderSide(color: OneSaveColors.primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: OneSaveColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: OneSaveColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: OneSaveColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: OneSaveColors.borderFocused, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: OneSaveColors.error),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: OneSaveColors.primary.withValues(alpha: 0.1),
    labelStyle: const TextStyle(color: OneSaveColors.primary),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: OneSaveColors.border,
    thickness: 1,
  ),
  listTileTheme: const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: OneSaveColors.surface,
    selectedItemColor: OneSaveColors.primary,
    unselectedItemColor: OneSaveColors.textSecondary,
    type: BottomNavigationBarType.fixed,
  ),
);

// Dark Theme
final ThemeData _darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: OneSaveColors.primary,
    onPrimary: OneSaveColors.onPrimary,
    secondary: OneSaveColors.secondary,
    onSecondary: OneSaveColors.onSecondary,
    surface: Color(0xFF1E1E1E),
    onSurface: Colors.white,
    background: Color(0xFF121212),
    onBackground: Colors.white,
    error: OneSaveColors.error,
    onError: OneSaveColors.onError,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: const Color(0xFF1E1E1E),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: OneSaveColors.primary,
      foregroundColor: OneSaveColors.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: OneSaveColors.primary,
      side: const BorderSide(color: OneSaveColors.primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: OneSaveColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF424242)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF424242)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: OneSaveColors.borderFocused, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: OneSaveColors.error),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: OneSaveColors.primary.withValues(alpha: 0.2),
    labelStyle: const TextStyle(color: OneSaveColors.primary),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF424242),
    thickness: 1,
  ),
  listTileTheme: const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    selectedItemColor: OneSaveColors.primary,
    unselectedItemColor: Color(0xFF757575),
    type: BottomNavigationBarType.fixed,
  ),
);