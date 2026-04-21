import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../home/post_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;
  Uint8List? _avatarBytes;
  String? _currentName;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = context.read<AppAuthProvider>().user;
    if (user != null) {
      try {
        // Đổi tên collection thành 'nguoi_dung' cho đồng bộ
        final doc = await FirebaseFirestore.instance.collection('nguoi_dung').doc(user.uid).get();
        if (doc.exists && mounted) {
          setState(() {
            _currentName = doc.data()?['displayName'];
            _currentAvatarUrl = doc.data()?['photoUrl'];
            _nameController.text = _currentName ?? '';
          });
        }
      } catch (e) {
        print("Lỗi load user: $e");
      }
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _avatarBytes = bytes;
      });
    }
  }

  Future<void> _saveProfile() async {
    final user = context.read<AppAuthProvider>().user;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      String? photoUrl = _currentAvatarUrl;
      
      if (_avatarBytes != null) {
        final fileName = 'avatar_${user.uid}.jpg';
        photoUrl = await context.read<PostProvider>().uploadImage(_avatarBytes!, fileName);
      }

      // Lưu vào collection 'nguoi_dung'
      await FirebaseFirestore.instance.collection('nguoi_dung').doc(user.uid).set({
        'displayName': _nameController.text.trim(),
        'photoUrl': photoUrl,
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _currentName = _nameController.text.trim();
          _currentAvatarUrl = photoUrl;
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hồ sơ đã được cập nhật thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();
    final postProvider = context.read<PostProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Vui lòng đăng nhập')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang cá nhân'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueAccent,
                      backgroundImage: _avatarBytes != null 
                        ? MemoryImage(_avatarBytes!) 
                        : (_currentAvatarUrl != null ? NetworkImage(_currentAvatarUrl!) : null) as ImageProvider?,
                      child: (_avatarBytes == null && _currentAvatarUrl == null)
                        ? Text(user.email![0].toUpperCase(), style: const TextStyle(fontSize: 40, color: Colors.white))
                        : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 18,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 18, color: Colors.blue),
                            onPressed: _pickAvatar,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isSaving)
                  const CircularProgressIndicator()
                else ...[
                  _isEditing
                      ? TextField(
                          controller: _nameController,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(hintText: 'Nhập biệt danh'),
                        )
                      : Text(
                          _currentName ?? 'Chưa có biệt danh',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                  const SizedBox(height: 4),
                  Text(user.email!, style: const TextStyle(color: Colors.grey)),
                  if (_isEditing) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Lưu thay đổi'),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Bài viết của tôi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PostModel>>(
              stream: postProvider.getPostsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final userPosts = (snapshot.data ?? []).where((p) => p.userId == user.uid).toList();
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: userPosts.length,
                  itemBuilder: (context, index) {
                    final post = userPosts[index];
                    return Card(
                      child: ListTile(
                        leading: post.imageUrl != null 
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(post.imageUrl!, width: 40, height: 40, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.article),
                        title: Text(post.title),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailScreen(post: post))),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
