import 'package:flutter/material.dart';

class GiftListScreen extends StatelessWidget {
  const GiftListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift List'),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: 10, // Replace with actual gift list count.
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text('Gift ${index + 1}'),
              subtitle: Text('Category: Electronics'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      // Navigate to edit gift page.
                      Navigator.pushNamed(context, '/editGift', arguments: index);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Confirm and delete gift logic.
                      _confirmDelete(context, index);
                    },
                  ),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(context, '/giftDetails', arguments: index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add gift page.
          Navigator.pushNamed(context, '/addGift');
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Confirmation dialog for deleting a gift.
  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Gift'),
          content: Text('Are you sure you want to delete Gift ${index + 1}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog.
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Delete gift logic here.
                Navigator.of(context).pop(); // Dismiss the dialog.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gift ${index + 1} deleted')),
                );
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
