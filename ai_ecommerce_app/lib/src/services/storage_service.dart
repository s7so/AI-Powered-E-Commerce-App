import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProductImage({required File file, required String productId}) async {
    final ref = _storage.ref().child('products').child('$productId.jpg');
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }
}