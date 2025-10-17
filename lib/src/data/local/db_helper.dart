import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class DbHelper {
  DbHelper._internal();
  static final DbHelper instance = DbHelper._internal();

  static const _dbName = 'edusave.db';
  static const _dbVersion = 1;
  Database? _database;

  final _secureStorage = const FlutterSecureStorage();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
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
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle migrations when bumping version
      },
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        role TEXT NOT NULL,
        passwordHash TEXT NOT NULL
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
        endDate TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE beneficiaries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        gender TEXT,
        age INTEGER,
        segment TEXT -- jeune/femme/cinéaste
      );
    ''');

    await db.execute('''
      CREATE TABLE partners(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT -- GAF, ambassade, ONG
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
        projectId INTEGER
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
