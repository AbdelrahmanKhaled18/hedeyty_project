import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../database/DAO/event_dao.dart';
import '../database/models/event.dart';
import 'event_creation.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  late Stream<QuerySnapshot> _eventsStream;
  final EventDAO _eventDAO = EventDAO();

  @override
  void initState() {
    super.initState();
    _fetchUserEvents();
  }

  void _fetchUserEvents() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    _eventsStream = FirebaseFirestore.instance
        .collection('events')
        .where('user_id', isEqualTo: userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _eventsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No events found.'));
          }

          final events = snapshot.data!.docs;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text(event['name']),
                subtitle: Text('${event['location']} - ${event['date']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditEventDialog(event);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteEvent(event.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to EventCreationPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EventCreationPage(),
            ),
          ).then((_) {
            // Refresh events when returning to this page
            setState(() {});
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      // Get local event by Firestore ID
      final db = await _eventDAO.getEvents();
      final localEvent = db.firstWhere(
              (event) => event.firestoreId == eventId,
          orElse: () => throw Exception("Event not found locally"));

      // Delete from Firestore
      await FirebaseFirestore.instance.collection('events').doc(eventId).delete();

      // Delete from local SQLite database
      await _eventDAO.deleteEvent(localEvent.id!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event: $e')),
      );
    }
  }

  void _showEditEventDialog(QueryDocumentSnapshot event) {
    final TextEditingController nameController =
    TextEditingController(text: event['name']);
    final TextEditingController locationController =
    TextEditingController(text: event['location']);
    final TextEditingController dateController =
    TextEditingController(text: event['date']);
    final TextEditingController descriptionController =
    TextEditingController(text: event['description']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      String formattedDate =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                      dateController.text = formattedDate;
                    }
                  },
                ),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _editEvent(
                  event.id,
                  nameController.text,
                  dateController.text,
                  locationController.text,
                  descriptionController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editEvent(
      String eventId,
      String name,
      String date,
      String location,
      String description,
      ) async {
    try {
      // Update in Firestore
      await FirebaseFirestore.instance.collection('events').doc(eventId).update({
        'name': name,
        'date': date,
        'location': location,
        'description': description,
      });

      // Get local event by Firestore ID
      final db = await _eventDAO.getEvents();
      final localEvent = db.firstWhere(
              (event) => event.firestoreId == eventId,
          orElse: () => throw Exception("Event not found locally"));

      // Update local SQLite database
      final updatedEvent = Event(
        id: localEvent.id,
        name: name,
        date: date,
        location: location,
        description: description,
        userId: localEvent.userId,
        firestoreId: eventId,
      );

      await _eventDAO.updateEvent(updatedEvent);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update event: $e')),
      );
    }
  }
}
