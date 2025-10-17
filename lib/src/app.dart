import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

class EduSaveApp extends ConsumerWidget {
  const EduSaveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final theme = ref.watch(appThemeProvider);

    return MaterialApp(
      title: 'EduSave',
      debugShowCheckedModeBanner: false,
      theme: theme,
      onGenerateRoute: router.onGenerateRoute,
      initialRoute: '/login',
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
    );
  }
}
