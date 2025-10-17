import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/partner.dart';
import '../../providers/app_providers.dart';

class PartnersScreen extends ConsumerStatefulWidget {
  const PartnersScreen({super.key});

  @override
  ConsumerState<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends ConsumerState<PartnersScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref.read(partnerRepositoryProvider).getAll(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? <Partner>[];
        return Scaffold(
          appBar: AppBar(title: const Text('Partenaires')),
          body: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (_, i) {
              final p = items[i];
              return ListTile(
                title: Text(p.name),
                subtitle: Text(p.type ?? ''),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: items.length,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final created = await showDialog<Partner>(context: context, builder: (_) => const _PartnerDialog());
              if (created != null) {
                await ref.read(partnerRepositoryProvider).create(created);
                if (mounted) setState(() {});
              }
            },
            icon: const Icon(Icons.add_business),
            label: const Text('Ajouter'),
          ),
        );
      },
    );
  }
}

class _PartnerDialog extends StatefulWidget {
  const _PartnerDialog();
  @override
  State<_PartnerDialog> createState() => _PartnerDialogState();
}

class _PartnerDialogState extends State<_PartnerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  String _type = 'GAF';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau partenaire'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'GAF', child: Text('GAF')),
                  DropdownMenuItem(value: 'Ambassade', child: Text('Ambassade')),
                  DropdownMenuItem(value: 'ONG', child: Text('ONG')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'GAF'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, Partner(
              name: _name.text.trim(), 
              type: _type,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
