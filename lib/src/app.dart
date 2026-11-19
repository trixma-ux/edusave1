import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/localization_provider.dart';
import 'services/localization_service.dart';

class OneSaveApp extends ConsumerStatefulWidget {
  const OneSaveApp({super.key});

  @override
  ConsumerState<OneSaveApp> createState() => _OneSaveAppState();
}

class _OneSaveAppState extends ConsumerState<OneSaveApp> {
  @override
  void initState() {
    super.initState();
    // Initialize app when it starts
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final theme = ref.watch(appThemeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(currentLocaleProvider);

    return MaterialApp(
      title: 'Edusave',
      debugShowCheckedModeBanner: false,
      theme: theme,
      themeMode: themeMode,
      onGenerateRoute: router.onGenerateRoute,
      initialRoute: '/login',
      locale: currentLocale,
      supportedLocales: LocalizationService.supportedLocales,
      localizationsDelegates: localizationDelegates,
      localeResolutionCallback: (Locale? locale, Iterable<Locale> supportedLocales) {
        if (locale == null) return supportedLocales.first;
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) {
            return supported;
          }
        }
        return supportedLocales.first;
      },
    );
  }
}
