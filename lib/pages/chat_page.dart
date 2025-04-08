import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatview/chatview.dart' as cv;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test/models/chat.dart';
import 'package:test/models/message.dart' as local_models;
import 'package:test/models/user_profile.dart';
import 'package:test/services/auth_service.dart';
import 'package:test/services/cloudinary_service.dart';
import 'package:test/services/database_service.dart';
import 'package:test/services/media_service.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;

  const ChatPage({super.key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isUploading = false;
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late CloudinaryService _cloudinaryService;
  
late cv.ChatController _messageController;

late cv.ChatUser _currentUser;

@override
void initState() {
  super.initState();
  _initializeServices();
  _setupCurrentUserAndController();
}


  void _initializeServices() {
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _cloudinaryService = _getIt.get<CloudinaryService>();
  }

void _setupCurrentUserAndController() {
  final user = _authService.user!;
  _currentUser = cv.ChatUser(
    id: user.uid,
    name: user.displayName ?? 'You',
    profilePhoto: user.photoURL ?? '',
  );
   


  _messageController = cv.ChatController(
    initialMessageList: [],
    scrollController: ScrollController(),
    otherUsers: [
      cv.ChatUser(
        id: widget.chatUser.uid!,
        name: widget.chatUser.name ?? 'User',
        profilePhoto: widget.chatUser.pfpURL ?? '',
      ),
    ],
    currentUser: _currentUser,
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildChatBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          if (widget.chatUser.pfpURL != null)
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chatUser.pfpURL!),
              radius: 16,
            ),
          const SizedBox(width: 10),
          Text(widget.chatUser.name!),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showChatInfo(),
        ),
      ],
    );
  }

  Widget _buildChatBody() {
    return Stack(
      children: [
        _buildChatView(),
        if (isUploading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildChatView() {
    return StreamBuilder(
      stream: _databaseService.getChatData(
        _currentUser.id,
        widget.chatUser.uid!,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final chat = snapshot.data?.data();
        final messages =
            chat?.messages != null
                ? _convertToChatViewMessages(chat!.messages!)
                : <cv.Message>[];

        _messageController.initialMessageList
          ..clear()
          ..addAll(messages);

        return cv.ChatView(
          chatController: _messageController,
          onSendTap: _handleSendMessage,
          chatViewState:
              messages.isNotEmpty
                  ? cv.ChatViewState.hasMessages
                  : cv.ChatViewState.noData,
          featureActiveConfig: const cv.FeatureActiveConfig(
            lastSeenAgoBuilderVisibility: true,
    receiptsBuilderVisibility: true,
    enableReplySnackBar: true,
  ),
  chatBackgroundConfig: cv.ChatBackgroundConfiguration(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  ),
  sendMessageConfig: cv.SendMessageConfiguration(
    textFieldConfig: cv.TextFieldConfiguration(
     // onMessageTyping: _handleTypingStatus,
     // composeButtonIcon: Icons.send,
      textStyle: Theme.of(context).textTheme.bodyMedium,
    ),
    defaultSendButtonColor: Theme.of(context).primaryColor,
    replyDialogColor: Theme.of(context).primaryColor.withValues(),
  ),
  messageConfig: cv.MessageConfiguration(
    imageMessageConfig: const cv.ImageMessageConfiguration(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
    ),

  ),
  loadMoreData: _loadMoreMessages,
  repliedMessageConfig: cv.RepliedMessageConfiguration(
    backgroundColor: Theme.of(context).primaryColor.withValues(),
    verticalBarColor: Theme.of(context).primaryColor,
  ),

  profileCircleConfig: const cv.ProfileCircleConfiguration(
    //profileImageRadius: 16,
  ),
);

      },
    );
  }

List<cv.Message> _convertToChatViewMessages(List<local_models.Message> messages) {
  return messages.map((msg) {
    return cv.Message(
      id: msg.sentAt?.millisecondsSinceEpoch.toString() ?? 
          DateTime.now().millisecondsSinceEpoch.toString(),
      message: msg.content ?? '',
      createdAt: msg.sentAt?.toDate() ?? DateTime.now(),
      sentBy: msg.senderID == _currentUser.id 
          ? _currentUser.id
          : widget.chatUser.uid!,
      //replyMessage: const cv.ReplyMessage(),
     // reaction: _buildDefaultReactions(),
      messageType: msg.messageType == local_models.MessageType.Image 
          ? cv.MessageType.image 
          : cv.MessageType.text,
      // Remove profilePhoto parameter if it's no longer valid
    );
  }).toList();
}


  Future<void> _handleSendMessage(
    String message, 
    cv.ReplyMessage? replyMessage, 
    cv.MessageType messageType,
  ) async {
    final firestoreMessage = local_models.Message(
      senderID: _currentUser.id,
      content: message,
      messageType: messageType == cv.MessageType.image 
          ? local_models.MessageType.Image 
          : local_models.MessageType.Text,
      sentAt: Timestamp.now(),
    );
    
    await _databaseService.sendChatMessage(
      _currentUser.id,
      widget.chatUser.uid!,
      firestoreMessage,
    );
    
  }

Future<List<cv.Message>> _loadMoreMessages() async {
  // Implement pagination or load more logic here.
  return [];
}


List<String> _buildDefaultReactions() {
  return ['❤️', '👍', '😂', '😮', '😢', '😡'];
}


  // void _handleTypingStatus(cv.TypingIndicator typingIndicator) {
  //   // Handle typing status updates
  // }

  Future<void> _showChatInfo() async {
    // Show chat info dialog
    
  }

  Future<void> _sendImageMessage(File imageFile) async {
    try {
      setState(() => isUploading = true);
      final imageUrl = await _cloudinaryService.uploadToCloudinary(imageFile);
      if (imageUrl != null) {
        await _handleSendMessage(imageUrl, null, cv.MessageType.image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send image: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => isUploading = false);
      }
    }
  }
}