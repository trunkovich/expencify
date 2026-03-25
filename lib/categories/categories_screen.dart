import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/categories_repository.dart';
import '../data/models/category.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _repo = CategoriesRepository();

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Future<_CategoryEditResult?> _showCategoryDialog({
    required String title,
    String initialName = '',
    String initialEmoji = '',
  }) async {
    final controller = TextEditingController(text: initialName);
    final emojiController = TextEditingController(text: initialEmoji);

    return showDialog<_CategoryEditResult>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emojiController,
                decoration: const InputDecoration(
                  labelText: 'Emoji (optional)',
                ),
              ),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                _CategoryEditResult(
                  name: controller.text.trim(),
                  emoji: emojiController.text.trim(),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createCategory(List<Category> currentCategories) async {
    final result = await _showCategoryDialog(title: 'Add category');
    if (result == null) return;
    if (result.name.isEmpty) return;

    final uid = _uid;
    final now = Timestamp.now();
    final id = FirebaseFirestore.instance.collection('tmp').doc().id;

    final minSortOrder = currentCategories.isEmpty
        ? 0
        : currentCategories
            .map((c) => c.sortOrder)
            .reduce((a, b) => a < b ? a : b);

    final category = Category(
      id: id,
      name: result.name,
      emoji: result.emoji.isEmpty ? null : result.emoji,
      sortOrder: minSortOrder - 10,
      createdAt: now,
      updatedAt: now,
    );

    await _repo.createOrUpdateCategory(uid, category);
  }

  Future<void> _editCategory(Category category) async {
    final result = await _showCategoryDialog(
      title: 'Edit category',
      initialName: category.name,
      initialEmoji: category.emoji ?? '',
    );

    if (result == null) return;
    if (result.name.isEmpty) return;

    final updated = Category(
      id: category.id,
      name: result.name,
      emoji: result.emoji.isEmpty ? null : result.emoji,
      sortOrder: category.sortOrder,
      createdAt: category.createdAt,
      updatedAt: Timestamp.now(),
    );

    await _repo.createOrUpdateCategory(_uid, updated);
  }

  Future<void> _deleteCategory(Category category) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text('Delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _repo.deleteCategory(_uid, category.id);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: const [],
      ),
      body: StreamBuilder<List<Category>>(
        stream: _repo.watchCategories(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!;
          if (categories.isEmpty) {
            return const Center(child: Text('No categories yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: categories.length,
            separatorBuilder: (_, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final c = categories[index];
              return ListTile(
                leading: Text(c.emoji ?? '•', style: const TextStyle(fontSize: 20)),
                title: Text(c.name),
                subtitle: Text('id: ${c.id}'),
                onTap: () => _editCategory(c),
                trailing: IconButton(
                  onPressed: () => _deleteCategory(c),
                  icon: const Icon(Icons.delete_outline),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: StreamBuilder<List<Category>>(
        stream: _repo.watchCategories(uid),
        builder: (context, snapshot) {
          final current = snapshot.data ?? const <Category>[];
          return FloatingActionButton(
            onPressed: () => _createCategory(current),
            tooltip: 'Add category',
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

class _CategoryEditResult {
  const _CategoryEditResult({required this.name, required this.emoji});

  final String name;
  final String emoji;
}

