import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';

class TransactionMapper {
  const TransactionMapper();

  TransactionModel fromSupabase(Map<String, dynamic> row) {
    final category = row['category'] as Map<String, dynamic>?;
    return TransactionModel(
      id: row['id'] as String?,
      title: row['title'] as String?,
      description: row['description'] as String?,
      amount: (row['amount'] as num?)?.toDouble(),
      date: DateTime.tryParse(row['date']?.toString() ?? '')?.toLocal(),
      invoiceFile: row['invoice_file'] as String?,
      transactionType:
          TransactionType.fromValue(row['transaction_type'] as String?),
      category: category == null
          ? null
          : Category(
              id: category['id'] as String?,
              name: category['name'] as String?,
              emoji: category['emoji'] as String?,
              color: category['color'] as String?,
            ),
    );
  }
}
