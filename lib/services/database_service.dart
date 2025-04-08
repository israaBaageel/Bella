import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:test/models/chat.dart';
import 'package:test/models/message.dart';
import 'package:test/models/user_profile.dart';
import 'package:test/services/auth_service.dart';
import 'package:test/utils.dart';

class DatabaseService {
  final GetIt _getIt = GetIt.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  late AuthService _authService;


  CollectionReference? _usersCollection;
  CollectionReference? _chatsCollection;

  DatabaseService(){
    _authService = _getIt.get<AuthService>();
    _setupCollectionReferences();
  }

  void _setupCollectionReferences(){
    _usersCollection= _firebaseFirestore.collection('users').withConverter<UserProfile>(
      fromFirestore: (snapshots, _ ) => UserProfile.fromJson(snapshots.data()!,),
     toFirestore: (userProfile, _) => userProfile.toJson(),
     );

   _chatsCollection  = _firebaseFirestore.collection('chats').withConverter<Chat>(
      fromFirestore: (snapshots, _ ) => Chat.fromJson(snapshots.data()!),
     toFirestore: (chat, _) => chat.toJson(),
     );


  }

  Future<void> createUserProfile({required UserProfile userProfile }) async{
    await _usersCollection?.doc(userProfile.uid).set(userProfile);

  }

  Stream<QuerySnapshot<UserProfile>> getUsersProfiles(){
   return _usersCollection?.where("uid", isNotEqualTo: _authService.user!.uid)
   .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExists(String uid1, String uid2) async{
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final result = await _chatsCollection?.doc(chatID).get();
    if(result != null){
      return result.exists;
    }
    return false;


  }

Future<void> createNewChat(String uid1, String uid2) async {
  String chatID = generateChatID(uid1: uid1, uid2: uid2);
  final docRef = _chatsCollection!.doc(chatID);
  final chat = Chat(
    id: chatID,
    participants: [uid1, uid2],
    messages: [],
    lastMessage: '',
    
    isGroup: false,
  );
  await docRef.set(chat);
}

Future<void> sendChatMessage(String uid1, String uid2, Message message) async {
  String chatID = generateChatID(uid1: uid1, uid2: uid2);
  await _chatsCollection!.doc(chatID).update({
    "messages": FieldValue.arrayUnion([message.toJson()]),
    "lastMessage": message.content,
    "lastMessageTime": FieldValue.serverTimestamp(),
  });
}

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2){
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    return _chatsCollection?.doc(chatID).snapshots() as Stream<DocumentSnapshot<Chat>>;
  }




  //group 
Future<String> createGroupChat({
  required List<String> participantIDs,
  required String groupName,
  required String? groupImageUrl,
}) async {
  final docRef = _chatsCollection!.doc(); // Auto-generated ID
  final chat = Chat(
    id: docRef.id,
    participants: participantIDs,
    groupName: groupName,
    groupImageUrl: groupImageUrl,
    messages: [],
    isGroup: true,
  );
  await docRef.set(chat);
  return docRef.id;
}


Future<void> addMemberToGroup(String chatId, String newMemberId) async {
  final docRef = _chatsCollection!.doc(chatId);
  await docRef.update({
    'participants': FieldValue.arrayUnion([newMemberId])
  });
}

Future<Map<String, dynamic>> getGroupData(String groupId) async {
  final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
  return groupDoc.data() ?? {};
}

//for search user
Stream<QuerySnapshot<Chat>> getUserChats(String userId) {
  return FirebaseFirestore.instance
      .collection('chats')
      .withConverter<Chat>(
        fromFirestore: (snapshot, _) => Chat.fromJson(snapshot.data()!),
        toFirestore: (chat, _) => chat.toJson(),
      )
      .where('participants', arrayContains: userId)
      .orderBy('lastMessage', descending: true)
      .snapshots();
}

}