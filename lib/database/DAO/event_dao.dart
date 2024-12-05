import 'package:sqflite/sqflite.dart';
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

    // Convert the List<Map<String, dynamic>> into List<Event>
    return List.generate(eventMaps.length, (i) {
      return Event.fromMap(eventMaps[i]);
    });
  }

  // Get events by user ID
  Future<List<Event>> getEventsByUserId(int userId) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> eventMaps = await db.query('events',
        where: 'user_id = ?', whereArgs: [userId]);

    return List.generate(eventMaps.length, (i) {
      return Event.fromMap(eventMaps[i]);
    });
  }

  // Delete an event by ID
  Future<int> deleteEvent(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  // Update event details
  Future<int> updateEvent(Event event) async {
    final db = await DatabaseHelper().database;
    return await db.update('events', event.toMap(),
        where: 'id = ?', whereArgs: [event.id]);
  }
}
