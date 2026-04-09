import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/post_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/post_model.dart';
import '../../widgets/app_image.dart';

class CreatePostScreen extends StatefulWidget {
  final String categoryId;
  final PostModel? postToEdit;

  const CreatePostScreen({
    super.key,
    required this.categoryId,
    this.postToEdit,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  XFile? image;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.postToEdit != null) {
      titleCtrl.text = widget.postToEdit!.title;
      contentCtrl.text = widget.postToEdit!.content;
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => image = picked);
    }
  }

  Future<void> submit() async {
    if (titleCtrl.text.isEmpty || contentCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => loading = true);

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);

    try {
      if (widget.postToEdit == null) {
        await postProvider.createPost(
          title: titleCtrl.text,
          content: contentCtrl.text,
          categoryId: widget.categoryId,
          userId: authProvider.user!.id,
          image: image, // Pass XFile directly
        );
      } else {
        await postProvider.updatePost(
          postId: widget.postToEdit!.id,
          title: titleCtrl.text,
          content: contentCtrl.text,
          image: image, // Pass XFile directly
          existingImageUrl: widget.postToEdit!.imageUrl,
        );
      }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.postToEdit == null ? "Create Post" : "Edit Post"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentCtrl,
              maxLines: 5,
              decoration: const InputDecoration(labelText: "Content"),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: image != null
                    ? AppImage(imageUrl: image!.path, fit: BoxFit.cover)
                    : (widget.postToEdit?.imageUrl != null
                        ? AppImage(imageUrl: widget.postToEdit!.imageUrl, fit: BoxFit.cover)
                        : const Icon(Icons.add_a_photo, size: 50)),
              ),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: submit,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: Text(widget.postToEdit == null ? "Post" : "Update"),
                  ),
          ],
        ),
      ),
    );
  }
}
