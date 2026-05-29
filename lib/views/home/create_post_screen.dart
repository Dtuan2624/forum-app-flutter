import 'dart:convert';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_theme.dart';
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

  // Image variables
  Uint8List? _imageBytes;
  String? _imageUrl;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _titleController.text = widget.post!.title;
      _contentController.text = widget.post!.content;
      _selectedCategoryId = widget.post!.categoryId;
      _imageUrl = widget.post!.imageUrl;
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

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageUrl = null; // Clear URL when picking new image
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _clearImage() {
    setState(() {
      _imageBytes = null;
      _imageUrl = null;
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

      // Upload image if new image was selected
      String? uploadedImageUrl = _imageUrl;
      if (_imageBytes != null) {
        final fileName = 'posts/${const Uuid().v4()}.jpg';
        try {
          uploadedImageUrl = await postProvider
              .uploadImage(_imageBytes!, fileName)
              .timeout(const Duration(seconds: 30));
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
          }
          setState(() => _loading = false);
          return;
        }

        if (uploadedImageUrl == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload image')),
            );
          }
          setState(() => _loading = false);
          return;
        }
      }

      if (widget.post == null) {
        await postProvider.createPost(
          title: title,
          content: content,
          categoryId: categoryId,
          userId: userId,
          imageUrl: uploadedImageUrl,
        );
      } else {
        await postProvider.updatePost(
          id: widget.post!.id,
          title: title,
          content: content,
          categoryId: categoryId,
          imageUrl: uploadedImageUrl,
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
        backgroundColor: AppTheme.burgundyHeader,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 2000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(color: AppTheme.darkGray),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: const TextStyle(color: AppTheme.darkGray),
                  prefixIcon: const Icon(
                    Icons.title,
                    color: AppTheme.goldAccent,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.darkGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.darkGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.goldAccent,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppTheme.cardGray,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                style: const TextStyle(color: AppTheme.darkGray),
                decoration: InputDecoration(
                  labelText: 'Content',
                  labelStyle: const TextStyle(color: AppTheme.darkGray),
                  prefixIcon: const Icon(
                    Icons.description,
                    color: AppTheme.goldAccent,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.darkGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.darkGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.goldAccent,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppTheme.cardGray,
                ),
                minLines: 4,
                maxLines: 8,
              ),
              const SizedBox(height: 16),
              // Image picker section
              GestureDetector(
                onTap: _loading ? null : _pickImage,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.goldAccent, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.cardGray,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_imageBytes == null && _imageUrl == null) ...[
                        Icon(
                          Icons.add_photo_alternate,
                          size: 48,
                          color: AppTheme.goldAccent,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add image',
                          style: TextStyle(
                            color: AppTheme.goldAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _imageBytes != null
                              ? Image.memory(
                                  _imageBytes!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : _imageUrl != null
                              ? Image.memory(
                                  base64Decode(_imageUrl!),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: _loading ? null : _pickImage,
                              icon: const Icon(Icons.edit),
                              label: const Text('Change'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.goldAccent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: _loading ? null : _clearImage,
                              icon: const Icon(Icons.delete),
                              label: const Text('Remove'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.accentRed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                style: const TextStyle(color: AppTheme.darkGray),
                dropdownColor: AppTheme.burgundyHeader,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: const TextStyle(color: AppTheme.darkGray),
                  prefixIcon: const Icon(
                    Icons.category,
                    color: AppTheme.goldAccent,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.darkGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.darkGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.goldAccent,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppTheme.cardGray,
                ),
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
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.goldAccent,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.blueButton,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.post == null ? 'Create Post' : 'Update Post',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
