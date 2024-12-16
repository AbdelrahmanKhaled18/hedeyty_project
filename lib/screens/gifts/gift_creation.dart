import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../database/DAO/gift_dao.dart';
import '../../database/models/gift.dart';
import '../../database/database_helper.dart';

class GiftCreationScreen extends StatefulWidget {
  final String firestoreEventId;

  const GiftCreationScreen({
    super.key,
    required this.firestoreEventId,
  });

  @override
  State<GiftCreationScreen> createState() => _GiftCreationScreenState();
}

class _GiftCreationScreenState extends State<GiftCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<int> _getLocalEventId(String firestoreEventId) async {
    final db = await DatabaseHelper().database;
    var result = await db.query(
      'events',
      where: 'firestore_id = ?',
      whereArgs: [firestoreEventId],
    );
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }
    throw Exception(
        'Local event ID not found for Firestore ID: $firestoreEventId');
  }

  Future<void> _createGift() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Add gift to Firestore
      DocumentReference firestoreGiftRef =
          await FirebaseFirestore.instance.collection('gifts').add({
        'event_id': widget.firestoreEventId,
        'name': _nameController.text,
        'description': _descriptionController.text,
        'category': _categoryController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'status': 'available',
        'pledged_by': null,
        'pledged_to': null,
      });

      // Get corresponding local event ID
      int localEventId = await _getLocalEventId(widget.firestoreEventId);

      // Create and insert gift into the local SQLite database
      Gift newGift = Gift(
        name: _nameController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        status: 'available',
        eventId: localEventId,
        firestoreId: firestoreGiftRef.id,
        pledgedBy: null,
        pledgedTo: null,
      );

      await GiftDAO().insertGift(newGift);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift created successfully!')),
      );

      Navigator.pop(context); // Return to GiftListScreen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating gift: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Gift")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: "Gift Name",
                  validator: (value) =>
                      value == null || value.isEmpty ? "Enter gift name" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _categoryController,
                  label: "Category",
                  validator: (value) => value == null || value.isEmpty
                      ? "Enter a category"
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: "Description (Optional)",
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _priceController,
                  label: "Price (Optional)",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createGift,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Add Gift',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
