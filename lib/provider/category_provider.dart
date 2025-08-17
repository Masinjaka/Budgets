import 'package:budgets/api/category_api.dart';
import 'package:budgets/model/category_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_provider.g.dart';

@riverpod
class Categories extends _$Categories {
  @override
  Future<List<Category>> build() {
    return getCategories();
  }

  Future<String> addSomeCategory(Category category) async {
    state = const AsyncValue.loading();
    try {
      final result = await addCategory(category);
      final categories = await getCategories();
      state = AsyncValue.data(categories);
      return result;
    } catch (e,s) {
      state = AsyncValue.error(e,s);
      rethrow;
    }
  }
  
  Future<String> editSomeCategory(Category category) async {
    // state = const AsyncValue.loading();
    try {
      final result = await editCategory(category);
      final categories = await getCategories();
      state = AsyncValue.data(categories);
      return result;
    } catch (e,s) {
      state = AsyncValue.error(e,s);
      rethrow;
    }
  }
}