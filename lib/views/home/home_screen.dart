import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/post_model.dart';
import '../../models/category_model.dart';
import '../../services/post_service.dart';
import '../../services/category_service.dart';
import 'category_posts_screen.dart';
import 'post_detail_screen.dart';
import 'create_post_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  final CategoryService _categoryService = CategoryService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header: MY FORUM
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  const Icon(Icons.menu, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  const Text(
                    "MY FORUM",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFF1E1E1E),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Search Bar Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple.shade900, width: 2),
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      color: Colors.white,
                      child: DropdownButton<String>(
                        value: "Everything",
                        underline: const SizedBox(),
                        items: ["Everything"]
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e, style: const TextStyle(color: Colors.black)),
                                ))
                            .toList(),
                        onChanged: (_) {},
                      ),
                    ),
                    Container(
                      width: 200,
                      height: 40,
                      color: Colors.white,
                      child: const TextField(
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: "search...",
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      color: Colors.white,
                      child: const Icon(Icons.search, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Forum Content
            Expanded(
              child: StreamBuilder<List<CategoryModel>>(
                stream: _categoryService.getCategoriesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                  }
                  final categories = snapshot.data ?? [];

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return _buildCategorySection(cat);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           // Opening CreatePost with the first available category as default
           _categoryService.getCategories().then((list) {
             if (list.isNotEmpty) {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePostScreen(categoryId: list.first.id),
                ),
              );
             }
           });
        },
        label: const Text("NEW POST"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildCategorySection(CategoryModel cat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF2D2D2D),
          ),
          child: Text(
            cat.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        _buildForumItem(
          catId: cat.id,
          catName: cat.name,
          icon: Icons.forum_rounded,
          title: cat.name,
          content: "Discuss everything about ${cat.name} here.",
          posts: 0, // In a real app, you'd aggregate these
          topics: 0,
          lastPostBy: "...",
          lastPostDate: "...",
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryPostsScreen(
                  categoryId: cat.id,
                  categoryName: cat.name,
                ),
              ),
            );
          }
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildForumItem({
    required String catId,
    required String catName,
    required IconData icon,
    required String title,
    required String content,
    required int posts,
    required int topics,
    required String lastPostBy,
    required String lastPostDate,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    content,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Dynamic data could be loaded here based on catId
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.black45), right: BorderSide(color: Colors.black45)),
                ),
                child: Text(
                  "Stats",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Category View", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                  const Text("Click to open", style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
