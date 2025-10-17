import 'package:sqflite_sqlcipher/sqflite.dart';
import '../local/db_helper.dart';
import '../models/event.dart';

class EventRepository {
  Future<int> create(Event event) async {
    final db = await DbHelper.instance.database;
    return db.insert('events', event.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Event>> getAll() async {
    final db = await DbHelper.instance.database;
    final maps = await db.query('events', orderBy: 'date ASC');
    return maps.map(Event.fromMap).toList();
  }

  Future<List<Event>> getUpcoming() async {
    final db = await DbHelper.instance.database;
    final maps = await db.query('events', orderBy: 'date ASC');
    return maps.map(Event.fromMap).toList();
  }

  Future<Event?> getById(int id) async {
    final db = await DbHelper.instance.database;
    final maps = await db.query('events', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Event.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(Event event) async {
    final db = await DbHelper.instance.database;
    return db.update('events', event.toMap(), where: 'id = ?', whereArgs: [event.id]);
  }

  Future<int> delete(int id) async {
    final db = await DbHelper.instance.database;
    return db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
}
