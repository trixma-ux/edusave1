import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlatformDbHelper {
  PlatformDbHelper._internal();
  static final PlatformDbHelper instance = PlatformDbHelper._internal();

  static const _dbName = 'edusave.db';
  static const _dbVersion = 1;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<String> _getOrCreateKey() async {
    const keyName = 'edusave_db_key';
    
    if (kIsWeb) {
      // For web, use SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      var key = prefs.getString(keyName);
      key ??= _generateRandomKey();
      await prefs.setString(keyName, key);
      return key;
    } else {
      // For mobile/desktop, use secure storage
      final prefs = await SharedPreferences.getInstance();
      var key = prefs.getString(keyName);
      key ??= _generateRandomKey();
      await prefs.setString(keyName, key);
      return key;
    }
  }

  String _generateRandomKey() {
    // 32-char random simple key; in production, generate securely.
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789!@#%^&*()_-+';
    final now = DateTime.now().microsecondsSinceEpoch;
    return List.generate(32, (i) => chars[(now + i) % chars.length]).join();
  }

  Future<Database> _initDb() async {
    if (kIsWeb) {
      // Web platform - use regular SQLite
      return await _initWebDb();
    } else {
      // Mobile platforms (iOS/Android)
      return await _initMobileDb();
    }
  }

  Future<Database> _initWebDb() async {
    // For web, use regular SQLite without encryption
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle migrations when bumping version
      },
    );
  }

  Future<Database> _initMobileDb() async {
    // For mobile platforms (iOS/Android)
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    final key = await _getOrCreateKey();

    return await openDatabase(
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
        passwordHash TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE projects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        program TEXT NOT NULL,
        status TEXT NOT NULL,
        description TEXT,
        startDate TEXT,
        endDate TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE beneficiaries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        gender TEXT,
        age INTEGER,
        segment TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE partners(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE project_beneficiaries(
        projectId INTEGER,
        beneficiaryId INTEGER,
        PRIMARY KEY(projectId, beneficiaryId),
        FOREIGN KEY(projectId) REFERENCES projects(id) ON DELETE CASCADE,
        FOREIGN KEY(beneficiaryId) REFERENCES beneficiaries(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE project_partners(
        projectId INTEGER,
        partnerId INTEGER,
        PRIMARY KEY(projectId, partnerId),
        FOREIGN KEY(projectId) REFERENCES projects(id) ON DELETE CASCADE,
        FOREIGN KEY(partnerId) REFERENCES partners(id) ON DELETE CASCADE
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
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY(projectId) REFERENCES projects(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE indicators(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projectId INTEGER NOT NULL,
        name TEXT NOT NULL,
        value REAL NOT NULL,
        unit TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY(projectId) REFERENCES projects(id) ON DELETE CASCADE
      );
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_projects_status ON projects(status);');
    await db.execute('CREATE INDEX idx_projects_program ON projects(program);');
    await db.execute('CREATE INDEX idx_events_date ON events(date);');
    await db.execute('CREATE INDEX idx_beneficiaries_segment ON beneficiaries(segment);');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
