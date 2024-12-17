import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/profile_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.teal.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: user?.photoURL != null
                      ? ClipOval(
                    child: Image.network(
                      user!.photoURL!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Text(
                    user?.displayName?.substring(0, 1) ?? 'G',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Guest',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? 'Not logged in',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu Options
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          const Divider(height: 1, thickness: 1, color: Colors.grey),

          _buildDrawerItem(
            icon: Icons.exit_to_app,
            title: 'Logout',
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.teal.shade800,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
      ),
      onTap: onTap,
    );
  }
}
