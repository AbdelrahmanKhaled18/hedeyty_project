import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

class FriendListItem extends StatefulWidget {
  final String friendName;
  final String friendFirestoreId;
  final void Function() onTap;
  final void Function()? onAddFriend;
  final bool isFriend;

  const FriendListItem({
    super.key,
    required this.friendName,
    required this.friendFirestoreId,
    required this.onTap,
    this.onAddFriend,
    required this.isFriend,
  });

  @override
  _FriendListItemState createState() => _FriendListItemState();
}

class _FriendListItemState extends State<FriendListItem> {
  Uint8List? profileImageBytes;
  int upcomingEventsCount = 0;
  bool _isLoadingEvents = true;
  bool _isLoadingImage = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileImage();
    _fetchUpcomingEvents();
  }

  Future<void> _fetchUserProfileImage() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.friendFirestoreId)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (data['profile_image'] != null && data['profile_image'].isNotEmpty) {
          setState(() {
            profileImageBytes = base64Decode(data['profile_image']);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile image: $e');
    } finally {
      setState(() {
        _isLoadingImage = false;
      });
    }
  }

  Future<void> _fetchUpcomingEvents() async {
    try {
      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('user_id', isEqualTo: widget.friendFirestoreId)
          .get();

      setState(() {
        upcomingEventsCount = eventsSnapshot.docs.length;
        _isLoadingEvents = false;
      });
    } catch (e) {
      setState(() {
        upcomingEventsCount = 0;
        _isLoadingEvents = false;
      });
      debugPrint('Error fetching events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.teal.shade100,
          backgroundImage: !_isLoadingImage && profileImageBytes != null
              ? MemoryImage(profileImageBytes!)
              : null,
          child: _isLoadingImage
              ? const CircularProgressIndicator(color: Colors.teal)
              : (profileImageBytes == null
                  ? Text(
                      widget.friendName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    )
                  : null),
        ),
        title: Text(
          widget.friendName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _isLoadingEvents
              ? const Text(
                  'Loading events...',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                )
              : Row(
                  children: [
                    const Icon(Icons.event, color: Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        upcomingEventsCount > 0
                            ? 'Upcoming Events: $upcomingEventsCount'
                            : 'No Upcoming Events',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
        trailing: widget.isFriend
            ? null
            : ElevatedButton.icon(
                icon:
                    const Icon(Icons.person_add, color: Colors.white, size: 18),
                label: const Text(
                  "Add",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: widget.onAddFriend,
              ),
        onTap: widget.onTap,
      ),
    );
  }
}
