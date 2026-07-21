import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Get subcategories for a specific category
Future<List<Subcategory>> getSubcategories(String categoryId) {
  return Wrapper.execute(() async {
    final results = await Supabase.instance.client
        .from('subcategories')
        .select('id, created_at, name, category_id')
        .eq('category_id', categoryId);

    if (results.isEmpty) return [];

    return results.map((item) => Subcategory.fromMap(item)).toList();
  });
}

// Get all subcategories
Future<List<Subcategory>> getAllSubcategories() {
  return Wrapper.execute(() async {
    final results = await Supabase.instance.client
        .from('subcategories')
        .select('id, created_at, name, category_id');

    if (results.isEmpty) return [];

    return results.map((item) => Subcategory.fromMap(item)).toList();
  });
}

// // Add subcategory
// Future<String> addSubcategory(Subcategory subcategory) {
//   return Wrapper.execute(() async {
//     final response = await supabase.rpc('add_subcategory', params: {
//       'subcategory_name': subcategory.name,
//       'subcategory_category_id': subcategory.categoryId,
//     });
//     return response as String;
//   });
// }

// // Edit subcategory
// Future<String> editSubcategory(Subcategory subcategory) {
//   return Wrapper.execute(() async {
//     final response = await supabase.rpc('edit_subcategory', params: {
//       'subcategory_id': subcategory.id,
//       'new_name': subcategory.name,
//       'new_category_id': subcategory.categoryId,
//     });
//     return response as String;
//   });
// }

// // Delete subcategory
// Future<String> deleteSubcategory(Subcategory subcategory) {
//   return Wrapper.execute(() async {
//     final response = await supabase.rpc('delete_subcategory', params: {
//       'subcategory_id': subcategory.id,
//     });
//     return response as String;
//   });
// }
