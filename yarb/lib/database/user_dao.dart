import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class UserDao {
  final dbHelper = DatabaseHelper();

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await dbHelper.database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await dbHelper.database;
    return await db.query('users');
  }

  Future<int> updateUser(int id, Map<String, dynamic> user) async {
    final db = await dbHelper.database;
    return await db.update('users', user, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await dbHelper.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
