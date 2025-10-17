import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/db_helper.dart';
import '../data/models/user.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  Future<User?> authenticate(String username, String password) async {
    final db = await DbHelper.instance.database;
    final hash = _hash(password);
    final res = await db.query('users', where: 'name = ? AND passwordHash = ?', whereArgs: [username, hash], limit: 1);
    if (res.isEmpty) return null;
    return User.fromMap(res.first);
  }

  Future<void> createAdminIfMissing() async {
    final db = await DbHelper.instance.database;
    final res = await db.query('users', limit: 1);
    if (res.isEmpty) {
      await db.insert('users', {
        'name': 'admin',
        'email': 'admin@cnf.ci',
        'role': 'ADMIN',
        'passwordHash': _hash('admin123'),
      });
    }
  }

  String _hash(String input) => sha256.convert(utf8.encode(input)).toString();
}
