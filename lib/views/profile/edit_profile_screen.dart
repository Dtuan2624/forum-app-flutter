import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../services/upload_service.dart';
import '../../widgets/app_image.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameCtrl = TextEditingController();
  XFile? image;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppAuthProvider>(context, listen: false).user;
    if (user != null) {
      nameCtrl.text = user.name;
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => image = picked);
    }
  }

  Future<void> save() async {
    if (nameCtrl.text.isEmpty) return;
    
    setState(() => loading = true);
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);

    try {
      String? imageUrl;
      if (image != null) {
        imageUrl = await UploadService().upload(image);
      }

      await authProvider.updateProfile(
        name: nameCtrl.text,
        avatar: imageUrl,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppAuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 60,
                child: ClipOval(
                  child: image != null
                    ? AppImage(imageUrl: image!.path, width: 120, height: 120, fit: BoxFit.cover)
                    : (user != null && user.avatar != null && user.avatar != ""
                        ? AppImage(imageUrl: user.avatar, width: 120, height: 120, fit: BoxFit.cover)
                        : const Icon(Icons.add_a_photo, size: 40)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 30),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: save,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text("Save Changes"),
                  ),
          ],
        ),
      ),
    );
  }
}
