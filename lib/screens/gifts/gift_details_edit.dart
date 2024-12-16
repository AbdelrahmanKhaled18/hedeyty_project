import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yarb/database/DAO/event_dao.dart';
import '../../database/DAO/gift_dao.dart';
import '../../database/database_helper.dart';
import '../../database/models/gift.dart';

class GiftDetailsAndEditScreen extends StatefulWidget {
  final String giftId;
  final bool canEdit;
  final String friendFirestoreId;

  const GiftDetailsAndEditScreen({
    super.key,
    required this.giftId,
    required this.canEdit,
    required this.friendFirestoreId,
  });

  @override
  State<GiftDetailsAndEditScreen> createState() =>
      _GiftDetailsAndEditScreenState();
}

class _GiftDetailsAndEditScreenState extends State<GiftDetailsAndEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadGiftDetails();
  }

  Future<void> _loadGiftDetails() async {
    try {
      final giftSnapshot = await FirebaseFirestore.instance
          .collection('gifts')
          .doc(widget.giftId)
          .get();

      if (giftSnapshot.exists) {
        final giftData = giftSnapshot.data()!;
        setState(() {
          _nameController.text = giftData['name'];
          _categoryController.text = giftData['category'];
          _descriptionController.text = giftData['description'];
        });
      } else {
        _showSnackBar('Gift not found.');
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('Failed to load gift details: $e');
    }
  }

  Future<void> _updateGift() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('gifts')
          .doc(widget.giftId)
          .update({
        'name': _nameController.text,
        'category': _categoryController.text,
        'description': _descriptionController.text,
      });

      final updatedGift = Gift(
        id: await _getLocalGiftId(widget.giftId),
        name: _nameController.text,
        category: _categoryController.text,
        description: _descriptionController.text,
        status: 'available',
        eventId: await _getLocalEventIdFromFirestore(widget.giftId),
        firestoreId: widget.giftId,
      );

      await GiftDAO().updateGift(updatedGift);

      setState(() => _isEditing = false);
      _showSnackBar('Gift updated successfully');
    } catch (e) {
      _showSnackBar('Failed to update gift: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteGift() async {
    try {
      await FirebaseFirestore.instance
          .collection('gifts')
          .doc(widget.giftId)
          .delete();

      final localGiftId = await _getLocalGiftId(widget.giftId);
      await GiftDAO().deleteGift(localGiftId);

      _showSnackBar('Gift deleted successfully');
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Failed to delete gift: $e');
    }
  }

  Future<String> _getFirestoreUserIdFromEvent(String eventFirestoreId) async {
    final eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventFirestoreId)
        .get();

    if (eventSnapshot.exists && eventSnapshot.data() != null) {
      return eventSnapshot.data()!['user_id'] ?? '';
    }

    throw Exception(
        'Firestore user ID not found for Event ID: $eventFirestoreId');
  }

  Future<void> _pledgeGift() async {
    setState(() => _isLoading = true);

    try {
      String pledgedByFirestoreId =
          FirebaseAuth.instance.currentUser?.uid ?? '';
      int pledgedById = await _getLocalUserId(pledgedByFirestoreId);

      String pledgedToFirestoreId =
          await _getFirestoreUserIdFromEvent(widget.friendFirestoreId);
      int pledgedToId = await _getLocalUserId(pledgedToFirestoreId);

      await FirebaseFirestore.instance
          .collection('gifts')
          .doc(widget.giftId)
          .update({
        'status': 'pledged',
        'pledged_by': pledgedByFirestoreId,
        'pledged_to': pledgedToFirestoreId,
      });

      final pledgedGift = Gift(
        id: await _getLocalGiftId(widget.giftId),
        name: _nameController.text,
        category: _categoryController.text,
        description: _descriptionController.text,
        status: 'pledged',
        eventId: await _getLocalEventIdFromFirestore(widget.giftId),
        firestoreId: widget.giftId,
        pledgedBy: pledgedById,
        pledgedTo: pledgedToId,
      );

      await GiftDAO().updateGift(pledgedGift);

      _showSnackBar('Gift pledged successfully');
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Failed to pledge gift: $e');
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<int> _getLocalUserId(String firestoreUserId) async {
    final db = await DatabaseHelper().database;

    if (firestoreUserId.isEmpty) {
      throw Exception('Firestore user ID is empty');
    }

    var result = await db.query(
      'users',
      where: 'firestore_id = ?',
      whereArgs: [firestoreUserId],
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }

    throw Exception(
        'Local user ID not found for Firestore ID: $firestoreUserId');
  }

  Future<int> _getLocalGiftId(String firestoreGiftId) async {
    final db = await DatabaseHelper().database;
    var result = await db.query(
      'gifts',
      where: 'firestore_id = ?',
      whereArgs: [firestoreGiftId],
    );
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }
    throw Exception(
        'Local gift ID not found for Firestore ID: $firestoreGiftId');
  }

  Future<int> _getLocalEventIdFromFirestore(String firestoreGiftId) async {
    final db = await DatabaseHelper().database;
    var result = await db.query(
      'gifts',
      where: 'firestore_id = ?',
      whereArgs: [firestoreGiftId],
    );
    if (result.isNotEmpty) {
      return result.first['event_id'] as int;
    }
    throw Exception(
        'Local event ID not found for Firestore ID: $firestoreGiftId');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Details & Edit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: widget.canEdit
            ? [
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => setState(() => _isEditing = true),
                  ),
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteGift(),
                  ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                  'Gift Name', _nameController, widget.canEdit && _isEditing),
              _buildTextField('Category', _categoryController,
                  widget.canEdit && _isEditing),
              _buildTextField('Description', _descriptionController,
                  widget.canEdit && _isEditing,
                  maxLines: 4),
              const SizedBox(height: 24),
              if (!widget.canEdit) _buildPledgeButton(),
              if (widget.canEdit && _isEditing) _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool enabled,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        validator: (value) =>
            value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _updateGift,
      icon: const Icon(Icons.save, color: Colors.white),
      label: const Text('Save Changes', style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildPledgeButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _pledgeGift,
      icon: const Icon(Icons.volunteer_activism, color: Colors.white),
      label: const Text('Pledge This Gift', style: TextStyle(fontSize: 16)),
    );
  }
}
