import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'events/event_list_screen.dart';
import 'gifts/pledged_gifts_screen.dart';
import '../widgets/main_drawer.dart';

class TabsScreen extends StatefulWidget {
  final int initialPageIndex;

  const TabsScreen({super.key, this.initialPageIndex = 0});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;

  final Map<int, Widget> pages = {
    0: const HomeScreen(),
    1: const EventListScreen(),
    2: const PledgedGiftsScreen(),
  };

  final List<String> titles = [
    'Home Page',
    'My Events List',
    'Pledged Gifts',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPageIndex = widget.initialPageIndex;
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedPageIndex]),
      ),
      drawer: const MainDrawer(),
      body: pages[_selectedPageIndex] ?? const SizedBox(),
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
