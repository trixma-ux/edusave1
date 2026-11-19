import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' show ConflictAlgorithm;
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

  static Future<void>? _adminSeed;

  /// Crée le compte administrateur par défaut une seule fois, même si
  /// l'écran de connexion est construit plusieurs fois en parallèle.
  Future<void> createAdminIfMissing() =>
      _adminSeed ??= _createAdminIfMissing().catchError((Object _) {
        _adminSeed = null;
      });

  Future<void> _createAdminIfMissing() async {
    final db = await DbHelper.instance.database;
    final res = await db.query('users', limit: 1);
    if (res.isEmpty) {
      await db.insert('users', {
        'name': 'admin',
        'email': 'admin@cnf.ci',
        'role': 'ADMIN',
        'passwordHash': _hash('admin123'),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isActive': 1,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  String _hash(String input) => sha256.convert(utf8.encode(input)).toString();
}
