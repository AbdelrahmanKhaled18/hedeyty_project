import '../database_helper.dart';
import '../models/event.dart';

class EventDAO {
  // Insert a new event
  Future<int> insertEvent(Event event) async {
    final db = await DatabaseHelper().database;
    return await db.insert('events', event.toMap());
  }

  // Get all events
  Future<List<Event>> getEvents() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> eventMaps = await db.query('events');

    return List.generate(eventMaps.length, (i) {
      return Event.fromMap(eventMaps[i]);
    });
  }

  // Get events by user ID
  Future<List<Event>> getEventsByUserId(int userId) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> eventMaps = await db.query(
      'events',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return List.generate(eventMaps.length, (i) {
      return Event.fromMap(eventMaps[i]);
    });
  }

  // Get event by Firestore ID
  Future<Event?> getEventByFirestoreId(String firestoreId) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> eventMaps = await db.query(
      'events',
      where: 'firestore_id = ?',
      whereArgs: [firestoreId],
    );

    if (eventMaps.isNotEmpty) {
      return Event.fromMap(eventMaps.first);
    }
    return null;
  }

  // Delete an event by Firestore ID
  Future<int> deleteEventByFirestoreId(String firestoreId) async {
    final db = await DatabaseHelper().database;
    return await db.delete(
      'events',
      where: 'firestore_id = ?',
      whereArgs: [firestoreId],
    );
  }

  // Delete an event by local ID
  Future<int> deleteEvent(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update event details
  Future<int> updateEvent(Event event) async {
    final db = await DatabaseHelper().database;
    return await db.update(
      'events',
      event.toMap(),
      where: 'firestore_id = ?',
      whereArgs: [event.firestoreId],
    );
  }

  Future<int> getUserIdFromEventId(String eventFirestoreId) async {
    final db = await DatabaseHelper().database;

    if (eventFirestoreId.isEmpty) {
      throw Exception('Event Firestore ID is empty');
    }

    var result = await db.query(
      'events',
      where: 'firestore_id = ?',
      whereArgs: [eventFirestoreId],
    );

    if (result.isNotEmpty) {
      return result.first['user_id'] as int;
    }

    throw Exception('User ID not found for Firestore Event ID: $eventFirestoreId');
  }
}
