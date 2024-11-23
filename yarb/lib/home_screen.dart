import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hedieaty Home'),
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create Event/List Button
            ElevatedButton(
              onPressed: () {
                // Navigate to Create Event/List Page
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Center(
                child: Text(
                  'Create Your Own Event/List',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for friends or gift lists',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // List of Friends
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Replace with the actual number of friends
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/profile_placeholder.png'), // Replace with actual image path
                    ),
                    title: Text('Friend Name $index'),
                    subtitle: Text(index % 2 == 0
                        ? 'Upcoming Events: ${index + 1}'
                        : 'No Upcoming Events'),
                    trailing: Icon(Icons.chevron_right, color: Colors.teal),
                    onTap: () {
                      // Navigate to friend's gift list
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
