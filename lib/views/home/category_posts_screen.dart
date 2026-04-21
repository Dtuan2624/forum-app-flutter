import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../views/home/create_post_screen.dart';
import '../../views/home/post_detail_screen.dart';

class CategoryPostsScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const CategoryPostsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final postProvider = context.read<PostProvider>();
    final authProvider = context.watch<AppAuthProvider>();
    final currentUserId = authProvider.user?.uid;

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: StreamBuilder<List<PostModel>>(
        stream: postProvider.getPostsStream(categoryId: categoryId),
        builder: (context, snapshot) {
          // Kiểm tra nếu có lỗi từ Firebase
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Lỗi truy vấn dữ liệu!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Hãy kiểm tra Debug Console trong Android Studio để nhấn vào link tạo Index.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text('No posts in this category yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final isOwner = post.userId == currentUserId;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(post.title),
                  subtitle: Text(
                    post.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(post: post),
                      ),
                    );
                  },
                  trailing: isOwner ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreatePostScreen(
                                post: post,
                                categoryId: categoryId,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, post),
                      ),
                    ],
                  ) : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePostScreen(categoryId: categoryId),
            ),
          );
        },
        tooltip: 'Create post in this category',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, PostModel post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final postProvider = context.read<PostProvider>();
              await postProvider.deletePost(post.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
