import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../providers/comment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_image.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommentProvider>(context, listen: false).fetchComments(widget.post.id);
    });
  }

  @override
  void dispose() {
    commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (commentCtrl.text.trim().isEmpty) return;

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final commentProvider = Provider.of<CommentProvider>(context, listen: false);

    try {
      await commentProvider.addComment(
        postId: widget.post.id,
        userId: authProvider.user!.id,
        userName: authProvider.user!.name,
        content: commentCtrl.text.trim(),
      );
      commentCtrl.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding comment: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = Provider.of<CommentProvider>(context);
    final authProvider = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Post Detail")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        // Optional: Full screen view logic
                        showDialog(
                          context: context,
                          builder: (context) => Dialog.fullscreen(
                            backgroundColor: Colors.black,
                            child: Stack(
                              children: [
                                InteractiveViewer(
                                  child: Center(
                                    child: AppImage(
                                      imageUrl: widget.post.imageUrl!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AppImage(
                          imageUrl: widget.post.imageUrl!,
                          width: double.infinity,
                          // Removed fixed height to allow full aspect ratio display
                          fit: BoxFit.fitWidth, 
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    widget.post.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Posted on ${widget.post.createdAt.day}/${widget.post.createdAt.month}/${widget.post.createdAt.year}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Divider(height: 30),
                  Text(
                    widget.post.content,
                    style: const TextStyle(fontSize: 18, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Comments",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  if (commentProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (commentProvider.comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No comments yet.", style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: commentProvider.comments.length,
                      itemBuilder: (context, index) {
                        final comment = commentProvider.comments[index];
                        final isOwner = comment.userId == authProvider.user?.id;
                        
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(comment.content),
                          trailing: isOwner 
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                onPressed: () => commentProvider.deleteComment(comment.id, widget.post.id),
                              )
                            : Text(
                                "${comment.createdAt.hour}:${comment.createdAt.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          // Comment Input Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentCtrl,
                      decoration: const InputDecoration(
                        hintText: "Write a comment...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _submitComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
