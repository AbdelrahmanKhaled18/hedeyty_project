import '../database_helper.dart';
import '../models/friend.dart';

class FriendDAO {
  // Insert a new friend relationship
  Future<int> insertFriend(Friend friend) async {
    final db = await DatabaseHelper().database;
    return await db.insert('friends', friend.toMap());
  }

  // Get all friends for a specific user
  Future<List<Friend>> getFriends(int userId) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> friendMaps = await db.query('friends',
        where: 'user_id = ?', whereArgs: [userId]);

    return List.generate(friendMaps.length, (i) {
      return Friend.fromMap(friendMaps[i]);
    });
  }

  // Delete a friend by user ID and friend ID
  Future<int> deleteFriend(int userId, int friendId) async {
    final db = await DatabaseHelper().database;
    return await db.delete('friends',
        where: 'user_id = ? AND friend_id = ?', whereArgs: [userId, friendId]);
  }
}
