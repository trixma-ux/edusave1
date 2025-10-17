import 'package:sqflite_sqlcipher/sqflite.dart';
import '../local/db_helper.dart';
import '../models/partner.dart';

class PartnerRepository {
  Future<int> create(Partner p) async {
    final db = await DbHelper.instance.database;
    return db.insert('partners', p.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Partner>> getAll() async {
    final db = await DbHelper.instance.database;
    final rows = await db.query('partners', orderBy: 'name');
    return rows.map(Partner.fromMap).toList();
  }

  Future<void> linkToProject({required int projectId, required int partnerId}) async {
    final db = await DbHelper.instance.database;
    await db.insert('project_partners', {
      'projectId': projectId,
      'partnerId': partnerId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> unlinkFromProject({required int projectId, required int partnerId}) async {
    final db = await DbHelper.instance.database;
    await db.delete('project_partners', where: 'projectId = ? AND partnerId = ?', whereArgs: [projectId, partnerId]);
  }

  Future<List<Partner>> forProject(int projectId) async {
    final db = await DbHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT p.* FROM partners p
      JOIN project_partners pp ON pp.partnerId = p.id
      WHERE pp.projectId = ? ORDER BY p.name
    ''', [projectId]);
    return rows.map(Partner.fromMap).toList();
  }
}
