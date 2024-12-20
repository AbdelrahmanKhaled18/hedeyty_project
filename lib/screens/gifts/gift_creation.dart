import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import '../../database/DAO/gift_dao.dart';
import '../../database/models/gift.dart';
import '../../database/database_helper.dart';
import 'dart:typed_data';

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
  Uint8List? giftImageBytes;

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
      String? imageString;
      if (giftImageBytes != null) {
        final compressedImageBytes =
        await FlutterImageCompress.compressWithList(
          giftImageBytes!,
          quality: 70,
        );
        imageString = base64Encode(compressedImageBytes);
      }

      DocumentReference firestoreGiftRef =
      await FirebaseFirestore.instance.collection('gifts').add({
        'event_id': widget.firestoreEventId,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _categoryController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'status': 'available',
        if (imageString != null) 'gift_image': imageString,
      });

      int localEventId = await _getLocalEventId(widget.firestoreEventId);

      Gift newGift = Gift(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        status: 'available',
        eventId: localEventId,
        firestoreId: firestoreGiftRef.id,
        giftImage: imageString,
      );

      await GiftDAO().insertGift(newGift);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift created successfully!')),
      );

      Navigator.pop(context);
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
      key: const Key('giftCreationPage'),
      appBar: AppBar(
        title: const Text("Add Gift"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    key: const Key('giftImagePicker'),
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.teal.shade100,
                      backgroundImage: giftImageBytes != null
                          ? MemoryImage(giftImageBytes!)
                          : null,
                      child: giftImageBytes == null
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_alt,
                              size: 40, color: Colors.teal),
                          SizedBox(height: 8),
                          Text(
                            "Upload Image",
                            style: TextStyle(
                              color: Colors.teal,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildEnhancedTextField(
                  key: const Key('giftNameField'),
                  controller: _nameController,
                  label: "Gift Name",
                  hintText: "Enter the gift name",
                  icon: Icons.card_giftcard,
                  validator: (value) => value == null || value.isEmpty
                      ? "Please enter the gift name"
                      : null,
                ),
                const SizedBox(height: 16),
                _buildEnhancedTextField(
                  key: const Key('giftCategoryField'),
                  controller: _categoryController,
                  label: "Category",
                  hintText: "Enter the gift category",
                  icon: Icons.category_outlined,
                  validator: (value) => value == null || value.isEmpty
                      ? "Please enter a category"
                      : null,
                ),
                const SizedBox(height: 16),
                _buildEnhancedTextField(
                  key: const Key('giftDescriptionField'),
                  controller: _descriptionController,
                  label: "Description (Optional)",
                  hintText: "Describe the gift (optional)",
                  icon: Icons.description_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                _buildEnhancedTextField(
                  key: const Key('giftPriceField'),
                  controller: _priceController,
                  label: "Price (Optional)",
                  hintText: "Enter the price",
                  icon: Icons.attach_money_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('giftSubmitButton'),
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ))
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

  Future<void> _pickImage() async {
    try {
      final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final imageBytes = await pickedFile.readAsBytes();
        setState(() {
          giftImageBytes = imageBytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed: $e")),
      );
    }
  }

  Widget _buildEnhancedTextField({
    required Key key,
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: validator,
    );
  }
}
