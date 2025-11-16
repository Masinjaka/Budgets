import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/main.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';

Future<List<Category>> getCategories() {
  return Wrapper.execute(() async {
    final response = await supabase.from('categories').select('id, name, emoji, color, transaction_type');

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
