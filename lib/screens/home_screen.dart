import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../database/DAO/friend_dao.dart';
import '../database/database_helper.dart';
import '../database/models/friend.dart';
import '../widgets/friend_item.dart';
import 'events/event_creation.dart';
import 'events/event_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> friendsList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_handleFocusChange);
    _fetchFriends();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() => searchResults = []);
    } else {
      searchUsers(_searchController.text);
    }
  }

  void _handleFocusChange() {
    if (!_searchFocusNode.hasFocus) {
      setState(() {
        searchResults = [];
        _searchController.clear();
      });
    }
  }

  Future<void> _fetchFriends() async {
    setState(() => _isLoading = true);
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      var friendsSnapshot = await FirebaseFirestore.instance
          .collection('friends')
          .where('user_ids', arrayContains: userId)
          .get();

      List<Map<String, dynamic>> fetchedFriends = [];

      for (var doc in friendsSnapshot.docs) {
        List<dynamic> userIds = doc['user_ids'];
        String friendId = userIds.firstWhere((id) => id != userId);

        var friendData = await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .get();

        if (friendData.exists) {
          fetchedFriends.add({
            'id': friendData.id,
            ...friendData.data()!,
          });
        }
      }

      setState(() {
        friendsList = fetchedFriends;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch friends: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> searchUsers(String query) async {
    var collection = FirebaseFirestore.instance.collection('users');
    var snapshot = await collection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    setState(() {
      searchResults =
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()!}).toList();
    });
  }

  Future<void> _addFriend(String friendFirestoreId) async {
    setState(() => _isLoading = true);

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Check if already friends
      var existingFriendSnapshot = await FirebaseFirestore.instance
          .collection('friends')
          .where('user_ids', arrayContains: userId)
          .get();

      bool alreadyFriends = existingFriendSnapshot.docs.any((doc) {
        List<dynamic> userIds = doc['user_ids'];
        return userIds.contains(friendFirestoreId);
      });

      if (alreadyFriends) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend already added')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Add to Firestore
      await FirebaseFirestore.instance.collection('friends').add({
        'user_ids': [userId, friendFirestoreId],
      });
      // Add to Local Database
      int localUserId = await getLocalIdForFirestoreId(userId);
      int localFriendId = await getLocalIdForFirestoreId(friendFirestoreId);

      Friend newFriend = Friend(userId: localUserId, friendId: localFriendId);
      await FriendDAO().insertFriend(newFriend);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend added successfully')),
      );

      await _fetchFriends();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add friend: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<int> getLocalIdForFirestoreId(String firestoreId) async {
    final db = await DatabaseHelper().database;
    var result = await db.query(
      'users',
      where: 'firestore_id = ?',
      whereArgs: [firestoreId],
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int; // Return the local database ID
    }
    throw Exception('Local ID not found for Firestore ID: $firestoreId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: searchUsers,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              hintText: 'Search for friends...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Friends List
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: _searchController.text.isEmpty && friendsList.isEmpty
                ? const Center(
              child: Text(
                'No friends found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              itemCount: _searchController.text.isEmpty
                  ? friendsList.length
                  : searchResults.length,
              itemBuilder: (context, index) {
                var user = _searchController.text.isEmpty
                    ? friendsList[index]
                    : searchResults[index];
                bool isFriend = friendsList
                    .any((friend) => friend['id'] == user['id']);

                return FriendListItem(
                  friendName: user['name'],
                  friendFirestoreId: user['id'],
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration:
                        const Duration(milliseconds: 500),
                        pageBuilder: (context, animation,
                            secondaryAnimation) =>
                            EventListScreen(
                              friendId: user['id'],
                              friendName: user['name'],
                            ),
                        transitionsBuilder: (context, animation,
                            secondaryAnimation, child) {
                          const begin =
                          Offset(1.0, 0.0); // Slide from right
                          const end = Offset.zero; // Final position
                          const curve = Curves.easeInOut;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation =
                          animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  onAddFriend: isFriend
                      ? null
                      : () => _addFriend(user['id']),
                  isFriend: isFriend,
                );
              },
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventCreationPage()),
          );
        },
        label: const Text('Create Event'),
        icon: const Icon(Icons.event),
        backgroundColor: Colors.teal.shade800,
      ),
    );
  }
}
