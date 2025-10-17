import 'package:sqflite_sqlcipher/sqflite.dart';
import '../local/db_helper.dart';
import '../models/event.dart';

class EventRepository {
  Future<int> create(EventModel event) async {
    final db = await DbHelper.instance.database;
    return db.insert('events', event.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<EventModel>> getUpcoming() async {
    final db = await DbHelper.instance.database;
    final maps = await db.query('events', orderBy: 'date ASC');
    return maps.map(EventModel.fromMap).toList();
  }

  Future<int> delete(int id) async {
    final db = await DbHelper.instance.database;
    return db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
}
