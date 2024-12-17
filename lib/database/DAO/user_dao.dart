import '../database_helper.dart';
import '../models/user.dart';

class UserDAO {
  // Insert a new user
  Future<int> insertUser(UserModel user) async {
    final db = await DatabaseHelper().database;
    return await db.insert('users', user.toMap());
  }

  // Get all users
  Future<List<UserModel>> getUsers() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> userMaps = await db.query('users');
    return List.generate(userMaps.length, (i) => UserModel.fromMap(userMaps[i]));
  }

  // Get a user by ID
  Future<UserModel?> getUserById(int id) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> userMaps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (userMaps.isNotEmpty) {
      return UserModel.fromMap(userMaps.first);
    }
    return null;
  }

  // Get a user by Firestore ID
  Future<UserModel?> getUserByFirestoreId(String firestoreId) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> userMaps = await db.query(
      'users',
      where: 'firestore_id = ?',
      whereArgs: [firestoreId],
    );
    if (userMaps.isNotEmpty) {
      return UserModel.fromMap(userMaps.first);
    }
    return null;
  }

  // Delete a user by ID
  Future<int> deleteUser(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update user information
  Future<int> updateUser(UserModel user) async {
    final db = await DatabaseHelper().database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Check if a user exists by Firestore ID
  Future<bool> userExistsByFirestoreId(String firestoreId) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'users',
      where: 'firestore_id = ?',
      whereArgs: [firestoreId],
    );
    return result.isNotEmpty;
  }

  // Check if a user exists by email
  Future<bool> userExistsByEmail(String email) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }
}
