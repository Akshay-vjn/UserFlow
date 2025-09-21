import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('userflow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path, 
      version: 2, 
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        avatar TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE google_auth (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        google_id TEXT UNIQUE NOT NULL,
        display_name TEXT,
        email TEXT NOT NULL,
        photo_url TEXT,
        server_auth_code TEXT,
        access_token TEXT,
        id_token TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE google_auth (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          google_id TEXT UNIQUE NOT NULL,
          display_name TEXT,
          email TEXT NOT NULL,
          photo_url TEXT,
          server_auth_code TEXT,
          access_token TEXT,
          id_token TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
    }
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await instance.database;
    return await db.query('users');
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearUsers() async {
    final db = await instance.database;
    await db.delete('users');
  }

  Future<Map<String, dynamic>?> getLatestUser() async {
    final db = await instance.database;
    final rows = await db.query('users', orderBy: 'id DESC', limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<int> saveGoogleAuth(Map<String, dynamic> googleAuth) async {
    try {
      final db = await instance.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      final existing = await db.query(
        'google_auth',
        where: 'google_id = ?',
        whereArgs: [googleAuth['google_id']],
      );
      
      if (existing.isNotEmpty) {
        return await db.update(
          'google_auth',
          {
            ...googleAuth,
            'updated_at': now,
          },
          where: 'google_id = ?',
          whereArgs: [googleAuth['google_id']],
        );
      } else {
        return await db.insert('google_auth', {
          ...googleAuth,
          'created_at': now,
          'updated_at': now,
        });
      }
    } catch (e) {
      print('Error saving Google auth: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>?> getGoogleAuth() async {
    try {
      final db = await instance.database;
      final rows = await db.query(
        'google_auth',
        orderBy: 'updated_at DESC',
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return rows.first;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearGoogleAuth() async {
    try {
      final db = await instance.database;
      await db.delete('google_auth');
    } catch (e) {
      print('Error clearing Google auth: $e');
    }
  }

  Future<void> clearAllAuth() async {
    try {
      final db = await instance.database;
      await db.delete('users');
      await db.delete('google_auth');
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}