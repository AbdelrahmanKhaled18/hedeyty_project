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
              centerTitle: true,
              backgroundColor: Colors.teal,
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
            return const Center(
              child: Text(
                'No events found.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            );
          }

          final events = snapshot.data!.docs;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: InkWell(
                    onTap: () => _navigateToGiftList(
                      event.id,
                      event['name'],
                      isCurrentUser,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.teal.shade100,
                            child: Text(
                              event['name'].substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Event Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Event Name
                                Text(
                                  event['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 8),

                                // Location Row
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Location: ${event['location']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),

                                // Date Row
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Date: ${event['date']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Edit/Delete Buttons (If Current User)
                          if (isCurrentUser)
                            Wrap(
                              spacing: 8.0,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _showEditEventDialog(event);
                                  },
                                  tooltip: "Edit Event",
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _deleteEvent(event.id);
                                  },
                                  tooltip: "Delete Event",
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
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
              backgroundColor: Colors.teal,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.edit, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                'Edit Event',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Make changes to your event details below.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                _buildStyledTextField(
                  label: 'Event Name',
                  controller: nameController,
                  icon: Icons.event,
                ),
                const SizedBox(height: 16),
                _buildStyledTextField(
                  label: 'Location',
                  controller: locationController,
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 16),
                _buildStyledTextField(
                  label: 'Date',
                  controller: dateController,
                  icon: Icons.calendar_today,
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
                const SizedBox(height: 16),
                _buildStyledTextField(
                  label: 'Description',
                  controller: descriptionController,
                  icon: Icons.description,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save, size: 20),
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
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              label: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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

  Widget _buildStyledTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    int maxLines = 1,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.teal,
            width: 2,
          ),
        ),
      ),
    );
  }
}
