import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/local/db_helper.dart';

final statsServiceProvider = Provider<StatsService>((ref) => StatsService());

class StatsService {
  Future<Map<String, int>> projectsCountByProgram({DateTime? from, DateTime? to}) async {
    final db = await DbHelper.instance.database;
    String where = '';
    final args = <Object?>[];
    if (from != null) {
      where += (where.isEmpty ? 'WHERE ' : ' AND ') + 'date(startDate) >= date(?)';
      args.add(_d(from));
    }
    if (to != null) {
      where += (where.isEmpty ? 'WHERE ' : ' AND ') + 'date(endDate) <= date(?)';
      args.add(_d(to));
    }
    final res = await db.rawQuery('''
      SELECT program, COUNT(*) as c
      FROM projects
      $where
      GROUP BY program
    ''', args);
    return {for (final r in res) (r['program'] as String): (r['c'] as int)};
  }

  Future<Map<String, Map<String, int>>> participationByProgramAndGender({DateTime? from, DateTime? to}) async {
    final db = await DbHelper.instance.database;
    String where = '';
    final args = <Object?>[];
    if (from != null) {
      where += (where.isEmpty ? 'WHERE ' : ' AND ') + 'date(p.startDate) >= date(?)';
      args.add(_d(from));
    }
    if (to != null) {
      where += (where.isEmpty ? 'WHERE ' : ' AND ') + 'date(p.endDate) <= date(?)';
      args.add(_d(to));
    }
    final res = await db.rawQuery('''
      SELECT p.program as program, COALESCE(b.gender,'N/A') as gender, COUNT(*) as c
      FROM project_beneficiaries pb
      JOIN projects p ON p.id = pb.projectId
      JOIN beneficiaries b ON b.id = pb.beneficiaryId
      $where
      GROUP BY p.program, b.gender
    ''', args);
    final map = <String, Map<String, int>>{};
    for (final r in res) {
      final prog = r['program'] as String;
      final gender = r['gender'] as String;
      final c = r['c'] as int;
      map.putIfAbsent(prog, () => {});
      map[prog]![gender] = c;
    }
    return map;
  }

  Future<int> upcomingEventsCount() async {
    final db = await DbHelper.instance.database;
    final res = await db.rawQuery('SELECT COUNT(*) as c FROM events WHERE datetime(date) >= datetime(?)', [DateTime.now().toIso8601String()]);
    return (res.first['c'] as int);
  }

  String _d(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
}
