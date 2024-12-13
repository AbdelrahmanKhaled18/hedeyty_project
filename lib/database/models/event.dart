class Event {
  final int? id;
  final String name;
  final String date;
  final String? location;
  final String? description;
  final int userId;
  final String? firestoreId;

  Event({
    this.id,
    required this.name,
    required this.date,
    this.location,
    this.description,
    required this.userId,
    this.firestoreId,
  });

  // Convert an Event into a Map for SQL insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'location': location,
      'description': description,
      'user_id': userId,
      'firestore_id': firestoreId,
    };
  }

  // Create an Event from a Map (used for fetching from SQLite)
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      date: map['date'],
      location: map['location'],
      description: map['description'],
      userId: map['user_id'],
      firestoreId: map['firestore_id'],
    );
  }
}
