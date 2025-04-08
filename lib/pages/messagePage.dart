import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test/Widgets/chat_tile.dart';
import 'package:test/models/chat.dart';
import 'package:test/models/user_profile.dart';
import 'package:test/pages/chat_page.dart';
import 'package:test/pages/group_chat.dart';
import 'package:test/services/auth_service.dart';
import 'package:test/services/database_service.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _ChatpageState();
}

class _ChatpageState extends State<MessagePage> {
  final GetIt _getIt = GetIt.instance;
  late DatabaseService _databaseService;
  late AuthService _authService;
  
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _databaseService = _getIt.get<DatabaseService>();
    _authService = _getIt.get<AuthService>();
  }

  void onSearch() async {
    if (_searchController.text.isEmpty) return;
    
    setState(() => isLoading = true);
    
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where("email", isEqualTo: _searchController.text.trim())
          .limit(1)
          .get();

      setState(() {
        userMap = query.docs.isEmpty ? null : query.docs.first.data();
        isLoading = false;
      });

      if (userMap == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user found')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void clearSearch() {
    setState(() {
      _searchController.clear();
      userMap = null;
      isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching 
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "Search by email",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
              )
            : const Text('Messages'),
        actions: [
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.group_add),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateGroupPage()),
              ),
            ),
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              if (isSearching) {
                clearSearch();
              } else {
                setState(() => isSearching = true);
              }
            },
          ),
        ],
      ),
      
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: SafeArea(
          child: Column(
            children: [
              if (isSearching) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Enter email",
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: onSearch,
                            ),
                          ),
                          onSubmitted: (_) => onSearch(),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const LinearProgressIndicator()
                else if (userMap != null)
                  _buildSearchResult(userMap!),
                const Divider(height: 1),
              ],
              Expanded(
                child: _buildChatList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResult(Map<String, dynamic> userData) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userData['pfpURL'] ?? ''),
      ),
      title: Text(userData['name'] ?? 'Unknown'),
      subtitle: Text(userData['email'] ?? ''),
      trailing: IconButton(
        icon: const Icon(Icons.chat),
        onPressed: () => _startChat(userData),
      ),
      onTap: () => _startChat(userData),
    );
  }

  Future<void> _startChat(Map<String, dynamic> userData) async {
    final currentUserId = _authService.user!.uid;
    final otherUserId = userData['uid'];
    
    try {
      // Check if chat exists
      final chatExists = await _databaseService.checkChatExists(
        currentUserId, 
        otherUserId,
      );
      
      if (!chatExists) {
        await _databaseService.createNewChat(currentUserId, otherUserId);
      }
      
      // Navigate to chat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            chatUser: UserProfile.fromJson(userData),
          ),
        ),
      );
      
      clearSearch();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting chat: $e')),
      );
    }
  }

  Widget _buildChatList() {
    return StreamBuilder<QuerySnapshot<Chat>>(
      stream: _databaseService.getUserChats(_authService.user!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('No chats yet'),
                Text('Search for users to start chatting'),
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final chatDoc = snapshot.data!.docs[index];
            final chat = chatDoc.data();
            
            if (chat.isGroup == true) {
              return _buildGroupChatItem(chat);
            }
            
            return FutureBuilder<UserProfile>(
              future: _getOtherUserProfile(chat.participants),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState != ConnectionState.done) {
                  return const ListTile(
                    leading: CircleAvatar(),
                    title: Text('Loading...'),
                  );
                }
                
                if (!userSnapshot.hasData) {
                  return const ListTile(
                    leading: CircleAvatar(),
                    title: Text('Unknown user'),
                  );
                }
                
                final user = userSnapshot.data!;
                return ChatTile(
                  userProfile: user,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(chatUser: user),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<UserProfile> _getOtherUserProfile(List<String> participants) async {
    final otherUserId = participants.firstWhere(
      (id) => id != _authService.user!.uid,
    );
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .get();
    return UserProfile.fromJson(userDoc.data()!);
  }

  Widget _buildGroupChatItem(Chat chat) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.group)),
      title: Text(chat.groupName ?? 'Group Chat'),
      subtitle: Text(chat.lastMessage ?? ''),
      onTap: () {
        // Navigate to group chat
      },
    );
  }
}