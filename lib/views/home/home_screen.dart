import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../core/app_theme.dart';
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
import '../../services/quote_service.dart';
import 'package:shimmer/shimmer.dart';

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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AppAuthProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final postProvider = context.read<PostProvider>();
    final currentUserId = authProvider.user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: 'Forum'.text.xl2.bold.make(),
        backgroundColor: AppTheme.burgundyHeader,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Trang cá nhân',
            onPressed: () => context.nextPage(const ProfileScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Tạo danh mục',
            onPressed: () => context.nextPage(const CreateCategoryScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: HStack([
        // Sidebar
        VStack([
          'Danh mục'.text.xl.bold.color(AppTheme.goldAccent).make().p16(),
          StreamBuilder<List<CategoryModel>>(
            stream: categoryProvider.categoriesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Shimmer.fromColors(
                  baseColor: AppTheme.darkGray,
                  highlightColor: AppTheme.cardGray,
                  child: ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.cardGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.darkGray,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 16,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.darkGray,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
              final categories = snapshot.data ?? [];
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.folder_open,
                      color: AppTheme.goldAccent,
                    ),
                    title: category.name.text.color(AppTheme.lightGray).make(),
                    tileColor: AppTheme.burgundyHeader,
                    onTap: () => context.nextPage(
                      CategoryPostsScreen(
                        categoryId: category.id,
                        categoryName: category.name,
                      ),
                    ),
                  ).box.roundedSM.make();
                },
              ).expand();
            },
          ).expand(),
        ]).box.width(280).border(color: AppTheme.darkGray).make(),

        // Posts
        VStack([
          // Quote of the day
          FutureBuilder<Map<String, dynamic>?>(
            future: QuoteService.fetchRandomQuote(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Shimmer.fromColors(
                  baseColor: AppTheme.darkGray,
                  highlightColor: AppTheme.cardGray,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.burgundyHeader,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 20,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.darkGray,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 20,
                          width: 200,
                          decoration: BoxDecoration(
                            color: AppTheme.darkGray,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 16,
                          width: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.darkGray,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final quote = snapshot.data;
              if (quote != null) {
                return VStack([
                  '"${quote['content']}"'.text.italic.lg
                      .color(AppTheme.goldAccent)
                      .makeCentered(),
                  '- ${quote['author']}'.text.sm
                      .color(AppTheme.lightGray)
                      .makeCentered(),
                ]).p16().card.color(AppTheme.burgundyHeader).make();
              }
              return const SizedBox.shrink();
            },
          ),

          HStack([
            'Bài viết mới nhất'.text.xl2.bold
                .color(AppTheme.goldAccent)
                .make()
                .expand(),
            24.widthBox,
            TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.lightGray),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bài viết...',
                hintStyle: const TextStyle(color: AppTheme.darkGray),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.goldAccent,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppTheme.goldAccent,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppTheme.darkGray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppTheme.darkGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: AppTheme.goldAccent,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppTheme.cardGray,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ).expand(flex: 2),
          ]).p16(),

          StreamBuilder<List<PostModel>>(
            stream: _searchQuery.isEmpty
                ? postProvider.getPostsStream()
                : postProvider.searchPosts(_searchQuery),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Shimmer.fromColors(
                  baseColor: AppTheme.darkGray,
                  highlightColor: AppTheme.cardGray,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.burgundyHeader,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppTheme.darkGray,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 20,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: AppTheme.darkGray,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 14,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: AppTheme.darkGray,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 14,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: AppTheme.darkGray,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: 14,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          color: AppTheme.darkGray,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppTheme.darkGray,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 30,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: AppTheme.darkGray,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
              final posts = snapshot.data ?? [];
              if (posts.isEmpty) {
                return (_searchQuery.isEmpty
                        ? 'Chưa có bài viết nào.'
                        : 'Không tìm thấy bài viết cho "$_searchQuery"')
                    .text
                    .color(AppTheme.lightGray)
                    .makeCentered();
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final isOwner = post.userId == currentUserId;
                  final isLiked =
                      currentUserId != null &&
                      post.likes.contains(currentUserId);

                  return VStack([
                        HStack([
                          if (post.imageUrl != null)
                            Image.network(
                              post.imageUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ).card.roundedSM.clip(Clip.antiAlias).make()
                          else
                            const Icon(
                                  Icons.image_not_supported,
                                  color: AppTheme.darkGray,
                                ).box
                                .color(AppTheme.cardGray)
                                .roundedSM
                                .make()
                                .wh(80, 80),

                          VStack([
                            post.title.text.bold.lg
                                .color(AppTheme.goldAccent)
                                .make(),
                            FutureBuilder<String>(
                              future: _getUserName(post.userId),
                              builder: (context, userSnap) =>
                                  'Đăng bởi: ${userSnap.data ?? "..."}'.text.sm
                                      .color(AppTheme.blueButton)
                                      .semiBold
                                      .make(),
                            ),
                            4.heightBox,
                            post.content.text
                                .color(AppTheme.lightGray)
                                .maxLines(2)
                                .ellipsis
                                .make(),
                          ]).pOnly(left: 12).expand(),
                        ]).onTap(
                          () => context.nextPage(PostDetailScreen(post: post)),
                        ),

                        HStack([
                          HStack([
                            IconButton(
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked
                                    ? AppTheme.accentRed
                                    : AppTheme.goldAccent,
                                size: 20,
                              ),
                              onPressed: () {
                                if (currentUserId != null) {
                                  postProvider.toggleLike(
                                    post.id,
                                    currentUserId,
                                  );
                                }
                              },
                            ),
                            '${post.likes.length}'.text
                                .color(AppTheme.lightGray)
                                .make(),
                          ]),
                          const Spacer(),
                          if (isOwner)
                            HStack([
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: AppTheme.blueButton,
                                  size: 18,
                                ),
                                onPressed: () => context.nextPage(
                                  CreatePostScreen(
                                    post: post,
                                    categoryId: post.categoryId,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: AppTheme.accentRed,
                                  size: 18,
                                ),
                                onPressed: () => _confirmDelete(context, post),
                              ),
                            ]),
                        ]).pOnly(top: 8),
                      ])
                      .p12()
                      .card
                      .color(AppTheme.burgundyHeader)
                      .make()
                      .pOnly(bottom: 12);
                },
              ).expand();
            },
          ).expand(),
        ]).expand(),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final categories = await categoryProvider.getCategories();
          if (categories.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hãy tạo danh mục trước.')),
            );
            return;
          }
          if (mounted) {
            context.nextPage(CreatePostScreen(categoryId: categories.first.id));
          }
        },
        backgroundColor: AppTheme.blueButton,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<String> _getUserName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userDoc.data()?['name'] ?? 'Người dùng';
    } catch (e) {
      return 'Người dùng';
    }
  }

  void _confirmDelete(BuildContext context, PostModel post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bài viết'),
        content: const Text('Bạn có chắc chắn muốn xóa bài viết này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<PostProvider>().deletePost(post.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
