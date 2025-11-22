import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/main.dart';
import 'package:budgets/features/categories/domain/models/subcategories.dart';

// Get subcategories for a specific category
Future<List<Subcategory>> getSubcategories(String categoryId) {
  return Wrapper.execute(() async {
    final response = await supabase
        .from('subcategories')
        .select()
        .eq('category_id', categoryId);

    if (response.isEmpty) return [];

    List<Subcategory> subcategories =
        (response as List).map((item) => Subcategory.fromMap(item)).toList();

    return subcategories;
  });
}

// Get all subcategories
Future<List<Subcategory>> getAllSubcategories() {
  return Wrapper.execute(() async {
    final response = await supabase.from('subcategories').select();

    if (response.isEmpty) return [];

    List<Subcategory> subcategories =
        (response as List).map((item) => Subcategory.fromMap(item)).toList();

    return subcategories;
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
