import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: const [
        ListTile(
          leading: Icon(Icons.security),
          title: Text('Sécurité et confidentialité'),
          subtitle: Text('Données chiffrées localement'),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.translate),
          title: Text('Langue'),
          subtitle: Text('Français'),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('À propos'),
          subtitle: Text('EduSave © CNF Côte d’Ivoire'),
        ),
      ],
    );
  }
}
