import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );
  }

  Future<String> uploadProfileImage(String uid, XFile imageFile) async {
    final ref = _storage.ref().child('profile_images/$uid.jpg');
    await ref.putFile(File(imageFile.path));
    return await ref.getDownloadURL();
  }

  Future<void> deleteProfileImage(String uid) async {
    try {
      await _storage.ref().child('profile_images/$uid.jpg').delete();
    } catch (e) {
      // Image doesn't exist, ignore
    }
  }
}
