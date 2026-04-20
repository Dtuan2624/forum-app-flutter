import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../services/category_service.dart';

class CreatePostScreen extends StatefulWidget {
  final PostModel? post;
  final String? categoryId;

  const CreatePostScreen({super.key, this.post, this.categoryId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final CategoryService _categoryService = CategoryService();
  bool _loading = false;
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _titleController.text = widget.post!.title;
      _contentController.text = widget.post!.content;
      _selectedCategoryId = widget.post!.categoryId;
    } else {
      _selectedCategoryId = widget.categoryId;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryService.getCategories();
    if (!mounted) return;
    setState(() {
      _categories = categories;
      if (_selectedCategoryId == null && categories.isNotEmpty) {
        _selectedCategoryId = categories.first.id;
      }
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final categoryId = _selectedCategoryId;
    if (title.isEmpty || content.isEmpty || categoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All fields are required')));
      return;
    }

    setState(() => _loading = true);
    try {
      final authProvider = context.read<AppAuthProvider>();
      final postProvider = context.read<PostProvider>();
      final userId = authProvider.user?.uid ?? 'anonymous';
      if (widget.post == null) {
        await postProvider.createPost(
          title: title,
          content: content,
          categoryId: categoryId,
          userId: userId,
        );
      } else {
        await postProvider.updatePost(
          id: widget.post!.id,
          title: title,
          content: content,
          categoryId: categoryId,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save post: $error')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? 'Create Post' : 'Edit Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                minLines: 4,
                maxLines: 8,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategoryId = value),
              ),
              const SizedBox(height: 24),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _save,
                      child: Text(
                        widget.post == null ? 'Create Post' : 'Update Post',
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
