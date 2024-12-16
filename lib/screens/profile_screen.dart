import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildEditableField(
              "Full Name",
              "Enter your name",
              nameController,
              isEditing,
            ),
            SizedBox(height: 16),
            buildEditableField(
              "Email",
              "Enter your email",
              emailController,
              isEditing,
            ),
            SizedBox(height: 16),
            buildEditableField(
              "Phone Number",
              "Enter your phone number",
              phoneController,
              isEditing,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 32),

            // Notification Settings
            buildOptionTile(
              icon: Icons.notifications,
              title: "Notification Settings",
              subtitle: "Manage your notifications preferences",
            ),

            // User's Created Events
            buildOptionTile(
              icon: Icons.event,
              title: "My Events",
              subtitle: "View and manage your created events",
            ),

            // Associated Gifts
            buildOptionTile(
              icon: Icons.card_giftcard,
              title: "Associated Gifts",
              subtitle: "View gifts linked to your events",
            ),

            // Link to My Pledged Gifts
            buildOptionTile(
              icon: Icons.favorite,
              title: "My Pledged Gifts",
              subtitle: "See gifts you pledged for others",
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEditableField(
      String label,
      String hint,
      TextEditingController controller,
      bool isEditing, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: controller,
          enabled: isEditing,
          keyboardType: keyboardType,
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

  Widget buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
