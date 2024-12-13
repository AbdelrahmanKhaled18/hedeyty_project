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
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: const AssetImage('assets/avatar.jpg'),
      ),
      title: Text(widget.friendName),
      subtitle: _isLoading
          ? const Text('Loading events...')
          : Text(upcomingEventsCount > 0
          ? 'Upcoming Events: $upcomingEventsCount'
          : 'No Upcoming Events'),
      trailing: widget.isFriend
          ? null
          : IconButton(
        icon: const Icon(Icons.person_add, color: Colors.teal),
        onPressed: widget.onAddFriend,
      ),
      onTap: widget.onTap,
    );
  }
}