import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/features/categories/domain/models/subcategory_transaction.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubcategoriesExpensesApi {
  SubcategoriesExpensesApi();

  Future<List<SubcategoryTransaction>> fetchSubcategoryExpenses(
      String transactionId) {
    return Wrapper.execute(() async {
      final results = await Supabase.instance.client
          .from('subcategory_expenses')
          .select(
            'id, created_at, amount, transaction_id, '
            'subcategory:sub_id(id, name, category_id, created_at)',
          )
          .eq('transaction_id', transactionId);

      if (results.isEmpty) {
        debugPrint(
            "No subcategory expenses found for transaction ID: $transactionId");
        return [];
      }

      return results.map((row) {
        final subcategory = row['subcategory'] as Map<String, dynamic>?;
        return SubcategoryTransaction(
          id: row['id'] as String,
          createdAt: row['created_at'] != null
              ? DateTime.parse(row['created_at'] as String)
              : DateTime.now(),
          amount: row['amount'] != null
              ? double.tryParse(row['amount'].toString())
              : null,
          subcategory: subcategory != null
              ? Subcategory(
                  id: subcategory['id'] as String?,
                  name: subcategory['name'] as String?,
                  categoryId: subcategory['category_id'] as String?,
                  createdAt: subcategory['created_at'] != null
                      ? DateTime.parse(subcategory['created_at'] as String)
                      : null,
                )
              : null,
          transactionId: row['transaction_id'] as String?,
        );
      }).toList();
    });
  }
}
