import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/core/powersync/powersync.dart' as powersync;
import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/features/categories/domain/models/subcategory_transaction.dart';
import 'package:flutter/foundation.dart';

class SubcategoriesExpensesApi {
  SubcategoriesExpensesApi();

  Future<List<SubcategoryTransaction>> fetchSubcategoryExpenses(
      String transactionId) {
    return Wrapper.execute(() async {
      final results = await powersync.db.getAll('''
        SELECT se.id, se.created_at, se.amount, se.sub_id, se.transaction_id,
               s.id AS sub_id_ref, s.name AS sub_name,
               s.category_id AS sub_category_id, s.created_at AS sub_created_at
        FROM subcategory_expenses se
        LEFT JOIN subcategories s ON se.sub_id = s.id
        WHERE se.transaction_id = ?
      ''', [transactionId]);

      if (results.isEmpty) {
        debugPrint(
            "No subcategory expenses found for transaction ID: $transactionId");
        return [];
      }

      debugPrint('Subcategory Expenses Response (PowerSync): $results');

      return results.map((row) {
        return SubcategoryTransaction(
          id: row['id'] as String,
          createdAt: row['created_at'] != null
              ? DateTime.parse(row['created_at'] as String)
              : DateTime.now(),
          amount: row['amount'] != null
              ? double.tryParse(row['amount'].toString())
              : null,
          subcategory: row['sub_id_ref'] != null
              ? Subcategory(
                  id: row['sub_id_ref'] as String?,
                  name: row['sub_name'] as String?,
                  categoryId: row['sub_category_id'] as String?,
                  createdAt: row['sub_created_at'] != null
                      ? DateTime.parse(row['sub_created_at'] as String)
                      : null,
                )
              : null,
          transactionId: row['transaction_id'] as String?,
        );
      }).toList();
    });
  }
}
