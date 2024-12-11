import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yarb/screens/event_list_screen.dart';
import 'package:yarb/screens/gift_list_screen.dart';
import 'package:yarb/screens/home_screen.dart';
import 'package:yarb/widgets/main_drawer.dart';
import 'package:yarb/screens/pledged_gifts_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

final user = FirebaseAuth.instance.currentUser;


class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;


  // Define the pages with their titles
  final Map<int, Widget> pages = {
    0: const HomeScreen(),
    1: const EventListScreen(),
    2: const PledgedGiftsScreen(), 
  };

  final List<String> titles = [
    'Home Page',
    'Events List',
    'Pledged Gifts',
  ];

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedPageIndex]), // Display title based on selected page
      ),
      drawer: const MainDrawer(), // Add the Drawer here
      body: pages[_selectedPageIndex] ?? const SizedBox(), // Display the active page
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
            label: 'Pledged Gifts',
          ),
        ],
      ),
    );
  }
}
