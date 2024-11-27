import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'hedieaty.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate,
        onOpen: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    });
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT
        , name TEXT, email TEXT, password TEXT, preferences TEXT)''');
    await db.execute(
        'CREATE TABLE events(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT,'
        ' date TEXT, location TEXT, description TEXT, user_id INTEGER, '
        'FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE)');
    await db.execute(
        'CREATE TABLE gifts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, '
        'description TEXT, category TEXT, price REAL, status TEXT, '
        'event_id INTEGER, FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE)');
    await db.execute('CREATE TABLE friends(user_id INTEGER, friend_id INTEGER, '
        'PRIMARY KEY(user_id, friend_id), '
        'FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE, '
        'FOREIGN KEY (friend_id) REFERENCES users(id) ON DELETE CASCADE)');
  }
}
