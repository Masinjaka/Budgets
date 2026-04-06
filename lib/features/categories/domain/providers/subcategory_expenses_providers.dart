import 'package:budgets/features/categories/data/datasource/subcategories_expenses_api.dart';
import 'package:budgets/features/categories/data/repository/subcategory_expenses_repository_impl.dart';
import 'package:budgets/features/categories/domain/interfaces/subcategory_expenses_repository.dart';
import 'package:budgets/features/categories/domain/models/subcategory_transaction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subcategory_expenses_providers.g.dart';

@riverpod
SubcategoriesExpensesApi subcategoriesExpensesApi(ref) {
  return SubcategoriesExpensesApi();
}

@riverpod
SubcategoryExpensesRepository subcategoryExpensesRepository(ref) {
  return SubcategoryExpensesRepositoryImpl(
      ref.watch(subcategoriesExpensesApiProvider));
}

@riverpod
Future<List<SubcategoryTransaction>> subcategoryExpenses(
    ref, String transactionId) {
  final repository = ref.watch(subcategoryExpensesRepositoryProvider);
  return repository.fetchSubcategoryExpenses(transactionId);
}
