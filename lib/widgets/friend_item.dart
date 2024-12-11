import 'package:flutter/material.dart';

class FriendListItem extends StatelessWidget {
  final String friendName;
  final int index;
  final void Function() onTap;
  final void Function()? onAddFriend; // Nullable to conditionally show/hide
  final bool isFriend; // New property to determine if the user is already a friend

  const FriendListItem({
    super.key,
    required this.friendName,
    required this.index,
    required this.onTap,
    this.onAddFriend,
    required this.isFriend,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: const AssetImage('assets/avatar.jpg'), // Replace with actual image path
      ),
      title: Text(friendName),
      subtitle: Text(index % 2 == 0
          ? 'Upcoming Events: ${index + 1}'
          : 'No Upcoming Events'),
      trailing: Wrap(
        spacing: 12, // Space between two icons
        children: <Widget>[
          if (!isFriend) // Show Add Friend icon only if not already a friend
            GestureDetector(
              onTap: onAddFriend,
              child: const Icon(Icons.person_add, color: Colors.teal),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
