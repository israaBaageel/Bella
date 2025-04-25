import 'dart:typed_data'; // Explicitly import typed_data
import 'dart:convert';
import 'dart:io';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test/models/chat.dart';

class Gemichat extends StatefulWidget {
  const Gemichat({super.key});

  @override
  State<Gemichat> createState() => _GemichatState();
}

class _GemichatState extends State<Gemichat> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  ChatUser currentUser = ChatUser(id: "0", firstName: "sos");
  ChatUser giminiUser = ChatUser(id: "1", firstName: "Gemini");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Fashion Assistant")),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      messageOptions: MessageOptions(
          currentUserContainerColor: Colors.pinkAccent,
            containerColor: const Color.fromARGB(255, 209, 195, 195),
            textColor: Colors.black,
            currentUserTextColor: Colors.white,
      ),
      inputOptions: InputOptions(
       // trailing: [IconButton(onPressed: _sendImageMessage, icon: Icon(Icons.image))],
      ),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages.insert(0, chatMessage);
    });

    // Process image if available
    List<Uint8List>? images;
    if (chatMessage.medias?.isNotEmpty ?? false) {
      // Convert image file to Uint8List
      images = [File(chatMessage.medias!.first.url).readAsBytesSync()];
    }

    String question = chatMessage.text!;
    StringBuffer buffer = StringBuffer();

    // Create a "typing" message from Gemini
    ChatMessage typingMsg = ChatMessage(
      user: giminiUser,
      createdAt: DateTime.now(),
      text: '',
    );

    setState(() {
      messages.insert(0, typingMsg);
    });

    gemini.promptStream(parts: [Part.text(question)]).listen(
      (event) {
        // Append only TextParts
        final textParts = event?.content?.parts?.whereType<TextPart>() ?? [];
        for (final part in textParts) {
          buffer.write(part.text);
        }

        setState(() {
          typingMsg.text = buffer.toString();
        });
      },
      onDone: () {
        // You could optionally replace typing message with a final version here
      },
      onError: (error) {
        print("Gemini error: $error");

        setState(() {
          messages.insert(
            0,
            ChatMessage(
              user: giminiUser,
              createdAt: DateTime.now(),
              text: "Oops! Something went wrong.",
            ),
          );
        });
      },
    );
  }

  void _sendImageMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      // Create the image message
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "how can i style this item",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "fileName",
            type: MediaType.image,
          ),
        ],
      );
      // Send the image message
      _sendMessage(chatMessage);
    }
  }
}
