import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yarb/event_list.dart';
import 'package:yarb/home_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

final user=FirebaseAuth.instance.currentUser;

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define the active page based on the selected index
    final List<Widget> pages = [
      const HomeScreen(),
      const EventListScreen(),
      const Center(child: Text('Gifts List Placeholder')), // Placeholder for Gifts List screen
    ];

    return Scaffold(
      body: pages[_selectedPageIndex], // Display the active page
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Gifts List',
          ),
        ],
      ),
    );
  }
}
