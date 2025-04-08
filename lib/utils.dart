import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:test/services/auth_service.dart';
import 'package:test/services/cloudinary_service.dart';
import 'package:test/services/database_service.dart';
import 'package:test/services/media_service.dart';
import 'package:test/services/storage_service.dart';

Future<void> registerServices() async {
    final GetIt getIt = GetIt.instance;

    getIt.registerSingleton<AuthService>(
        AuthService(),
    );
    getIt.registerSingleton<MediaService>(
        MediaService(),
    );
    //     getIt.registerSingleton<StorageService>(
    //     StorageService(),
    // );
    getIt.registerSingleton<DatabaseService>(
        DatabaseService(),
    );

    getIt.registerSingleton<CloudinaryService>(CloudinaryService());//???

}

String generateChatID({required String uid1, required String uid2}){
  List uids= [uid1, uid2];
  uids.sort();
  String chatID = uids.fold("", (id, uid) => "id$uid");
  return chatID;
}