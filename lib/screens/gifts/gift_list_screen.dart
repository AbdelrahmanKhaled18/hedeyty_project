import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../database/database_helper.dart';
import 'gift_creation.dart';
import 'gift_details_edit.dart';

class GiftListScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final bool canEdit;

  const GiftListScreen({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.canEdit,
  });

  @override
  State<GiftListScreen> createState() => _GiftListScreenState();
}

class _GiftListScreenState extends State<GiftListScreen> {
  late Stream<QuerySnapshot> _giftsStream;

  @override
  void initState() {
    super.initState();
    _fetchGifts();
  }

  void _fetchGifts() {
    _giftsStream = FirebaseFirestore.instance
        .collection('gifts')
        .where('event_id', isEqualTo: widget.eventId)
        .snapshots();
  }

  Future<void> _deleteGift(String giftId) async {
    try {
      // Delete from Firestore
      await FirebaseFirestore.instance.collection('gifts').doc(giftId).delete();

      // Delete from local SQLite database
      final db = await DatabaseHelper().database;
      await db.delete(
        'gifts',
        where: 'firestore_id = ?',
        whereArgs: [giftId],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete gift: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.eventName}'s Gift List"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _giftsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No gifts found.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            final gifts = snapshot.data!.docs;

            return ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                return _buildGiftCard(gift);
              },
            );
          },
        ),
      ),
      floatingActionButton: widget.canEdit
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftCreationScreen(
                      firestoreEventId: widget.eventId,
                    ),
                  ),
                );
              },
              label: const Text("Add Gift"),
              icon: const Icon(Icons.add),
              backgroundColor: Colors.teal,
            )
          : null,
    );
  }

  Widget _buildGiftCard(DocumentSnapshot gift) {
    final giftData = gift.data() as Map<String, dynamic>;
    final friendFirestoreId = giftData['event_id'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GiftDetailsAndEditScreen(
                  giftId: gift.id,
                  canEdit: widget.canEdit,
                  friendFirestoreId: friendFirestoreId,
                ),
              ),
            );
          },
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.teal.shade100,
              child: Text(
                gift['name'].substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
            title: Text(
              gift['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    icon: Icons.category,
                    label: "Category",
                    value: gift['category'],
                  ),
                  _buildInfoRow(
                    icon: Icons.monetization_on,
                    label: "Price",
                    value: "\$${gift['price'].toStringAsFixed(2)}",
                  ),
                  _buildInfoRow(
                    icon: Icons.check_circle_outline,
                    label: "Status",
                    value: gift['status'],
                  ),
                ],
              ),
            ),
            trailing: widget.canEdit
                ? Wrap(
                    spacing: 8.0,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GiftDetailsAndEditScreen(
                                giftId: gift.id,
                                canEdit: true,
                                friendFirestoreId: friendFirestoreId,
                              ),
                            ),
                          );
                        },
                        tooltip: "Edit Gift",
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _confirmDelete(gift.id);
                        },
                        tooltip: "Delete Gift",
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String giftId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Gift'),
          content: const Text('Are you sure you want to delete this gift?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss the dialog
                await _deleteGift(giftId);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
