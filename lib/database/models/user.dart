class UserModel {
  final int? id;
  final String name;
  final String email;
  final String? phone;        // Added phone field
  final String? password;
  final String? preferences;
  final String? firestoreId;  // Firestore ID field
  final String? profileImage; // Added profile image field

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,               // Initialize phone in constructor
    this.password,
    this.preferences,
    this.firestoreId,
    this.profileImage,        // Initialize profile image
  });

  /// Convert a User into a Map for SQL insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'preferences': preferences,
      'firestore_id': firestoreId,
      'profile_image': profileImage,  // Include profile image
    };
  }

  /// Create a User from a Map (used for fetching from SQLite)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      password: map['password'] as String?,
      preferences: map['preferences'] as String?,
      firestoreId: map['firestore_id'] as String?,
      profileImage: map['profile_image'] as String?,  // Extract profile image
    );
  }
}
