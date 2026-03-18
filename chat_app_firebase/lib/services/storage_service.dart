import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'auth_service.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const _uuid = Uuid();

  /// Upload a chat image and return the download URL
  static Future<String> uploadChatImage(File file) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage
        .ref()
        .child('chat_images')
        .child(AuthService.currentUserId!)
        .child(fileName);

    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Upload a profile photo and return the download URL
  static Future<String> uploadProfilePhoto(File file) async {
    final ref = _storage
        .ref()
        .child('profile_photos')
        .child('${AuthService.currentUserId}.jpg');

    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
