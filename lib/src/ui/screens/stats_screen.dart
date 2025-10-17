import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/stats_service.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  DateTime? _from;
  DateTime? _to;

  @override
  Widget build(BuildContext context) {
    final stats = ref.read(statsServiceProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _DateField(label: 'De', value: _from, onPick: (d) => setState(() => _from = d))),
                const SizedBox(width: 8),
                Expanded(child: _DateField(label: 'À', value: _to, onPick: (d) => setState(() => _to = d))),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => setState(() {}), child: const Text('Filtrer')),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder(
              future: stats.projectsCountByProgram(from: _from, to: _to),
              builder: (context, snap) {
                final data = snap.data ?? {};
                final sections = <PieChartSectionData>[];
                final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
                var i = 0;
                data.forEach((k, v) {
                  sections.add(PieChartSectionData(value: v.toDouble(), title: k, color: colors[i % colors.length]));
                  i++;
                });
                return Card(
                  child: SizedBox(height: 220, child: sections.isEmpty ? const Center(child: Text('Aucune donnée')) : PieChart(PieChartData(sections: sections))),
                );
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder(
                future: stats.participationByProgramAndGender(from: _from, to: _to),
                builder: (context, snap) {
                  final data = snap.data ?? {};
                  final genders = {'F', 'M', 'N/A'}; // baseline
                  for (final m in data.values) {genders.addAll(m.keys);} // ensure all keys present
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Participation par programme et genre'),
                          const SizedBox(height: 8),
                          Expanded(
                            child: BarChart(
                              BarChartData(
                                barGroups: data.entries.map((e) {
                                  final prog = e.key;
                                  final m = e.value;
                                  final keys = genders.toList();
                                  return BarChartGroupData(x: prog.hashCode, barRods: [
                                    for (var i = 0; i < keys.length; i++)
                                      BarChartRodData(toY: (m[keys[i]] ?? 0).toDouble(), color: Colors.primaries[i % Colors.primaries.length])
                                  ],
                                  showingTooltipIndicators: const [0]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onPick;
  const _DateField({required this.label, required this.value, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          locale: const Locale('fr'),
        );
        onPick(picked);
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(value == null ? label : '$label: ${value!.toLocal().toString().split(' ').first}'),
      ),
    );
  }
}
