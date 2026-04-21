import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/category_model.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/post_provider.dart';
import '../profile/profile_screen.dart';
import 'category_posts_screen.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';
import 'create_category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> _getUserName(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('nguoi_dung').doc(userId).get();
      return doc.data()?['displayName'] ?? 'Thành viên mới';
    } catch (e) {
      return 'Ẩn danh';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final postProvider = context.read<PostProvider>();
    final currentUserId = authProvider.user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Trang cá nhân',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Tạo danh mục',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateCategoryScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade300))),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Align(alignment: Alignment.centerLeft, child: Text('Danh mục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                ),
                Expanded(
                  child: StreamBuilder<List<CategoryModel>>(
                    stream: categoryProvider.categoriesStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      final categories = snapshot.data ?? [];
                      return ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return ListTile(
                            leading: const Icon(Icons.folder_open),
                            title: Text(category.name),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryPostsScreen(categoryId: category.id, categoryName: category.name))),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Posts
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Text('Bài viết mới nhất', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm bài viết...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }) : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          onChanged: (value) => setState(() => _searchQuery = value),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<PostModel>>(
                    stream: _searchQuery.isEmpty ? postProvider.getPostsStream() : postProvider.searchPosts(_searchQuery),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      final posts = snapshot.data ?? [];
                      if (posts.isEmpty) return Center(child: Text(_searchQuery.isEmpty ? 'Chưa có bài viết nào.' : 'Không tìm thấy bài viết cho "$_searchQuery"'));
                      
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final isOwner = post.userId == currentUserId;
                          final isLiked = currentUserId != null && post.likes.contains(currentUserId);
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: post.imageUrl != null 
                                    ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(post.imageUrl!, width: 60, height: 60, fit: BoxFit.cover))
                                    : Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                                  title: Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FutureBuilder<String>(
                                        future: _getUserName(post.userId),
                                        builder: (context, userSnap) => Text('Đăng bởi: ${userSnap.data ?? "..."}', style: const TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.w500)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailScreen(post: post))),
                                ),
                                // Dòng tương tác: Like và Edit/Delete
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey),
                                            onPressed: () {
                                              if (currentUserId != null) {
                                                postProvider.toggleLike(post.id, currentUserId);
                                              }
                                            },
                                          ),
                                          Text('${post.likes.length}'),
                                        ],
                                      ),
                                      if (isOwner) Row(
                                        children: [
                                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostScreen(post: post, categoryId: post.categoryId)))),
                                          IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _confirmDelete(context, post)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final categories = await categoryProvider.getCategories();
          if (categories.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hãy tạo danh mục trước.')));
            return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostScreen(categoryId: categories.first.id)));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, PostModel post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bài viết'),
        content: const Text('Bạn có chắc chắn muốn xóa bài viết này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(onPressed: () async { await context.read<PostProvider>().deletePost(post.id); if (context.mounted) Navigator.pop(context); }, child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
