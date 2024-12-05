class Friend {
  final int userId;
  final int friendId;

  Friend({
    required this.userId,
    required this.friendId,
  });

  // Convert a Friend into a Map for SQL insertion
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'friend_id': friendId,
    };
  }

  // Create a Friend from a Map (used for fetching from SQLite)
  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      userId: map['user_id'],
      friendId: map['friend_id'],
    );
  }
}
