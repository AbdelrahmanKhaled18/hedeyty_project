import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:yarb/screens/tabs.dart';
import '../../database/database_helper.dart';

class ProfileScreen extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  Future<void> _saveUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final updatedData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
      };

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updatedData);

      // Update Local Database (SQLite)
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
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () async {
              if (isEditing) {
                await _saveUserData();
              }
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildEditableField(
              "Full Name",
              "Enter your name",
              nameController,
              isEditing,
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              "Email",
              "Enter your email",
              emailController,
              isEditing,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              "Phone Number",
              "Enter your phone number",
              phoneController,
              isEditing,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              "New Password",
              "Enter new password",
              passwordController,
              isEditing,
              obscureText: true,
            ),
            const SizedBox(height: 32),
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
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
      String label,
      String hint,
      TextEditingController controller,
      bool isEditable, {
        TextInputType keyboardType = TextInputType.text,
        bool obscureText = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: controller,
          enabled: isEditable,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
