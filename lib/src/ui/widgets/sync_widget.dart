import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/enhanced_sync_provider.dart';

class SyncWidget extends ConsumerWidget {
  const SyncWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(enhancedSyncStatusProvider);
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  syncStatus.isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: syncStatus.isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Synchronisation',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (syncStatus.isSyncing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Status text
            Text(
              syncStatus.isOnline 
                ? 'Connecté' 
                : 'Hors ligne',
              style: TextStyle(
                color: syncStatus.isOnline ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            if (syncStatus.lastSyncTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'Dernière sync: ${syncStatus.lastSyncText}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            
            if (syncStatus.hasError) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        syncStatus.error!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => ref.read(enhancedSyncStatusProvider.notifier).clearError(),
                    ),
                  ],
                ),
              ),
            ],
            
            if (syncStatus.isSuccess && syncStatus.syncedItems > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${syncStatus.syncedItems} éléments synchronisés',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Sync button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: syncStatus.isSyncing || !syncStatus.isOnline
                        ? null
                        : () => ref.read(enhancedSyncStatusProvider.notifier).performSync(),
                    icon: const Icon(Icons.sync),
                    label: Text(syncStatus.isSyncing ? 'Synchronisation...' : 'Synchroniser'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showSyncSettings(context, ref),
                  icon: const Icon(Icons.settings),
                  tooltip: 'Paramètres de synchronisation',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSyncSettings(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => SyncSettingsDialog(),
    );
  }
}

class SyncSettingsDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<SyncSettingsDialog> createState() => _SyncSettingsDialogState();
}

class _SyncSettingsDialogState extends ConsumerState<SyncSettingsDialog> {
  final _baseUrlController = TextEditingController();
  final _authTokenController = TextEditingController();
  bool _autoSyncEnabled = false;
  int _syncInterval = 15;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final syncStatus = ref.read(enhancedSyncStatusProvider);
    setState(() {
      _autoSyncEnabled = syncStatus.autoSyncEnabled;
      _syncInterval = syncStatus.syncInterval;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Paramètres de synchronisation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Auto sync toggle
          SwitchListTile(
            title: const Text('Synchronisation automatique'),
            subtitle: const Text('Synchroniser automatiquement les données'),
            value: _autoSyncEnabled,
            onChanged: (value) {
              setState(() {
                _autoSyncEnabled = value;
              });
            },
          ),
          
          // Sync interval
          if (_autoSyncEnabled) ...[
            const SizedBox(height: 8),
            Text('Intervalle de synchronisation (minutes)'),
            Slider(
              value: _syncInterval.toDouble(),
              min: 5,
              max: 120,
              divisions: 23,
              label: '$_syncInterval min',
              onChanged: (value) {
                setState(() {
                  _syncInterval = value.round();
                });
              },
            ),
          ],
          
          const Divider(),
          
          // API Configuration
          TextField(
            controller: _baseUrlController,
            decoration: const InputDecoration(
              labelText: 'URL de l\'API',
              hintText: 'https://api.onesave.cnf.ci',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 8),
          
          TextField(
            controller: _authTokenController,
            decoration: const InputDecoration(
              labelText: 'Token d\'authentification',
              hintText: 'Votre token d\'API',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _saveSettings,
          child: const Text('Sauvegarder'),
        ),
      ],
    );
  }

  Future<void> _saveSettings() async {
    final notifier = ref.read(enhancedSyncStatusProvider.notifier);
    
    // Save auto sync settings
    await notifier.setAutoSyncEnabled(_autoSyncEnabled);
    await notifier.setSyncInterval(_syncInterval);
    
    // Save API configuration if provided
    if (_baseUrlController.text.isNotEmpty && _authTokenController.text.isNotEmpty) {
      await notifier.configureApi(
        baseUrl: _baseUrlController.text,
        authToken: _authTokenController.text,
      );
    }
    
    Navigator.of(context).pop();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paramètres sauvegardés'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _authTokenController.dispose();
    super.dispose();
  }
}
