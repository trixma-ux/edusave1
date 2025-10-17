import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/beneficiary.dart';
import '../../providers/app_providers.dart';

class BeneficiariesScreen extends ConsumerStatefulWidget {
  const BeneficiariesScreen({super.key});

  @override
  ConsumerState<BeneficiariesScreen> createState() => _BeneficiariesScreenState();
}

class _BeneficiariesScreenState extends ConsumerState<BeneficiariesScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref.read(beneficiaryRepositoryProvider).getAll(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? <Beneficiary>[];
        return Scaffold(
          appBar: AppBar(title: const Text('Bénéficiaires')),
          body: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (_, i) {
              final b = items[i];
              return ListTile(
                title: Text(b.fullName),
                subtitle: Text('${b.segment ?? ''} ${b.gender ?? ''}'),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: items.length,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final created = await showDialog<Beneficiary>(context: context, builder: (_) => const _BeneficiaryDialog());
              if (created != null) {
                await ref.read(beneficiaryRepositoryProvider).create(created);
                if (mounted) setState(() {});
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter'),
          ),
        );
      },
    );
  }
}

class _BeneficiaryDialog extends StatefulWidget {
  const _BeneficiaryDialog();
  @override
  State<_BeneficiaryDialog> createState() => _BeneficiaryDialogState();
}

class _BeneficiaryDialogState extends State<_BeneficiaryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  String _segment = 'Jeune';
  String _gender = 'F';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau bénéficiaire'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nom complet'),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _segment,
                decoration: const InputDecoration(labelText: 'Segment'),
                items: const [
                  DropdownMenuItem(value: 'Jeune', child: Text('Jeune')),
                  DropdownMenuItem(value: 'Femme', child: Text('Femme')),
                  DropdownMenuItem(value: 'Cinéaste', child: Text('Cinéaste')),
                ],
                onChanged: (v) => setState(() => _segment = v ?? 'Jeune'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Genre'),
                items: const [
                  DropdownMenuItem(value: 'F', child: Text('F')),
                  DropdownMenuItem(value: 'M', child: Text('M')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'F'),
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
            Navigator.pop(context, Beneficiary(fullName: _name.text.trim(), gender: _gender, segment: _segment));
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
