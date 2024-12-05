import 'package:flutter/material.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  // Sample list of events
  List<Map<String, dynamic>> events = [
    {'name': 'Birthday Party', 'category': 'Social', 'status': 'Upcoming'},
    {'name': 'Team Meeting', 'category': 'Work', 'status': 'Current'},
    {'name': 'Wedding', 'category': 'Family', 'status': 'Past'},
  ];

  String sortBy = 'name'; // Default sorting criterion

  void sortEvents(String criterion) {
    setState(() {
      sortBy = criterion;
      events.sort((a, b) => a[criterion].compareTo(b[criterion]));
    });
  }

  void addEvent(String name, String category, String status) {
    setState(() {
      events.add({'name': name, 'category': category, 'status': status});
    });
  }

  void editEvent(int index, String name, String category, String status) {
    setState(() {
      events[index] = {'name': name, 'category': category, 'status': status};
    });
  }

  void deleteEvent(int index) {
    setState(() {
      events.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom Top Bar for sorting
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Event List',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => sortEvents(value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
                    const PopupMenuItem(value: 'category', child: Text('Sort by Category')),
                    const PopupMenuItem(value: 'status', child: Text('Sort by Status')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  title: Text(event['name']),
                  subtitle: Text('${event['category']} - ${event['status']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditEventDialog(context, index, event);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          deleteEvent(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    String name = '';
    String category = '';
    String status = 'Upcoming';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Event Name'),
              onChanged: (value) => name = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (value) => category = value,
            ),
            DropdownButtonFormField<String>(
              value: status,
              items: ['Upcoming', 'Current', 'Past']
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ))
                  .toList(),
              onChanged: (value) => status = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              addEvent(name, category, status);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditEventDialog(
      BuildContext context, int index, Map<String, dynamic> event) {
    String name = event['name'];
    String category = event['category'];
    String status = event['status'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Event Name'),
              controller: TextEditingController(text: name),
              onChanged: (value) => name = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Category'),
              controller: TextEditingController(text: category),
              onChanged: (value) => category = value,
            ),
            DropdownButtonFormField<String>(
              value: status,
              items: ['Upcoming', 'Current', 'Past']
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ))
                  .toList(),
              onChanged: (value) => status = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              editEvent(index, name, category, status);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
