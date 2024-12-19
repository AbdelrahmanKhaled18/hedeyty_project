import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yarb/screens/tabs.dart';
import '../../database/database_helper.dart';
import 'package:image/image.dart' as img;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isEditing = false;
  bool isLoading = true;
  List<Map<String, dynamic>> pledgedGifts = [];
  String? profileImageBase64; // Holds the base64 string of the image
  Uint8List? profileImageBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchPledgedGifts();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Fetch user data from Firestore
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userSnapshot.exists) {
        final data = userSnapshot.data()!;

        setState(() {
          nameController.text = data['name'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['phone'] ?? '';

          // Decode and decompress the profile image
          if (data['profile_image'] != null &&
              data['profile_image'].isNotEmpty) {
            final compressedBytes = base64Decode(data['profile_image']);

            // Decode the image using the image package
            img.Image? decompressedImage = img.decodeJpg(compressedBytes);

            if (decompressedImage != null) {
              profileImageBytes = Uint8List.fromList(
                img.encodePng(decompressedImage),
              );
            } else {
              profileImageBytes = null; // Handle image decoding failure
            }
          } else {
            profileImageBytes = null;
          }
        });

        // Sync data with local SQLite database
        await _syncLocalDb(user.uid, data);
      } else {
        throw Exception("User not found in Firestore.");
      }
    } catch (e) {
      _showSnackBar("Failed to load user data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _syncLocalDb(String userId, Map<String, dynamic> data) async {
    final db = await DatabaseHelper().database;

    // Prepare updated user data
    final updatedData = {
      'firestore_id': userId,
      'name': data['name'],
      'email': data['email'],
      'phone': data['phone'],
      'profile_image': data['profile_image'] ?? '', // Sync profile image
    };

    // Check if the user already exists in SQLite
    final existing = await db.query(
      'users',
      where: 'firestore_id = ?',
      whereArgs: [userId],
    );

    if (existing.isEmpty) {
      await db.insert('users', updatedData); // Insert if not exists
    } else {
      await db.update(
        'users',
        updatedData, // Update if already exists
        where: 'firestore_id = ?',
        whereArgs: [userId],
      );
    }
  }

  Future<void> _fetchPledgedGifts() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('gifts')
          .where('pledged_to', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pledged')
          .get();

      List<Map<String, dynamic>> fetchedGifts = [];

      // Fetch details for each pledged gift and resolve the user name
      for (var doc in snapshot.docs) {
        final data = doc.data();

        String pledgedByName = 'Unknown'; // Default value
        if (data['pledged_by'] != null) {
          // Fetch the user name for 'pledged_by'
          final pledgedBySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(data['pledged_by'])
              .get();

          if (pledgedBySnapshot.exists) {
            pledgedByName = pledgedBySnapshot['name'] ?? 'Unknown';
          }
        }

        // Add gift data with pledged_by name
        fetchedGifts.add({
          'name': data['name'],
          'category': data['category'],
          'description': data['description'] ?? 'No description provided',
          'price': data['price'] ?? 0.0,
          'pledged_by': pledgedByName,
          'gift_image': data['gift_image'], // Include gift image
        });
      }

      setState(() {
        pledgedGifts = fetchedGifts;
      });
    } catch (e) {
      _showSnackBar("Failed to load pledged gifts: $e");
    }
  }


  Future<void> _saveUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Convert and compress the image if it exists
      String? compressedImageString;
      if (profileImageBytes != null) {
        // Decode the image using the image package
        img.Image? originalImage = img.decodeImage(profileImageBytes!);

        if (originalImage != null) {
          // Compress the image
          final compressedImageBytes = img.encodeJpg(
            originalImage,
            quality: 80, // Adjust quality (0-100)
          );

          // Convert to Base64 string
          compressedImageString = base64Encode(compressedImageBytes);
        }
      }

      // Prepare updated data
      final updatedData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        if (compressedImageString != null)
          'profile_image': compressedImageString,
      };

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updatedData);

      // Update Local Database
      final db = await DatabaseHelper().database;
      await db.update(
        'users',
        updatedData,
        where: 'firestore_id = ?',
        whereArgs: [user.uid],
      );

      // Handle password update
      if (passwordController.text.isNotEmpty) {
        final hashedPassword = _hashPassword(passwordController.text.trim());

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'password': hashedPassword});

        await db.update(
          'users',
          {'password': hashedPassword},
          where: 'firestore_id = ?',
          whereArgs: [user.uid],
        );
      }

      _showSnackBar("Profile updated successfully!");
    } catch (e) {
      _showSnackBar("Failed to update profile: $e");
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
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
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.teal.shade800,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit, size: 28),
            onPressed: () async {
              if (isEditing) await _saveUserData();
              setState(() => isEditing = !isEditing);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.teal.shade100,
                          backgroundImage: profileImageBytes != null
                              ? MemoryImage(profileImageBytes!)
                              : null,
                          child: profileImageBytes == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.teal,
                                )
                              : null,
                        ),
                        if (isEditing)
                          IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                            onPressed: _pickImage,
                            tooltip: "Upload Image",
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildEditableField(
                    "Full Name",
                    "Enter your full name",
                    nameController,
                    isEditing,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildEditableField(
                    "Email",
                    "Enter your email",
                    emailController,
                    isEditing,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  _buildEditableField(
                    "Phone",
                    "Enter your phone number",
                    phoneController,
                    isEditing,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  _buildEditableField(
                    "New Password",
                    "Enter your new password",
                    passwordController,
                    isEditing,
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 40),
                  _buildOptionTile(
                    icon: Icons.event,
                    title: "My Events",
                    subtitle: "View and manage your created events",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const TabsScreen(initialPageIndex: 1),
                        ),
                      );
                    },
                  ),
                  _buildOptionTile(
                    icon: Icons.favorite,
                    title: "My Pledged Gifts",
                    subtitle: "See gifts you pledged for others",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const TabsScreen(initialPageIndex: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Gifts Pledged to Me",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  pledgedGifts.isEmpty
                      ? const Text(
                          "No pledged gifts found.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pledgedGifts.length,
                          itemBuilder: (context, index) {
                            final gift = pledgedGifts[index];
                            return _buildGiftCard(gift);
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildGiftCard(Map<String, dynamic> gift) {
    Uint8List? giftImageBytes;

    // Decode the gift image if available
    if (gift['gift_image'] != null && gift['gift_image'].isNotEmpty) {
      try {
        giftImageBytes = base64Decode(gift['gift_image']);
      } catch (e) {
        debugPrint("Error decoding gift image: $e");
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.teal.shade100,
          backgroundImage: giftImageBytes != null
              ? MemoryImage(giftImageBytes)
              : const AssetImage('assets/default_gift.jpg') as ImageProvider,
        ),
        title: Text(
          gift['name'],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Category: ${gift['category']}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              "Price: \$${gift['price'].toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              "Pledged By: ${gift['pledged_by']}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final originalImageBytes = await pickedFile.readAsBytes();

        // Decode the image using the image package
        img.Image? originalImage = img.decodeImage(originalImageBytes);

        if (originalImage != null) {
          // Compress the image (Resize and adjust quality)
          final compressedImage = img.encodeJpg(
            originalImage,
            quality: 80, // Adjust quality from 0 to 100
          );

          setState(() {
            profileImageBytes = Uint8List.fromList(compressedImage);
            profileImageBase64 =
                base64Encode(compressedImage); // Store compressed Base64
          });
        }
      }
    } catch (e) {
      _showSnackBar("Image upload failed: $e");
    }
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.teal.shade800,
          size: 30,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    String hint,
    TextEditingController controller,
    bool isEditable, {
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      enabled: isEditable,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal.shade800),
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: isEditable ? Colors.grey.shade100 : Colors.grey.shade200,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
