import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/project.dart';
import '../../providers/app_providers.dart';

class ProgramsScreen extends ConsumerWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Programmes'),
          bottom: const TabBar(tabs: [Tab(text: 'CLAC'), Tab(text: 'IFADEM'), Tab(text: 'ELAN')]),
        ),
        body: const TabBarView(children: [
          _ProgramList(program: 'CLAC'),
          _ProgramList(program: 'IFADEM'),
          _ProgramList(program: 'ELAN'),
        ]),
      ),
    );
  }
}

class _ProgramList extends ConsumerWidget {
  final String program;
  const _ProgramList({required this.program});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(projectRepositoryProvider).getAll(),
      builder: (context, snapshot) {
        final items = (snapshot.data ?? <Project>[]).where((p) => p.program == program).toList();
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemBuilder: (_, i) => ListTile(title: Text(items[i].title), subtitle: Text(items[i].status)),
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: items.length,
        );
      },
    );
  }
}
