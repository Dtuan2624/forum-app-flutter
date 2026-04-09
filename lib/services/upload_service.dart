import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

class UploadService {
  final _uuid = const Uuid();

  Future<String?> upload(dynamic imageInput) async {
    try {
      if (imageInput == null) return null;

      // Handle XFile (cross-platform)
      if (imageInput is XFile) {
        if (kIsWeb) {
          return imageInput.path; // Blob URL
        } else {
          // Mobile: Copy to permanent storage
          final directory = await getApplicationDocumentsDirectory();
          final fileName = "${_uuid.v4()}${p.extension(imageInput.path)}";
          final savedPath = p.join(directory.path, fileName);
          
          final bytes = await imageInput.readAsBytes();
          final savedFile = File(savedPath);
          await savedFile.writeAsBytes(bytes);
          return savedFile.path;
        }
      }

      // Handle legacy File (mobile only)
      if (imageInput is File) {
        if (kIsWeb) return null;
        final directory = await getApplicationDocumentsDirectory();
        final fileName = "${_uuid.v4()}${p.extension(imageInput.path)}";
        final savedPath = p.join(directory.path, fileName);
        final savedFile = await imageInput.copy(savedPath);
        return savedFile.path;
      }

      return null;
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }
}
