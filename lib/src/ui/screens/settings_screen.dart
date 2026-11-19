import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/localization_provider.dart';
import '../../providers/user_provider.dart';
import 'api_configuration_screen.dart';
import 'user_management_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final syncStatus = ref.watch(syncStatusProvider);
    final syncNotifier = ref.read(syncStatusProvider.notifier);
    // Notification settings removed for web compatibility
    final currentLocale = ref.watch(currentLocaleProvider);
    final localizationNotifier = ref.read(currentLocaleProvider.notifier);
    final currentUser = ref.watch(currentUserProvider);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Theme Settings
        Card(
          child: ListTile(
            leading: Icon(
              themeMode == ThemeMode.dark 
                ? Icons.dark_mode 
                : themeMode == ThemeMode.light 
                  ? Icons.light_mode 
                  : Icons.brightness_auto,
            ),
            title: const Text('Thème'),
            subtitle: Text(themeNotifier.themeModeName),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => themeNotifier.toggleTheme(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Sync Settings
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  syncStatus.isOnline 
                    ? Icons.cloud_done 
                    : Icons.cloud_off,
                  color: syncStatus.isOnline 
                    ? Colors.green 
                    : Colors.red,
                ),
                title: const Text('Synchronisation'),
                subtitle: Text(
                  syncStatus.isOnline 
                    ? 'En ligne' 
                    : 'Hors ligne',
                ),
                trailing: syncStatus.isOnline 
                  ? IconButton(
                      icon: syncStatus.isSyncing 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                      onPressed: syncStatus.isSyncing 
                        ? null 
                        : () => syncNotifier.performSync(),
                    )
                  : null,
              ),
              if (syncStatus.lastSyncTime != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Dernière sync: ${_formatDateTime(syncStatus.lastSyncTime!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              if (syncStatus.hasError)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Erreur: ${syncStatus.error}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Notification Settings removed for web compatibility
        
        // Security Settings
        Card(
          child: const ListTile(
            leading: Icon(Icons.security),
            title: Text('Sécurité et confidentialité'),
            subtitle: Text('Données chiffrées localement'),
          ),
        ),
        const SizedBox(height: 8),
        
        // Language Settings
        Card(
          child: ListTile(
            leading: Icon(
              Icons.translate,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Langue'),
            subtitle: Text(localizationNotifier.getLocaleName(currentLocale)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localizationNotifier.getLocaleFlag(currentLocale),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () => localizationNotifier.toggleLocale(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // User Management (Admin only)
        if (currentUser?.hasPermission('manage_users') == true) ...[
          Card(
            child: ListTile(
              leading: Icon(
                Icons.people,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Gestion des utilisateurs'),
              subtitle: const Text('Gérer les utilisateurs et les rôles'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UserManagementScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // API Configuration
        Card(
          child: ListTile(
            leading: Icon(
              Icons.api,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Configuration API'),
            subtitle: const Text('Intégration avec des systèmes externes'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ApiConfigurationScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        
        // About
        Card(
          child: const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('À propos'),
            subtitle: Text('Edusave © Côte d\'Ivoire'),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
