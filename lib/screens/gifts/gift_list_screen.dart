import 'dart:convert';
import 'dart:typed_data';
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
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    _fetchGifts();
  }

  void _fetchGifts() {
    try {
      setState(() {
        _giftsStream = FirebaseFirestore.instance
            .collection('gifts')
            .where('event_id', isEqualTo: widget.eventId)
            .snapshots();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching gifts: $e')),
      );
    }
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
      key: const Key("giftListPage"),
      appBar: AppBar(
        title: Text("${widget.eventName}'s Gift List"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildSortDropdown(),
          ),
        ],
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

            final sortedGifts = _sortGifts(snapshot.data!.docs);

            return ListView.builder(
              itemCount: sortedGifts.length,
              itemBuilder: (context, index) {
                final gift = sortedGifts[index];
                return _buildGiftCard(gift);
              },
            );
          },
        ),
      ),
      floatingActionButton: widget.canEdit
          ? FloatingActionButton.extended(
              key: const Key("addGiftButton"),
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

    // Decode the gift image if available
    Uint8List? giftImageBytes;
    if (giftData['gift_image'] != null && giftData['gift_image'].isNotEmpty) {
      try {
        giftImageBytes = base64Decode(giftData['gift_image']);
      } catch (e) {
        debugPrint('Error decoding gift image: $e');
      }
    }

    // Determine card color based on pledge status
    final isPledged = (giftData['status'] ?? 'available') == 'pledged';
    final cardColor = isPledged ? Colors.orange.shade100 : Colors.teal.shade50;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        color: cardColor, // Apply the color based on pledge status
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
                  canEdit: widget.canEdit && !isPledged,
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
              backgroundImage: giftImageBytes != null
                  ? MemoryImage(giftImageBytes)
                  : const AssetImage('assets/avatar.jpg')
                      as ImageProvider,
            ),
            title: Text(
              giftData['name'],
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
                    value: giftData['category'] ?? 'N/A',
                  ),
                  _buildInfoRow(
                    icon: Icons.monetization_on,
                    label: "Price",
                    value: "\$${(giftData['price'] ?? 0.0).toStringAsFixed(2)}",
                  ),
                  _buildInfoRow(
                    icon: Icons.check_circle_outline,
                    label: "Status",
                    value: giftData['status'] ?? 'N/A',
                  ),
                ],
              ),
            ),
            trailing: widget.canEdit && !isPledged
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

  Widget _buildSortDropdown() {
    return DropdownButton<String>(
      value: _sortBy,
      dropdownColor: Colors.teal,
      icon: const Icon(Icons.sort, color: Colors.white),
      underline: const SizedBox(),
      style: const TextStyle(color: Colors.white, fontSize: 16),
      items: const [
        DropdownMenuItem(
          value: 'name',
          child: Text("Sort by Name"),
        ),
        DropdownMenuItem(
          value: 'category',
          child: Text("Sort by Category"),
        ),
        DropdownMenuItem(
          value: 'price',
          child: Text("Sort by Price"),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _sortBy = value!;
          _fetchGifts(); // Re-fetch gifts with the updated sorting
        });
      },
    );
  }

  List<DocumentSnapshot> _sortGifts(List<DocumentSnapshot> gifts) {
    List<DocumentSnapshot> sortedGifts = List<DocumentSnapshot>.from(gifts);

    sortedGifts.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      if (_sortBy == 'price') {
        return (aData['price'] ?? 0).compareTo(bData['price'] ?? 0);
      } else if (_sortBy == 'category') {
        return (aData['category'] ?? '').toString().compareTo(
              (bData['category'] ?? '').toString(),
            );
      } else {
        // Default: Sort by name
        return (aData['name'] ?? '').toString().compareTo(
              (bData['name'] ?? '').toString(),
            );
      }
    });

    return sortedGifts;
  }
}
