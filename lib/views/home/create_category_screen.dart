import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';

class CreateCategoryScreen extends StatefulWidget {
  final CategoryModel? category;

  const CreateCategoryScreen({super.key, this.category});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name is required')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);
    try {
      final categoryProvider = context.read<CategoryProvider>();
      if (widget.category == null) {
        await categoryProvider.createCategory(name);
      } else {
        await categoryProvider.updateCategory(widget.category!.id, name);
      }
      if (mounted) Navigator.pop(context);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save category: $error')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == null ? 'Create Category' : 'Edit Category',
        ),
        backgroundColor: AppTheme.burgundyHeader,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.burgundyHeader,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.category,
                        size: 64,
                        color: AppTheme.goldAccent,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.category == null
                            ? 'New Category'
                            : 'Edit Category',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: AppTheme.darkGray),
                  decoration: InputDecoration(
                    labelText: 'Category name',
                    labelStyle: const TextStyle(color: AppTheme.darkGray),
                    prefixIcon: const Icon(
                      Icons.label,
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
                const SizedBox(height: 24),
                _loading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.goldAccent,
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
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
                            widget.category == null
                                ? 'Create Category'
                                : 'Update Category',
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
      ),
    );
  }
}
