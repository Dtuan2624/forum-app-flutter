import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comment_model.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/category_provider.dart';
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

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a comment before sending.')),
      );
      return;
    }

    final authProvider = context.read<AppAuthProvider>();
    final userId = authProvider.user?.uid ?? 'anonymous';

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sendingComment = true);
    try {
      await context.read<CommentProvider>().createComment(
        postId: widget.post.id,
        userId: userId,
        text: text,
        parentCommentId: _replyToId,
      );
      _commentController.clear();
      setState(() {
        _replyToId = null;
        _replyToText = null;
      });
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not send comment: $error')),
      );
    } finally {
      if (mounted) setState(() => _sendingComment = false);
    }
  }

  Widget _buildCommentCard(CommentModel comment, List<CommentModel> replies) {
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
                Expanded(
                  child: Text(
                    comment.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Text(
                  comment.createdAt != null
                      ? '${comment.createdAt!.toLocal()}'
                      : '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _replyToId = comment.id;
                      _replyToText = comment.text;
                    });
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: const Text('Reply'),
                ),
              ],
            ),
            if (replies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                child: Column(
                  children: replies
                      .map(
                        (reply) => ListTile(
                          visualDensity: const VisualDensity(vertical: -2),
                          title: Text(reply.text),
                          subtitle: reply.createdAt != null
                              ? Text(reply.createdAt!.toLocal().toString())
                              : null,
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.read<CategoryProvider>();
    final commentProvider = context.watch<CommentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePostScreen(
                    post: widget.post,
                    categoryId: widget.post.categoryId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.post.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              FutureBuilder(
                future: categoryProvider.getCategoryById(
                  widget.post.categoryId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading category...');
                  }
                  final category = snapshot.data;
                  return Text(
                    category != null
                        ? 'Category: ${category.name}'
                        : 'Category: ${widget.post.categoryId}',
                    style: const TextStyle(color: Colors.grey),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(widget.post.content, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              const Text(
                'Comments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<CommentModel>>(
                stream: commentProvider.getCommentsStream(widget.post.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final comments = snapshot.data ?? [];
                  final topLevel = comments
                      .where((comment) => comment.parentCommentId == null)
                      .toList();
                  final replies = comments
                      .where((comment) => comment.parentCommentId != null)
                      .toList();

                  if (comments.isEmpty) {
                    return const Text(
                      'No comments yet. Start the conversation.',
                    );
                  }

                  return Column(
                    children: topLevel.map((comment) {
                      final nestedReplies = replies
                          .where((reply) => reply.parentCommentId == comment.id)
                          .toList();
                      return _buildCommentCard(comment, nestedReplies);
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              if (_replyToText != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text('Replying to: "$_replyToText"')),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _replyToId = null;
                            _replyToText = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Write a comment',
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              _sendingComment
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _sendComment,
                      child: const Text('Post comment'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
