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

  final List<Widget> pages = [
    const HomeScreen(key: Key('homePage')),
    const EventListScreen(key: Key('eventListPage')),
    const PledgedGiftsScreen(key: Key('pledgedGiftsPage')),
  ];

  final List<String> titles = [
    'Home',
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
      key: const Key('tabsScreen'),
      appBar: AppBar(
        title: Text(
          titles[_selectedPageIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 5,
        backgroundColor: Colors.teal.shade800,
      ),
      drawer: const MainDrawer(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: pages[_selectedPageIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        key: const Key("bottomNavigationBar"),
        currentIndex: _selectedPageIndex,
        onTap: _selectPage,
        selectedItemColor: Colors.teal.shade800,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            key: Key("HomeTab"),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            key: Key("EventsTab"),
            icon: Icon(Icons.event_outlined),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            key: Key("PledgedGiftsTab"),
            icon: Icon(Icons.card_giftcard_outlined),
            label: 'Pledged Gifts',
          ),
        ],
      ),
    );
  }
}
