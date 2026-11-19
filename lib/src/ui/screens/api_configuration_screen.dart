import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/api_provider.dart';

class ApiConfigurationScreen extends ConsumerStatefulWidget {
  const ApiConfigurationScreen({super.key});

  @override
  ConsumerState<ApiConfigurationScreen> createState() => _ApiConfigurationScreenState();
}

class _ApiConfigurationScreenState extends ConsumerState<ApiConfigurationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _baseUrlController = TextEditingController();
  final _authTokenController = TextEditingController();
  final _apiKeyController = TextEditingController();
  
  bool _isLoading = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _authTokenController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadConfiguration() async {
    final config = await ref.read(apiServiceProvider).getConfiguration();
    setState(() {
      _baseUrlController.text = config.baseUrl;
      _authTokenController.text = config.authToken ?? '';
      _apiKeyController.text = config.apiKey ?? '';
    });
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(apiServiceProvider).configureApi(
        baseUrl: _baseUrlController.text.trim(),
        authToken: _authTokenController.text.trim().isNotEmpty 
          ? _authTokenController.text.trim() 
          : null,
        apiKey: _apiKeyController.text.trim().isNotEmpty 
          ? _apiKeyController.text.trim() 
          : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration sauvegardée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testConnection() async {
    if (_baseUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir une URL de base'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isTesting = true);

    try {
      // First save the configuration
      await ref.read(apiServiceProvider).configureApi(
        baseUrl: _baseUrlController.text.trim(),
        authToken: _authTokenController.text.trim().isNotEmpty 
          ? _authTokenController.text.trim() 
          : null,
        apiKey: _apiKeyController.text.trim().isNotEmpty 
          ? _apiKeyController.text.trim() 
          : null,
      );

      // Then test the connection
      final result = await ref.read(apiServiceProvider).testConnection();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du test: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _clearConfiguration() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer la configuration API ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(apiServiceProvider).clearConfiguration();
      _loadConfiguration();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration supprimée'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration API'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.api,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Configuration API externe',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Connectez Edusave à des systèmes externes',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Configuration Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paramètres de connexion',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Base URL
                      TextFormField(
                        controller: _baseUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL de base',
                          hintText: 'https://api.example.com',
                          prefixIcon: Icon(Icons.link),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'L\'URL de base est requise';
                          }
                          final uri = Uri.tryParse(value.trim());
                          if (uri == null || !uri.hasAbsolutePath) {
                            return 'Veuillez saisir une URL valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Auth Token
                      TextFormField(
                        controller: _authTokenController,
                        decoration: const InputDecoration(
                          labelText: 'Token d\'authentification (optionnel)',
                          hintText: 'Bearer token ou JWT',
                          prefixIcon: Icon(Icons.key),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      
                      // API Key
                      TextFormField(
                        controller: _apiKeyController,
                        decoration: const InputDecoration(
                          labelText: 'Clé API (optionnelle)',
                          hintText: 'Clé d\'API pour l\'authentification',
                          prefixIcon: Icon(Icons.vpn_key),
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveConfiguration,
                      icon: _isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                      label: Text(_isLoading ? 'Sauvegarde...' : 'Sauvegarder'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isTesting ? null : _testConnection,
                      icon: _isTesting 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi_protected_setup),
                      label: Text(_isTesting ? 'Test...' : 'Tester'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Clear Configuration Button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _clearConfiguration,
                  icon: const Icon(Icons.clear),
                  label: const Text('Supprimer la configuration'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // API Features
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fonctionnalités disponibles',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildFeatureItem(
                        context,
                        Icons.download,
                        'Import de données',
                        'Importer des données depuis des systèmes externes',
                      ),
                      _buildFeatureItem(
                        context,
                        Icons.upload,
                        'Export de données',
                        'Exporter des données vers des systèmes externes',
                      ),
                      _buildFeatureItem(
                        context,
                        Icons.sync,
                        'Synchronisation',
                        'Synchroniser les données avec des systèmes externes',
                      ),
                      _buildFeatureItem(
                        context,
                        Icons.file_upload,
                        'Upload de fichiers',
                        'Télécharger des fichiers vers des systèmes externes',
                      ),
                      _buildFeatureItem(
                        context,
                        Icons.file_download,
                        'Download de fichiers',
                        'Télécharger des fichiers depuis des systèmes externes',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aide - Configuration API'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'URL de base',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('L\'URL de base de votre API externe (ex: https://api.example.com)'),
              SizedBox(height: 16),
              
              Text(
                'Token d\'authentification',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Token Bearer ou JWT pour l\'authentification (optionnel)'),
              SizedBox(height: 16),
              
              Text(
                'Clé API',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Clé d\'API pour l\'authentification (optionnelle)'),
              SizedBox(height: 16),
              
              Text(
                'Test de connexion',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Teste la connectivité avec l\'API configurée'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
