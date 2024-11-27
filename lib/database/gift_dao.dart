import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class GiftDao {
  final dbHelper = DatabaseHelper();

  Future<int> insertGift(Map<String, dynamic> gift) async {
    final db = await dbHelper.database;
    return await db.insert('gifts', gift);
  }

  Future<List<Map<String, dynamic>>> getGiftsByEvent(int eventId) async {
    final db = await dbHelper.database;
    return await db.query('gifts', where: 'event_id = ?', whereArgs: [eventId]);
  }

  Future<int> updateGift(int id, Map<String, dynamic> gift) async {
    final db = await dbHelper.database;
    return await db.update('gifts', gift, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteGift(int id) async {
    final db = await dbHelper.database;
    return await db.delete('gifts', where: 'id = ?', whereArgs: [id]);
  }
}
