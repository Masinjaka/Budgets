import 'package:budgets/core/wrapper.dart';
import 'package:budgets/main.dart';
import 'package:budgets/model/category_model.dart';

Future<List<Category>> getCategories() {
  return Wrapper.execute(() async {
    final response = await supabase.from('categories').select();

    if (response.isEmpty) return [];

    List<Category> categories =
        (response as List).map((item) => Category.fromMap(item)).toList();

    return categories;
  });
}

Future<String> addCategory(Category category) {
  return Wrapper.execute(() async {
    final response = await supabase.rpc('add_category', params: {
      'category_name': category.name,
      'category_emoji': category.emoji,
      'category_color': category.color
    });
    return response as String;
  });
}
