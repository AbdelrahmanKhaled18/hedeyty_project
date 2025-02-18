import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../database/models/event.dart';
import '../../database/DAO/event_dao.dart';
import '../../database/database_helper.dart';

class EventCreationPage extends StatefulWidget {
  const EventCreationPage({super.key});

  @override
  _EventCreationPageState createState() => _EventCreationPageState();
}

class _EventCreationPageState extends State<EventCreationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      String firestoreUserId = FirebaseAuth.instance.currentUser!.uid;
      int localUserId = await _getLocalUserId(firestoreUserId);

      // Save to Firestore and get the document ID
      String firestoreId = await _saveEventToFirestore(firestoreUserId: firestoreUserId);

      // Create event model with Firestore ID
      Event newEvent = Event(
        name: _nameController.text,
        date: _dateController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        userId: localUserId,
        firestoreId: firestoreId,
      );

      // Insert into SQLite
      await EventDAO().insertEvent(newEvent);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );

      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating event: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _saveEventToFirestore({required String firestoreUserId}) async {
    DocumentReference docRef = await FirebaseFirestore.instance.collection('events').add({
      'user_id': firestoreUserId,
      'name': _nameController.text,
      'date': _dateController.text,
      'location': _locationController.text,
      'description': _descriptionController.text,
    });
    return docRef.id;
  }

  Future<int> _getLocalUserId(String firestoreId) async {
    final db = await DatabaseHelper().database;
    var result = await db.query(
      'users',
      where: 'firestore_id = ?',
      whereArgs: [firestoreId],
    );
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }
    throw Exception('Local user ID not found for Firestore ID: $firestoreId');
  }

  void _clearForm() {
    _nameController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _dateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key("eventCreationPage"),
      appBar: AppBar(
        title: const Text('Create Event'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Name Field
                _buildTextField(
                  key: const Key("eventNameField"),
                  controller: _nameController,
                  labelText: 'Event Name',
                  hintText: 'Enter event name',
                  icon: Icons.event,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Event Date Field
                _buildTextField(
                  key: const Key("eventDateField"),
                  controller: _dateController,
                  labelText: 'Event Date',
                  hintText: 'Select event date',
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
                      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                      setState(() => _dateController.text = formattedDate);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Location Field (Optional)
                _buildTextField(
                  key: const Key("eventLocationField"),
                  controller: _locationController,
                  labelText: 'Location (Optional)',
                  hintText: 'Enter location',
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 20),

                // Description Field (Optional)
                _buildTextField(
                  key: const Key("eventDescriptionField"),
                  controller: _descriptionController,
                  labelText: 'Description (Optional)',
                  hintText: 'Enter description',
                  icon: Icons.description,
                  maxLines: 4,
                ),
                const SizedBox(height: 30),

                // Create Event Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key("eventSubmitButton"),
                    onPressed: _isLoading ? null : _createEvent,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : const Text(
                      'Create Event',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom Text Field Widget
  Widget _buildTextField({
    required Key key,
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.teal,
            width: 2,
          ),
        ),
      ),
      validator: validator,
    );
  }
}
