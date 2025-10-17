import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
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
      appBar: AppBar(
        title: const Text('EduSave'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (k) {
              switch (k) {
                case 'beneficiaries':
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BeneficiariesScreen()));
                  break;
                case 'partners':
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PartnersScreen()));
                  break;
              }
            },
            itemBuilder: (c) => const [
              PopupMenuItem(value: 'beneficiaries', child: Text('Bénéficiaires')),
              PopupMenuItem(value: 'partners', child: Text('Partenaires')),
            ],
          )
        ],
      ),
      body: _pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => ref.read(currentTabProvider.notifier).state = i,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.collections_bookmark), label: 'Programmes'),
          NavigationDestination(icon: Icon(Icons.work_outline), label: 'Projets'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Rencontres'),
          NavigationDestination(icon: Icon(Icons.query_stats), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Paramètres'),
        ],
      ),
    );
  }
}
