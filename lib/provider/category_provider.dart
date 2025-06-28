import 'package:budgets/api/category_api.dart';
import 'package:budgets/model/category_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_provider.g.dart';

@riverpod
class Categories extends _$Categories {
  @override
  Future<List<Category>> build() async{
    return await getCategories();
  }
}