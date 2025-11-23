import 'package:budgets/features/categories/data/datasource/subcategories_expenses_api.dart';
import 'package:budgets/features/categories/domain/interfaces/subcategory_expenses_repository.dart';
import 'package:budgets/features/categories/domain/models/subcategory_transaction.dart';

class SubcategoryExpensesRepositoryImpl
    implements SubcategoryExpensesRepository {
  final SubcategoriesExpensesApi _api;

  SubcategoryExpensesRepositoryImpl(this._api);

  @override
  Future<List<SubcategoryTransaction>> fetchSubcategoryExpenses(
      String transactionId) {
    return _api.fetchSubcategoryExpenses(transactionId);
  }
}
