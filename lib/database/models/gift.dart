class Gift {
  final int? id;
  final String name;
  final String? description;
  final String? category;
  final double? price;
  final String status;
  final int eventId;

  Gift({
    this.id,
    required this.name,
    this.description,
    this.category,
    this.price,
    required this.status,
    required this.eventId,
  });

  // Convert a Gift into a Map for SQL insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'event_id': eventId,
    };
  }

  // Create a Gift from a Map (used for fetching from SQLite)
  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'],
      status: map['status'],
      eventId: map['event_id'],
    );
  }
}
