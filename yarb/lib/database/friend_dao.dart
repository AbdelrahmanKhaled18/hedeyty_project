import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class FriendDao {
  final dbHelper = DatabaseHelper();

  Future<int> addFriend(int userId, int friendId) async {
    final db = await dbHelper.database;
    return await db.insert('friends', {
      'user_id': userId,
      'friend_id': friendId,
    });
  }

  Future<List<Map<String, dynamic>>> getFriends(int userId) async {
    final db = await dbHelper.database;
    return await db.query('friends', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> removeFriend(int userId, int friendId) async {
    final db = await dbHelper.database;
    return await db.delete(
      'friends',
      where: 'user_id = ? AND friend_id = ?',
      whereArgs: [userId, friendId],
    );
  }
}
