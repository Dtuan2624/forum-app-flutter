import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class UploadService {
  final _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String?> upload(dynamic imageInput) async {
    try {
      if (imageInput == null) return null;

      final fileName = "${_uuid.v4()}.jpg";
      final ref = _storage.ref().child("uploads/$fileName");

      if (kIsWeb) {
        if (imageInput is XFile) {
          final bytes = await imageInput.readAsBytes();
          await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        }
      } else {
        if (imageInput is XFile) {
          await ref.putFile(File(imageInput.path));
        } else if (imageInput is File) {
          await ref.putFile(imageInput);
        }
      }

      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }
}
