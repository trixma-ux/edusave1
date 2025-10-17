import 'package:sqflite_sqlcipher/sqflite.dart';
import '../local/db_helper.dart';
import '../models/project.dart';

class ProjectRepository {
  Future<int> create(Project project) async {
    final db = await DbHelper.instance.database;
    return db.insert('projects', project.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Project>> getAll() async {
    final db = await DbHelper.instance.database;
    final maps = await db.query('projects', orderBy: 'startDate DESC NULLS LAST');
    return maps.map(Project.fromMap).toList();
  }

  Future<int> update(Project project) async {
    final db = await DbHelper.instance.database;
    return db.update('projects', project.toMap(), where: 'id = ?', whereArgs: [project.id]);
  }

  Future<Project?> getById(int id) async {
    final db = await DbHelper.instance.database;
    final maps = await db.query('projects', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Project.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    final db = await DbHelper.instance.database;
    return db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }
}
