class UserModel {
  final int? id;
  final String name;
  final String email;
  final String? phone;        // Added phone field
  final String? password;
  final String? preferences;
  final String? firestoreId;  // Firestore ID field

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,               // Initialize phone in constructor
    this.password,
    this.preferences,
    this.firestoreId,
  });

  /// Convert a User into a Map for SQL insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,        // Include phone in map
      'password': password,
      'preferences': preferences,
      'firestore_id': firestoreId,
    };
  }

  /// Create a User from a Map (used for fetching from SQLite)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,    // Extract phone from map
      password: map['password'] as String?,
      preferences: map['preferences'] as String?,
      firestoreId: map['firestore_id'] as String?,
    );
  }
}
