class Gift {
  final int? id;
  final String name;
  final String? description;
  final String? category;
  final double? price;
  final String status;
  final int eventId;
  final String firestoreId;
  final int? pledgedBy; // Foreign Key from 'users' table
  final int? pledgedTo; // Foreign Key from 'users' table
  final String? giftImage; // New field for storing image as Base64 string

  Gift({
    this.id,
    required this.name,
    this.description,
    this.category,
    this.price,
    required this.status,
    required this.eventId,
    required this.firestoreId,
    this.pledgedBy,
    this.pledgedTo,
    this.giftImage, // Initialize the new image field
  });

  /// Convert a Gift into a Map for SQLite insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'event_id': eventId,
      'firestore_id': firestoreId,
      'pledged_by': pledgedBy,
      'pledged_to': pledgedTo,
      'gift_image': giftImage, // Include the image in the map
    };
  }

  /// Create a Gift from a Map (used for fetching from SQLite)
  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price']?.toDouble(),
      status: map['status'],
      eventId: map['event_id'],
      firestoreId: map['firestore_id'],
      pledgedBy: map['pledged_by'],
      pledgedTo: map['pledged_to'],
      giftImage: map['gift_image'], // Extract the image from the map
    );
  }
}
