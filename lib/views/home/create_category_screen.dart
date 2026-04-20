import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Category name'),
                ),
                const SizedBox(height: 24),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _save,
                        child: Text(
                          widget.category == null
                              ? 'Create Category'
                              : 'Update Category',
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
