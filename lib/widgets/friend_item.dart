import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  int upcomingEventsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUpcomingEvents();
  }

  Future<void> _fetchUpcomingEvents() async {
    try {
      DateTime now = DateTime.now();
      String currentDate = DateFormat('yyyy-MM-dd').format(now);

      var eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('user_id', isEqualTo: widget.friendFirestoreId)
          .get();

      setState(() {
        upcomingEventsCount = eventsSnapshot.docs.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        upcomingEventsCount = 0;
        _isLoading = false;
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
          backgroundImage: const AssetImage('assets/avatar.jpg'),
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
          child: _isLoading
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
          icon: const Icon(Icons.person_add, color: Colors.white, size: 18),
          label: const Text(
            "Add",
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
