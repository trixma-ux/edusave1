import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/project.dart';
import '../../providers/app_providers.dart';
import 'project_details_screen.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref.read(projectRepositoryProvider).getAll(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? <Project>[];
        return Scaffold(
          body: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (_, i) {
              final p = items[i];
              return ListTile(
                title: Text(p.title),
                subtitle: Text('${p.program} • ${p.status}'),
                onTap: p.id == null ? null : () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProjectDetailsScreen(project: p)),
                ),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: items.length,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final created = await showDialog<Project>(context: context, builder: (_) => const _ProjectDialog());
              if (created != null) {
                await ref.read(projectRepositoryProvider).create(created);
                if (mounted) setState(() {});
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Nouveau projet'),
          ),
        );
      },
    );
  }
}

class _ProjectDialog extends StatefulWidget {
  const _ProjectDialog();
  @override
  State<_ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<_ProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  String _program = 'CLAC';
  String _status = 'PLANIFIE';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer un projet'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _program,
                decoration: const InputDecoration(labelText: 'Programme'),
                items: const [
                  DropdownMenuItem(value: 'CLAC', child: Text('CLAC')),
                  DropdownMenuItem(value: 'IFADEM', child: Text('IFADEM')),
                  DropdownMenuItem(value: 'ELAN', child: Text('ELAN')),
                  DropdownMenuItem(value: 'AUTRE', child: Text('Autre')),
                ],
                onChanged: (v) => setState(() => _program = v ?? 'CLAC'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Statut'),
                items: const [
                  DropdownMenuItem(value: 'PLANIFIE', child: Text('Planifié')),
                  DropdownMenuItem(value: 'EN_COURS', child: Text('En cours')),
                  DropdownMenuItem(value: 'TERMINE', child: Text('Terminé')),
                  DropdownMenuItem(value: 'CLOTURE', child: Text('Clôturé')),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'PLANIFIE'),
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
            Navigator.pop(
              context,
              Project(
                title: _title.text.trim(), 
                program: _program, 
                status: _status,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
