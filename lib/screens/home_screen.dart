import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/DAO/friend_dao.dart';
import '../database/database_helper.dart';
import '../database/models/friend.dart';
import '../widgets/friend_item.dart';
import 'event_creation.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EventCreationPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Create Your Own Event/List',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
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
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _searchController.text.isEmpty && friendsList.isEmpty
                        ? const Center(
                            child: Text(
                              'No friends yet',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
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
                                onTap: () {},
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
      ),
    );
  }
}
