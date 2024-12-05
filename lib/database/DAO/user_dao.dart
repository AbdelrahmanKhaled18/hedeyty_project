import '../database_helper.dart';
import '../models/user.dart';

class UserDAO {
  // Insert a new user
  Future<int> insertUser(User user) async {
    final db = await DatabaseHelper().database;
    return await db.insert('users', user.toMap());
  }

  // Get all users
  Future<List<User>> getUsers() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> userMaps = await db.query('users');

    // Convert the List<Map<String, dynamic>> into List<User>
    return List.generate(userMaps.length, (i) {
      return User.fromMap(userMaps[i]);
    });
  }

  // Get a user by ID
  Future<User?> getUserById(int id) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> userMaps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (userMaps.isNotEmpty) {
      return User.fromMap(userMaps.first);
    }
    return null;
  }

  // Delete a user by ID
  Future<int> deleteUser(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Update user information
  Future<int> updateUser(User user) async {
    final db = await DatabaseHelper().database;
    return await db.update('users', user.toMap(),
        where: 'id = ?', whereArgs: [user.id]);
  }
}
