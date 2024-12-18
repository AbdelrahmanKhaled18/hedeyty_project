import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:yarb/screens/tabs.dart';
import '../../database/database_helper.dart';

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
        });

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
    final existing = await db.query(
      'users',
      where: 'firestore_id = ?',
      whereArgs: [userId],
    );

    final updatedData = {
      'firestore_id': userId,
      'name': data['name'],
      'email': data['email'],
      'phone': data['phone'],
    };

    if (existing.isEmpty) {
      await db.insert('users', updatedData);
    } else {
      await db.update(
        'users',
        updatedData,
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

      final updatedData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updatedData);

      final db = await DatabaseHelper().database;
      await db.update(
        'users',
        updatedData,
        where: 'firestore_id = ?',
        whereArgs: [user.uid],
      );

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
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.teal.shade100,
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.teal,
                      ),
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          child: Text(
            gift['name'].substring(0, 1).toUpperCase(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
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
            Text("Category: ${gift['category']}",
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text("Price: \$${gift['price'].toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text("Pledged By: ${gift['pledged_by']}",
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal)),
          ],
        ),
      ),
    );
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
