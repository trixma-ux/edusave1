import 'package:sqflite_sqlcipher/sqflite.dart';
import '../local/db_helper.dart';
import '../models/beneficiary.dart';

class BeneficiaryRepository {
  Future<int> create(Beneficiary b) async {
    final db = await DbHelper.instance.database;
    return db.insert('beneficiaries', b.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Beneficiary>> getAll() async {
    final db = await DbHelper.instance.database;
    final rows = await db.query('beneficiaries', orderBy: 'fullName');
    return rows.map(Beneficiary.fromMap).toList();
  }

  Future<void> linkToProject({required int projectId, required int beneficiaryId}) async {
    final db = await DbHelper.instance.database;
    await db.insert('project_beneficiaries', {
      'projectId': projectId,
      'beneficiaryId': beneficiaryId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> unlinkFromProject({required int projectId, required int beneficiaryId}) async {
    final db = await DbHelper.instance.database;
    await db.delete('project_beneficiaries', where: 'projectId = ? AND beneficiaryId = ?', whereArgs: [projectId, beneficiaryId]);
  }

  Future<Beneficiary?> getById(int id) async {
    final db = await DbHelper.instance.database;
    final maps = await db.query('beneficiaries', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Beneficiary.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(Beneficiary beneficiary) async {
    final db = await DbHelper.instance.database;
    return db.update('beneficiaries', beneficiary.toMap(), where: 'id = ?', whereArgs: [beneficiary.id]);
  }

  Future<int> delete(int id) async {
    final db = await DbHelper.instance.database;
    return db.delete('beneficiaries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Beneficiary>> forProject(int projectId) async {
    final db = await DbHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT b.* FROM beneficiaries b
      JOIN project_beneficiaries pb ON pb.beneficiaryId = b.id
      WHERE pb.projectId = ? ORDER BY b.fullName
    ''', [projectId]);
    return rows.map(Beneficiary.fromMap).toList();
  }
}
