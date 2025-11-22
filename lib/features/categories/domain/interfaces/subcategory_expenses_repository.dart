import 'package:budgets/features/categories/domain/models/subcategory_transaction.dart';

abstract class SubcategoryExpensesRepository {
  Future<List<SubcategoryTransaction>> fetchSubcategoryExpenses(
      String transactionId);
}
