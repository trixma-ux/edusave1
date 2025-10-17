import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/project.dart';
import '../../data/models/beneficiary.dart';
import '../../data/models/partner.dart';
import '../../providers/app_providers.dart';
import '../../services/report_export_service.dart';

class ProjectDetailsScreen extends ConsumerWidget {
  final Project project;
  const ProjectDetailsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        actions: [
          IconButton(
            tooltip: 'Exporter PDF',
            onPressed: () => ref.read(reportExportServiceProvider).exportProjectPdf(project, ref),
            icon: const Icon(Icons.picture_as_pdf),
          ),
          IconButton(
            tooltip: 'Exporter Excel',
            onPressed: () => ref.read(reportExportServiceProvider).exportProjectExcel(project, ref),
            icon: const Icon(Icons.grid_on),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${project.program} • ${project.status}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (project.description != null) Text(project.description!),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _BeneficiariesList(project: project)),
                  const SizedBox(width: 12),
                  Expanded(child: _PartnersList(project: project)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeneficiariesList extends ConsumerStatefulWidget {
  final Project project;
  const _BeneficiariesList({required this.project});

  @override
  ConsumerState<_BeneficiariesList> createState() => _BeneficiariesListState();
}

class _BeneficiariesListState extends ConsumerState<_BeneficiariesList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref.read(beneficiaryRepositoryProvider).forProject(widget.project.id!),
      builder: (context, snapshot) {
        final items = snapshot.data ?? <Beneficiary>[];
        return Card(
          child: Column(
            children: [
              ListTile(title: const Text('Bénéficiaires'), trailing: IconButton(icon: const Icon(Icons.add), onPressed: _add)),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) => ListTile(title: Text(items[i].fullName)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _add() async {
    final all = await ref.read(beneficiaryRepositoryProvider).getAll();
    if (!mounted) return;
    final selected = await showModalBottomSheet<Beneficiary>(
      context: context,
      builder: (_) => _SelectList<Beneficiary>(
        title: 'Sélectionner un bénéficiaire',
        items: all,
        label: (b) => b.fullName,
      ),
    );
    if (selected != null) {
      await ref.read(beneficiaryRepositoryProvider).linkToProject(projectId: widget.project.id!, beneficiaryId: selected.id!);
      if (mounted) setState(() {});
    }
  }
}

class _PartnersList extends ConsumerStatefulWidget {
  final Project project;
  const _PartnersList({required this.project});

  @override
  ConsumerState<_PartnersList> createState() => _PartnersListState();
}

class _PartnersListState extends ConsumerState<_PartnersList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref.read(partnerRepositoryProvider).forProject(widget.project.id!),
      builder: (context, snapshot) {
        final items = snapshot.data ?? <Partner>[];
        return Card(
          child: Column(
            children: [
              ListTile(title: const Text('Partenaires'), trailing: IconButton(icon: const Icon(Icons.add), onPressed: _add)),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) => ListTile(title: Text(items[i].name))),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _add() async {
    final all = await ref.read(partnerRepositoryProvider).getAll();
    if (!mounted) return;
    final selected = await showModalBottomSheet<Partner>(
      context: context,
      builder: (_) => _SelectList<Partner>(
        title: 'Sélectionner un partenaire',
        items: all,
        label: (p) => p.name,
      ),
    );
    if (selected != null) {
      await ref.read(partnerRepositoryProvider).linkToProject(projectId: widget.project.id!, partnerId: selected.id!);
      if (mounted) setState(() {});
    }
  }
}

class _SelectList<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final String Function(T) label;
  const _SelectList({required this.title, required this.items, required this.label});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: Text(title, style: Theme.of(context).textTheme.titleMedium)),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(label(items[i])),
                onTap: () => Navigator.pop(context, items[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
