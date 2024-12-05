class User {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final String? preferences;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.preferences,
  });

  // Convert a User into a Map for SQL insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'preferences': preferences,
    };
  }

  // Create a User from a Map (used for fetching from SQLite)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      preferences: map['preferences'],
    );
  }
}
