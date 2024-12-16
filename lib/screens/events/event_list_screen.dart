import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../database/DAO/event_dao.dart';
import '../../database/models/event.dart';
import '../gifts/gift_list_screen.dart';
import 'event_creation.dart';

class EventListScreen extends StatefulWidget {
  final String? friendId;
  final String? friendName;

  const EventListScreen({super.key, this.friendId, this.friendName});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  late Stream<QuerySnapshot> _eventsStream;
  final EventDAO _eventDAO = EventDAO();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  void _fetchEvents() {
    String userId = widget.friendId ?? FirebaseAuth.instance.currentUser!.uid;
    _eventsStream = FirebaseFirestore.instance
        .collection('events')
        .where('user_id', isEqualTo: userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = widget.friendId == null;

    return Scaffold(
      appBar: !isCurrentUser
          ? AppBar(
              title: Text("${widget.friendName}'s Events List"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
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

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                child: InkWell(
                  onTap: () => _navigateToGiftList(
                    event.id,
                    event['name'],
                    isCurrentUser,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.teal.shade100,
                      child: Text(
                        event['name'].substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      event['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Location: ${event['location']}',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          'Date: ${event['date']}',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: isCurrentUser
                        ? Wrap(
                            spacing: 8.0,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _showEditEventDialog(event);
                                },
                                tooltip: "Edit Event",
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteEvent(event.id);
                                },
                                tooltip: "Delete Event",
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isCurrentUser
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EventCreationPage(),
                  ),
                ).then((_) => _fetchEvents());
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .delete();

      // Delete from Local SQLite Database
      final dbEvents = await _eventDAO.getEvents();
      final localEvent = dbEvents.firstWhere(
        (event) => event.firestoreId == eventId,
        orElse: () => throw Exception("Event not found locally"),
      );

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
                _buildTextField('Name', nameController),
                _buildTextField('Location', locationController),
                _buildTextField(
                  'Date',
                  dateController,
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      dateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                ),
                _buildTextField(
                  'Description',
                  descriptionController,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .update({
        'name': name,
        'date': date,
        'location': location,
        'description': description,
      });

      // Update in Local SQLite Database
      final dbEvents = await _eventDAO.getEvents();
      final localEvent = dbEvents.firstWhere(
        (event) => event.firestoreId == eventId,
        orElse: () => throw Exception("Event not found locally"),
      );

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

  void _navigateToGiftList(String eventId, String eventName, bool canEdit) {
    print(widget.friendId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftListScreen(
          eventId: eventId,
          eventName: eventName,
          canEdit: canEdit,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool readOnly = false, int maxLines = 1, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      onTap: onTap,
      decoration: InputDecoration(labelText: label),
    );
  }
}
