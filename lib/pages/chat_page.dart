import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test/models/chat.dart';
import 'package:test/models/message.dart';
import 'package:test/models/user_profile.dart';
import 'package:test/services/auth_service.dart';
import 'package:test/services/cloudinary_service.dart';
import 'package:test/services/database_service.dart';
import 'package:test/services/media_service.dart';

import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;
  //g

  const ChatPage({super.key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isUploading = false;
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late AppDatabaseService _databaseService;
  late MediaService _mediaService;
  late CloudinaryService _cloudinaryService;
  ChatUser? currentUser, otherUser;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<AppDatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _cloudinaryService = _getIt.get<CloudinaryService>();
    currentUser = ChatUser(
      id: _authService.user!.uid,
      firstName: _authService.user!.displayName,
    );
    otherUser = ChatUser(
      id: widget.chatUser.uid!,
      firstName: widget.chatUser.name,
    );
    //pfp url
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chatUser.name!)),
      body: Stack(
        children: [
          _buildUI(),
          if (isUploading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
      stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
      builder: (context, snapshot) {
        Chat? chat = snapshot.data?.data();
        List<ChatMessage> messages = [];
        if (chat != null && chat.messages != null) {
          messages = _generateChatMessagesList(chat.messages!);
        }
        return DashChat(
          messageOptions: MessageOptions(
            showOtherUsersAvatar: true,
            showTime: true,
            currentUserContainerColor: Colors.blue,
            containerColor: Colors.green,
            textColor: Colors.white,
            currentUserTextColor: Colors.white,
            messageMediaBuilder: (
              ChatMessage message,
              ChatMessage? previousMessage,
              ChatMessage? nextMessage,
            ) {
              if (message.medias != null && message.medias!.isNotEmpty) {
                final media = message.medias!.first;
                return Column(
                  crossAxisAlignment:
                      message.user == currentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => Scaffold(
                                  backgroundColor: Colors.black,
                                  appBar: AppBar(
                                    backgroundColor: Colors.black,
                                    iconTheme: IconThemeData(
                                      color: Colors.white,
                                    ),
                                  ),
                                  body: Center(
                                    child: InteractiveViewer(
                                      child: Image.network(media.url),
                                    ),
                                  ),
                                ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          media.url,
                          width: MediaQuery.of(context).size.width * 0.6,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: 200,
                              color: Colors.grey[300],
                              child: Icon(Icons.error, color: Colors.red),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('hh:mm a').format(message.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                );
              }
              return Container();
            },
          ),
          inputOptions: InputOptions(
            sendButtonBuilder: defaultSendButton(
              color: Colors.pinkAccent,
              //disabledColor: Colors.grey,
            ),
            alwaysShowSend: true,
            trailing: [_mediaMessageButton()],
          ),
          currentUser: currentUser!,
          onSend: _sendMessage,
          messages: messages,
        );
      },
    );
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    Message message = Message(
      senderID: currentUser!.id,
      content: chatMessage.text,
      messageType: MessageType.Text,
      sentAt: Timestamp.fromDate(chatMessage.createdAt),
    );
    await _databaseService.sendChatMessage(
      currentUser!.id,
      otherUser!.id,
      message,
    );
  }

  Future<void> _sendImageMessage(File imageFile) async {
    try {
      setState(() => isUploading = true);

      // Upload image to Cloudinary
      String? imageUrl = await _cloudinaryService.uploadToCloudinary(imageFile);

      // Create image message
      Message message = Message(
        senderID: currentUser!.id,
        content: imageUrl,
        messageType: MessageType.Image,
        sentAt: Timestamp.now(),
      );

      // Save to Firestore
      await _databaseService.sendChatMessage(
        currentUser!.id,
        otherUser!.id,
        message,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send image: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() => isUploading = false);
      }
    }
  }

  List<ChatMessage> _generateChatMessagesList(List<Message> messages) {
    List<ChatMessage> chatMessages =
        messages.map((m) {
          if (m.messageType == MessageType.Image) {
            return ChatMessage(
              user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
              createdAt: m.sentAt!.toDate(),
              medias: [
                ChatMedia(url: m.content!, fileName: "", type: MediaType.image),
              ],
            );
          } else {
            return ChatMessage(
              user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
              text: m.content!,
              createdAt: m.sentAt!.toDate(),
            );
          }
        }).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }

  Widget _mediaMessageButton() {
    return IconButton(
      onPressed: () async {
        File? file = await _mediaService.getImageFromGallery();
        await _sendImageMessage(file!); /////////
      },
      icon: Icon(Icons.image, color: Colors.pinkAccent),
    );
  }
}
