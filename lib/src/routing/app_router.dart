import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/projects_screen.dart';
import '../ui/screens/events_screen.dart';
import '../ui/screens/stats_screen.dart';
import '../ui/screens/settings_screen.dart';

final appRouterProvider = Provider<AppRouter>((ref) => AppRouter());

class AppRouter {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/projects':
        return MaterialPageRoute(builder: (_) => const ProjectsScreen());
      case '/events':
        return MaterialPageRoute(builder: (_) => const EventsScreen());
      case '/stats':
        return MaterialPageRoute(builder: (_) => const StatsScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
