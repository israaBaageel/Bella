import 'package:cloud_firestore/cloud_firestore.dart';

// models/group.dart
class Group {
  final String id;
  final String name;
  final String? imageUrl;
  final List<String> memberIds;
  final String createdBy;
  final Timestamp createdAt;
  final Timestamp? lastMessageAt;
  final String? lastMessage;

  Group({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.memberIds,
    required this.createdBy,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessage,
  });

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      memberIds: List<String>.from(map['memberIds']),
      createdBy: map['createdBy'],
      createdAt: map['createdAt'],
      lastMessageAt: map['lastMessageAt'],
      lastMessage: map['lastMessage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'memberIds': memberIds,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'lastMessageAt': lastMessageAt,
      'lastMessage': lastMessage,
    };
  }
}