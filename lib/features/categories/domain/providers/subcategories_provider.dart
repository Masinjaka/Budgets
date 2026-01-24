import 'package:budgets/features/categories/data/datasource/subcategories_api.dart';
import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subcategories_provider.g.dart';

@riverpod
Future<List<Subcategory>> subcategories(Ref ref, String categoryId) async {
  return await getSubcategories(categoryId);
}
