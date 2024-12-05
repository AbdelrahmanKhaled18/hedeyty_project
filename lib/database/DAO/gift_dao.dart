import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/gift.dart';

class GiftDAO {
  // Insert a new gift
  Future<int> insertGift(Gift gift) async {
    final db = await DatabaseHelper().database;
    return await db.insert('gifts', gift.toMap());
  }

  // Get all gifts
  Future<List<Gift>> getGifts() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> giftMaps = await db.query('gifts');

    return List.generate(giftMaps.length, (i) {
      return Gift.fromMap(giftMaps[i]);
    });
  }

  // Get gifts by event ID
  Future<List<Gift>> getGiftsByEventId(int eventId) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> giftMaps = await db.query('gifts',
        where: 'event_id = ?', whereArgs: [eventId]);

    return List.generate(giftMaps.length, (i) {
      return Gift.fromMap(giftMaps[i]);
    });
  }

  // Delete a gift by ID
  Future<int> deleteGift(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('gifts', where: 'id = ?', whereArgs: [id]);
  }

  // Update a gift's details
  Future<int> updateGift(Gift gift) async {
    final db = await DatabaseHelper().database;
    return await db.update('gifts', gift.toMap(),
        where: 'id = ?', whereArgs: [gift.id]);
  }
}
