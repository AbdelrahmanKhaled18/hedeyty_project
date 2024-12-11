class UserModel {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final String? preferences;
  final String? firestoreId;  // Add this field

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.preferences,
    this.firestoreId,  // Initialize in constructor
  });

  // Convert a User into a Map for SQL insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'preferences': preferences,
      'firestore_id': firestoreId,  // Add this line
    };
  }

  // Create a User from a Map (used for fetching from SQLite)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      preferences: map['preferences'],
      firestoreId: map['firestore_id'] as String?,  // Add this line
    );
  }
}
