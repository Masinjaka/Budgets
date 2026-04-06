import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/core/powersync/powersync.dart' as powersync;
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/core/constants.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

Future<List<Category>> getCategories() {
  return Wrapper.execute(() async {
    final results = await powersync.db.getAll('''
      SELECT id, name, emoji, color, transaction_type
      FROM categories
    ''');

    if (results.isEmpty) return [];

    return results.map((row) => Category.fromMap(row)).toList();
  });
}

// Add category — replaces RPC 'add_category'
Future<String> addCategory(Category category) {
  return Wrapper.execute(() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('No authenticated user');

    final categoryId = _uuid.v4();
    final trType = category.transactionType?.value ?? 'expense';

    await powersync.db.execute(
      '''INSERT INTO categories (id, name, emoji, color, user_id, transaction_type)
         VALUES (?, ?, ?, ?, ?, ?)''',
      [categoryId, category.name, category.emoji, category.color, userId, trType],
    );

    return categoryId;
  });
}

// Edit category — replaces RPC 'edit_category'
Future<String> editCategory(Category category) {
  return Wrapper.execute(() async {
    if (category.id == null) throw Exception('Category ID is required');

    await powersync.db.execute(
      '''UPDATE categories
         SET name = COALESCE(?, name),
             emoji = COALESCE(?, emoji),
             color = COALESCE(?, color)
         WHERE id = ?''',
      [category.name, category.emoji, category.color, category.id],
    );

    return category.id!;
  });
}

// Delete category — replaces RPC 'delete_category'
Future<String> deleteCategory(Category category) {
  return Wrapper.execute(() async {
    if (category.id == null) throw Exception('Category ID is required');

    await powersync.db.execute(
      'DELETE FROM categories WHERE id = ?',
      [category.id],
    );

    return category.id!;
  });
}

/// Checks if the savings category exists for the current user
/// Returns the category if found, null otherwise
Future<Category?> getSavingsCategory() async {
  try {
    final categories = await getCategories();
    return categories
        .where((c) => c.name == SystemCategories.savingsCategoryName)
        .firstOrNull;
  } catch (e) {
    debugPrint('Error checking for savings category: $e');
    return null;
  }
}

/// Ensures the savings category exists for goal contributions
/// Creates it if it doesn't exist, returns the existing one if it does
Future<Category> ensureSavingsCategoryExists() async {
  final existing = await getSavingsCategory();
  if (existing != null) {
    return existing;
  }

  // Create the savings category
  debugPrint('Creating savings category for goals...');
  await addCategory(Category(
    name: SystemCategories.savingsCategoryName,
    emoji: SystemCategories.savingsCategoryEmoji,
    color: SystemCategories.savingsCategoryColor,
    transactionType: TransactionType.expense,
  ));

  // Fetch and return the newly created category
  final categories = await getCategories();
  final created = categories
      .where((c) => c.name == SystemCategories.savingsCategoryName)
      .firstOrNull;

  if (created == null) {
    throw Exception('Failed to create savings category');
  }

  return created;
}

/// Check if a category is the system savings category
bool isSavingsCategory(Category category) {
  return category.name == SystemCategories.savingsCategoryName;
}
