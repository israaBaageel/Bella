import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test/models/user_profile.dart';
import 'package:test/pages/chat_page.dart';
import 'package:test/pages/messagePage.dart';
import 'package:test/services/database_service.dart';
import 'package:test/services/media_service.dart';
import 'package:test/services/cloudinary_service.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final GetIt _getIt = GetIt.instance;

  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late CloudinaryService _cloudinaryService;

  List<UserProfile> selectedUsers = [];
  File? _groupImage;
  String? _groupImageUrl;
  TextEditingController _groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _cloudinaryService = _getIt.get<CloudinaryService>();
  }

  Future<void> _pickGroupImage() async {
    final file = await _mediaService.getImageFromGallery();
    if (file != null) {
      setState(() => _groupImage = file);
      final url = await _cloudinaryService.uploadToCloudinary(file);
      if (url != null) {
        setState(() => _groupImageUrl = url);
        print("Uploaded image URL: $_groupImageUrl"); // Debugging: Check if URL is valid.
      } else {
      print("Failed to upload image.");
    }
    }
  }

Future<void> _createGroup() async {
  final name = _groupNameController.text.trim();
  if (name.isEmpty || selectedUsers.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please provide a group name and select members")),
    );
    return;
  }

  final uidList = selectedUsers.map((u) => u.uid!).toList();
  final groupId = await _databaseService.createGroupChat(
    participantIDs: uidList,
    groupName: name,
    groupImageUrl: _groupImageUrl,
  );

  if (groupId != null) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MessagePage(),
      ),
    );
  }
}


  void _viewGroupMembers() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        children: selectedUsers.map((user) => ListTile(
          leading: CircleAvatar(child: Text(user.name![0])),
          title: Text(user.name!),
          trailing: IconButton(
            icon: Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () {
              setState(() => selectedUsers.remove(user));
              
              Navigator.pop(context);
              _viewGroupMembers();
            },
          ),
        )).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Group"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _createGroup,
          )
        ],
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: _pickGroupImage,
            child: CircleAvatar(
              radius: 40,
              backgroundImage:
                  _groupImageUrl != null
                   ? NetworkImage(_groupImageUrl!)
                    : null,
              child: _groupImageUrl == null ? Icon(Icons.camera_alt) : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _groupNameController,
              decoration: InputDecoration(labelText: "Group Name"),
            ),
          ),
          TextButton.icon(
            onPressed: _viewGroupMembers,
            icon: Icon(Icons.group),
            label: Text("View Members (${selectedUsers.length})"),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _databaseService.getUsersProfiles(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!.docs.map((doc) => doc.data()).toList();
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isSelected = selectedUsers.contains(user);
                    return ListTile(
                      leading: CircleAvatar(child: Text(user.name![0])),
                      title: Text(user.name!),
                      trailing: isSelected ? Icon(Icons.check_circle) : null,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedUsers.remove(user);
                          } else {
                            selectedUsers.add(user);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
