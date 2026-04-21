import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/comment_model.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/post_provider.dart';
import 'create_post_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  String? _replyToId;
  String? _replyToText;
  bool _sendingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _getUserInfo(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('nguoi_dung').doc(userId).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập bình luận.')));
      return;
    }

    final authProvider = context.read<AppAuthProvider>();
    final userId = authProvider.user?.uid ?? 'anonymous';

    setState(() => _sendingComment = true);
    try {
      await context.read<CommentProvider>().createComment(
        postId: widget.post.id,
        userId: userId,
        text: text,
        parentCommentId: _replyToId,
      );
      _commentController.clear();
      setState(() { _replyToId = null; _replyToText = null; });
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $error')));
    } finally {
      if (mounted) setState(() => _sendingComment = false);
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bình luận'),
        content: const Text('Bạn có chắc chắn muốn xóa bình luận này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<CommentProvider>().deleteComment(widget.post.id, commentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final authProvider = context.watch<AppAuthProvider>();
    final currentUserId = authProvider.user?.uid;

    return StreamBuilder<List<PostModel>>(
      stream: postProvider.getPostsStream(),
      builder: (context, snapshot) {
        // Tìm lại bài viết hiện tại trong stream để lấy số lượng like mới nhất
        final allPosts = snapshot.data ?? [];
        final post = allPosts.firstWhere((p) => p.id == widget.post.id, orElse: () => widget.post);
        final isLiked = currentUserId != null && post.likes.contains(currentUserId);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chi tiết bài viết'),
            actions: [
              if (post.userId == currentUserId)
                IconButton(icon: const Icon(Icons.edit), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostScreen(post: post, categoryId: post.categoryId)))),
              if (post.userId == currentUserId)
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Xóa bài viết'),
                      content: const Text('Bạn có chắc muốn xóa bài viết này?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                        TextButton(onPressed: () async { await postProvider.deletePost(post.id); if (context.mounted) { Navigator.pop(context); Navigator.pop(context); } }, child: const Text('Xóa', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                }),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<Map<String, dynamic>?>(
                    future: _getUserInfo(post.userId),
                    builder: (context, snapshot) {
                      final data = snapshot.data;
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: data?['photoUrl'] != null ? NetworkImage(data!['photoUrl']) : null,
                            child: data?['photoUrl'] == null ? const Icon(Icons.person) : null,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data?['displayName'] ?? 'Thành viên', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(post.createdAt != null ? '${post.createdAt!.toLocal().day}/${post.createdAt!.toLocal().month}/${post.createdAt!.toLocal().year}' : '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(post.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (post.imageUrl != null)
                    ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(post.imageUrl!, width: double.infinity, fit: BoxFit.cover)),
                  const SizedBox(height: 16),
                  Text(post.content, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 24),
                  
                  // DÒNG TƯƠNG TÁC LIKE
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey, size: 28),
                        onPressed: () { if (currentUserId != null) postProvider.toggleLike(post.id, currentUserId); },
                      ),
                      Text('${post.likes.length} người đã thích bài này', style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  
                  const Divider(),
                  const Text('Bình luận', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // Phần bình luận giữ nguyên...
                  _buildCommentsList(post.id, currentUserId),
                  const SizedBox(height: 24),
                  if (_replyToText != null)
                    Row(
                      children: [
                        Expanded(child: Text('Đang trả lời: "$_replyToText"', style: const TextStyle(fontStyle: FontStyle.italic))),
                        IconButton(onPressed: () => setState(() { _replyToId = null; _replyToText = null; }), icon: const Icon(Icons.close)),
                      ],
                    ),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(labelText: 'Viết bình luận...', border: OutlineInputBorder()),
                    minLines: 2, maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  _sendingComment ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _sendComment, child: const Text('Gửi bình luận')),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildCommentsList(String postId, String? currentUserId) {
    final commentProvider = context.watch<CommentProvider>();
    return StreamBuilder<List<CommentModel>>(
      stream: commentProvider.getCommentsStream(postId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final comments = snapshot.data ?? [];
        final topLevel = comments.where((comment) => comment.parentCommentId == null).toList();
        final replies = comments.where((comment) => comment.parentCommentId != null).toList();
        return Column(
          children: topLevel.map((comment) {
            final nestedReplies = replies.where((reply) => reply.parentCommentId == comment.id).toList();
            return _buildCommentCard(comment, nestedReplies, currentUserId);
          }).toList(),
        );
      },
    );
  }

  Widget _buildCommentCard(CommentModel comment, List<CommentModel> replies, String? currentUserId) {
    final isOwner = comment.userId == currentUserId;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FutureBuilder<Map<String, dynamic>?>(
                  future: _getUserInfo(comment.userId),
                  builder: (context, snapshot) => Text(snapshot.data?['displayName'] ?? 'Ẩn danh', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                if (isOwner) IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _deleteComment(comment.id)),
              ],
            ),
            Text(comment.text),
            TextButton(onPressed: () => setState(() { _replyToId = comment.id; _replyToText = comment.text; }), child: const Text('Trả lời')),
            if (replies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  children: replies.map((reply) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: FutureBuilder<Map<String, dynamic>?>(
                      future: _getUserInfo(reply.userId),
                      builder: (context, snap) => Text('${snap.data?['displayName'] ?? "..."}: ${reply.text}', style: const TextStyle(fontSize: 14)),
                    ),
                    trailing: reply.userId == currentUserId ? IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18), onPressed: () => _deleteComment(reply.id)) : null,
                  )).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
