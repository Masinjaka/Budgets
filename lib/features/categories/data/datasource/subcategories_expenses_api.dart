import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/features/categories/domain/models/subcategory_transaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubcategoriesExpensesApi {
  final SupabaseClient _client;

  SubcategoriesExpensesApi(this._client);

  Future<List<SubcategoryTransaction>> fetchSubcategoryExpenses(
      String transactionId) {
    return Wrapper.execute(() async {
      final response = await _client
          .from('subcategory_expenses')
          .select()
          .eq('transaction_id', transactionId);

      if (response.isEmpty) {
        return [];
      }

      return response
          .map((json) => SubcategoryTransaction.fromJson(json))
          .toList();
    });
  }
}
