import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/auth_provider.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

class CategoryPostsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryPostsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryPostsScreen> createState() => _CategoryPostsScreenState();
}

class _CategoryPostsScreenState extends State<CategoryPostsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).changeCategory(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final authProvider = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: postProvider.loading && postProvider.posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: postProvider.posts.length,
              itemBuilder: (context, i) {
                final p = postProvider.posts[i];
                final isOwner = p.userId == authProvider.user?.id;

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(p.title),
                    subtitle: Text(p.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(post: p),
                        ),
                      );
                    },
                    trailing: isOwner
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreatePostScreen(
                                        categoryId: widget.categoryId,
                                        postToEdit: p,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => postProvider.deletePost(p.id),
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePostScreen(categoryId: widget.categoryId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
