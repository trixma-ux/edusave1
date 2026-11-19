import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/app_providers.dart';
import '../widgets/offline_indicator.dart';
import '../widgets/sync_widget.dart';
import '../../theme/app_theme.dart';
import 'projects_screen.dart';
import 'events_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import 'programs_screen.dart';
import 'beneficiaries_screen.dart';
import 'partners_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _pages = [ProgramsScreen(), ProjectsScreen(), EventsScreen(), StatsScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(currentTabProvider);
    return Scaffold(
      backgroundColor: OneSaveColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: OneSaveColors.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.save_alt,
                color: OneSaveColors.onPrimary,
                size: 24,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(width: 12),
            const Text('OneSave')
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideX(begin: -0.3, end: 0, duration: 600.ms, delay: 200.ms),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: OneSaveColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.more_vert,
                color: OneSaveColors.primary,
              ),
            ),
            onSelected: (k) {
              switch (k) {
                case 'beneficiaries':
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const BeneficiariesScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: animation.drive(
                            Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                                .chain(CurveTween(curve: Curves.easeInOut)),
                          ),
                          child: child,
                        );
                      },
                    ),
                  );
                  break;
                case 'partners':
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const PartnersScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: animation.drive(
                            Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                                .chain(CurveTween(curve: Curves.easeInOut)),
                          ),
                          child: child,
                        );
                      },
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (c) => [
              PopupMenuItem(
                value: 'beneficiaries',
                child: Row(
                  children: [
                    Icon(Icons.people, color: OneSaveColors.primary),
                    const SizedBox(width: 12),
                    const Text('Bénéficiaires'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'partners',
                child: Row(
                  children: [
                    Icon(Icons.handshake, color: OneSaveColors.primary),
                    const SizedBox(width: 12),
                    const Text('Partenaires'),
                  ],
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 600.ms,
                delay: 400.ms,
              ),
        ],
      ),
      body: Column(
        children: [
          const OfflineIndicator(),
          const SyncWidget(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: animation.drive(
                    Tween(begin: const Offset(0.1, 0.0), end: Offset.zero)
                        .chain(CurveTween(curve: Curves.easeInOut)),
                  ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Container(
                key: ValueKey(tab),
                child: _pages[tab],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: OneSaveColors.surface,
          boxShadow: [
            BoxShadow(
              color: OneSaveColors.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => ref.read(currentTabProvider.notifier).state = i,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.collections_bookmark_outlined),
              selectedIcon: Icon(Icons.collections_bookmark),
              label: 'Programmes',
            ),
            NavigationDestination(
              icon: Icon(Icons.work_outline),
              selectedIcon: Icon(Icons.work),
              label: 'Projets',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_outlined),
              selectedIcon: Icon(Icons.event),
              label: 'Rencontres',
            ),
            NavigationDestination(
              icon: Icon(Icons.query_stats_outlined),
              selectedIcon: Icon(Icons.query_stats),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Paramètres',
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms, delay: 600.ms)
          .slideY(begin: 1.0, end: 0.0, duration: 600.ms, delay: 600.ms),
    );
  }
}
