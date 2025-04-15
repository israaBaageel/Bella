import 'package:test/models/message.dart';

class Chat {
  String? id;
  List<String> participants;
  List<Message>? messages;
  bool isGroup;
  String? groupName;
  String? groupImageUrl;
  String? lastMessage;

  Chat({
    required this.id,
    required this.participants,
    required this.messages,
    this.isGroup = false,
    this.groupName,
    this.groupImageUrl,
    this.lastMessage,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      participants: List<String>.from(json['participants']),
      messages:
          json['messages'] != null
              ? List<Message>.from(
                json['messages'].map((m) => Message.fromJson(m)),
              )
              : null,
      isGroup: json['isGroup'] ?? false,
      groupName: json['groupName'],
      groupImageUrl: json['groupImage'],
      lastMessage: json['lastMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'messages': messages?.map((m) => m.toJson()).toList(),
      'isGroup': isGroup,
      'groupName': groupName,
      'groupImage': groupImageUrl,
      'lastMessage': lastMessage,
    };
  }
}
