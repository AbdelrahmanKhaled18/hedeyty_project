import '../database_helper.dart';
import '../models/gift.dart';

class GiftDAO {
  Future<int> insertGift(Gift gift) async {
    final db = await DatabaseHelper().database;
    return await db.insert('gifts', gift.toMap());
  }

  Future<List<Gift>> getGiftsByEventId(int eventId) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> giftMaps = await db.query(
      'gifts',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
    return giftMaps.map((giftMap) => Gift.fromMap(giftMap)).toList();
  }

  Future<List<Gift>> getPledgedGifts(int userId) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> giftMaps = await db.query(
      'gifts',
      where: 'status = ? AND pledged_by = ?',
      whereArgs: ['pledged', userId],
    );
    return giftMaps.map((giftMap) => Gift.fromMap(giftMap)).toList();
  }

  Future<int> updateGift(Gift gift) async {
    final db = await DatabaseHelper().database;
    return await db.update(
      'gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }

  Future<int> deleteGift(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete(
      'gifts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
