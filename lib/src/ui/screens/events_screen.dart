import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event.dart';
import '../../providers/app_providers.dart';
import '../../services/notification_service.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(notificationServiceProvider).init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref.read(eventRepositoryProvider).getUpcoming(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? <Event>[];
        return Scaffold(
          body: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (_, i) {
              final e = items[i];
              return ListTile(
                leading: const Icon(Icons.event_note),
                title: Text(e.title),
                subtitle: Text('${e.location ?? ''} • ${e.date.toLocal()}'),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: items.length,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final created = await showDialog<Event>(context: context, builder: (_) => const _EventDialog());
              if (created != null) {
                final repo = ref.read(eventRepositoryProvider);
                final id = await repo.create(created);
                await ref.read(notificationServiceProvider).scheduleReminder(
                      id: id,
                      title: 'Rappel événement',
                      body: created.title,
                      dateTime: created.date,
                    );
                if (mounted) setState(() {});
              }
            },
            icon: const Icon(Icons.add_alert),
            label: const Text('Nouvel événement'),
          ),
        );
      },
    );
  }
}

class _EventDialog extends StatefulWidget {
  const _EventDialog();
  @override
  State<_EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<_EventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _location = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(hours: 1));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un événement'),
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
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(labelText: 'Lieu'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('Date: ${_date.toLocal()}')),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        locale: const Locale('fr'),
                      );
                      if (picked != null) {
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date));
                        setState(() => _date = DateTime(picked.year, picked.month, picked.day, time?.hour ?? 9, time?.minute ?? 0));
                      }
                    },
                    child: const Text('Choisir'),
                  ),
                ],
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
              Event(
                title: _title.text.trim(), 
                location: _location.text.trim().isEmpty ? null : _location.text.trim(), 
                date: _date,
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
