import 'package:budgets/core/wrapper.dart';
import 'package:budgets/main.dart';
import 'package:budgets/model/category_model.dart' as model;

Future<List<model.Category>> getCategories() {
  return Wrapper.execute(() async {
    final response = await supabase.from('expense_categories').select();

    if(response.isEmpty) return [];

    List<model.Category> categories = (response as List)
        .map((item) => model.Category.fromMap(item))
        .toList();

    return categories;
  });
}