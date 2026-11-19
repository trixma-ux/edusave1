import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class DbHelper {
  DbHelper._internal();
  static final DbHelper instance = DbHelper._internal();

  static const _dbName = 'edusave.db';
  static const _dbVersion = 2;
  Database? _database;

  final _secureStorage = const FlutterSecureStorage();

  Future<Database>? _opening;

  /// Ouvre la base une seule fois, même en cas d'appels concurrents.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _opening ??= _initDb();
    try {
      _database = await _opening!;
    } catch (_) {
      _opening = null;
      rethrow;
    }
    return _database!;
  }

  Future<String> _getOrCreateKey() async {
    const keyName = 'edusave_db_key';
    var key = await _secureStorage.read(key: keyName);
    key ??= _generateRandomKey();
    await _secureStorage.write(key: keyName, value: key);
    return key;
  }

  String _generateRandomKey() {
    // 32-char random simple key; in production, generate securely.
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789!@#%^&*()_-+';
    final now = DateTime.now().microsecondsSinceEpoch;
    return List.generate(32, (i) => chars[(now + i) % chars.length]).join();
  }

  Future<Database> _initDb() async {
    if (kIsWeb) {
      // Sur le web, sqflite natif (MethodChannel) et path_provider ne sont pas
      // disponibles : on utilise SQLite compilé en WebAssembly (IndexedDB).
      return databaseFactoryFfiWeb.openDatabase(
        _dbName,
        options: OpenDatabaseOptions(
          version: _dbVersion,
          onCreate: (db, version) async {
            await _createSchema(db);
          },
          onUpgrade: _migrate,
        ),
      );
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    final key = await _getOrCreateKey();

    return openDatabase(
      path,
      password: key,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: _migrate,
    );
  }

  /// v1 → v2 : les modèles écrivent `createdAt`/`updatedAt` (et `isActive`
  /// pour les utilisateurs) mais le schéma v1 ne les déclarait pas, ce qui
  /// faisait échouer toute création ou connexion.
  static Future<void> _migrate(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final now = DateTime.now().toIso8601String();
      for (final table in ['users', 'projects', 'beneficiaries', 'partners', 'events']) {
        final cols = (await db.rawQuery('PRAGMA table_info($table)'))
            .map((c) => c['name'] as String)
            .toSet();
        for (final col in ['createdAt', 'updatedAt']) {
          if (!cols.contains(col)) {
            await db.execute('ALTER TABLE $table ADD COLUMN $col TEXT');
          }
        }
        await db.update(table, {'createdAt': now}, where: 'createdAt IS NULL');
        await db.update(table, {'updatedAt': now}, where: 'updatedAt IS NULL');
        if (table == 'users' && !cols.contains('isActive')) {
          await db.execute(
              'ALTER TABLE users ADD COLUMN isActive INTEGER NOT NULL DEFAULT 1');
        }
      }
    }
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        role TEXT NOT NULL,
        passwordHash TEXT NOT NULL,
        createdAt TEXT,
        updatedAt TEXT,
        isActive INTEGER NOT NULL DEFAULT 1
      );
    ''');

    await db.execute('''
      CREATE TABLE projects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        program TEXT NOT NULL, -- CLAC/IFADEM/ELAN/Autre
        status TEXT NOT NULL,
        description TEXT,
        startDate TEXT,
        endDate TEXT,
        createdAt TEXT,
        updatedAt TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE beneficiaries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        gender TEXT,
        age INTEGER,
        segment TEXT, -- jeune/femme/cinéaste
        createdAt TEXT,
        updatedAt TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE partners(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT, -- GAF, ambassade, ONG
        createdAt TEXT,
        updatedAt TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE project_beneficiaries(
        projectId INTEGER,
        beneficiaryId INTEGER,
        PRIMARY KEY(projectId, beneficiaryId)
      );
    ''');

    await db.execute('''
      CREATE TABLE project_partners(
        projectId INTEGER,
        partnerId INTEGER,
        PRIMARY KEY(projectId, partnerId)
      );
    ''');

    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        location TEXT,
        description TEXT,
        date TEXT NOT NULL,
        projectId INTEGER,
        createdAt TEXT,
        updatedAt TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE indicators(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projectId INTEGER NOT NULL,
        name TEXT NOT NULL,
        value REAL NOT NULL,
        unit TEXT
      );
    ''');
  }
}
