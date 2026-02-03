import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/main.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/core/constants.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:flutter/foundation.dart' hide Category;

Future<List<Category>> getCategories() {
  return Wrapper.execute(() async {
    final response = await supabase
        .from('categories')
        .select('id, name, emoji, color, transaction_type');

    if (response.isEmpty) return [];

    List<Category> categories =
        (response as List).map((item) => Category.fromMap(item)).toList();

    return categories;
  });
}

// Add category
Future<String> addCategory(Category category) {
  return Wrapper.execute(() async {
    final response = await supabase.rpc('add_category', params: {
      'category_name': category.name,
      'category_emoji': category.emoji,
      'category_color': category.color,
      'tr_type': category.transactionType?.value ?? 'expense',
    });
    return response as String;
  });
}

// Edit category
Future<String> editCategory(Category category) {
  return Wrapper.execute(() async {
    final response = await supabase.rpc('edit_category', params: {
      'category_id': category.id,
      'new_name': category.name,
      'new_emoji': category.emoji,
      'new_color': category.color,
      // 'new_transaction_type': category.transactionType?.value ?? 'expense',
    });
    return response as String;
  });
}

// Delete category
Future<String> deleteCategory(Category category) {
  return Wrapper.execute(() async {
    final response = await supabase.rpc('delete_category', params: {
      'category_id': category.id,
    });
    return response as String;
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
