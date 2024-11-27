import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class EventDao {
  final dbHelper = DatabaseHelper();

  Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await dbHelper.database;
    return await db.insert('events', event);
  }

  Future<List<Map<String, dynamic>>> getEventsByUser(int userId) async {
    final db = await dbHelper.database;
    return await db.query('events', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> updateEvent(int id, Map<String, dynamic> event) async {
    final db = await dbHelper.database;
    return await db.update('events', event, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteEvent(int id) async {
    final db = await dbHelper.database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
}
