import 'package:budgets/core/utils/response_parser.dart';
import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/main.dart';
import 'package:budgets/features/transactions/domain/model/expense_model.dart';
import 'package:flutter/foundation.dart';

/// Paginated response model for transactions
class PaginatedTransactions {
  final List<Expense> transactions;
  final bool hasMore;
  final int currentPage;

  const PaginatedTransactions({
    required this.transactions,
    required this.hasMore,
    required this.currentPage,
  });
}

Future<List<Expense>> getExpenses() {
  return Wrapper.execute(() async {
    try {
      final response = await supabase.from('transaction').select('''
    title,
    description,
    amount,
    date,
    invoice_file,
    transaction_type,
    categories (id, name, emoji, color)
  ''').order('date', ascending: false);

      if (response.isEmpty) return [];

      List<Expense> expense =
          (response as List).map((item) => Expense.fromMap(item)).toList();

      return expense;
    } catch (e, s) {
      debugPrint('$e,$s');
      rethrow;
    }
  });
}

/// Get transactions with pagination
Future<PaginatedTransactions> getTransactionsPaginated({
  int page = 0,
  int limit = 10,
  TransactionType? type,
}) {
  return Wrapper.execute(() async {
    try {
      final offset = page * limit;

      var query = supabase.from('transaction').select('''
            title,
            description,
            amount,
            date,
            invoice_file,
            transaction_type,
            categories (id, name, emoji, color)
          ''');

      if (type != null) {
        query = query.eq('transaction_type', type.value);
      }

      // Get transactions with one extra to check if there are more
      final response = await query
          .order('date', ascending: false)
          .range(offset, offset + limit); // fetches limit+1 items

      if (response.isEmpty) {
        return const PaginatedTransactions(
          transactions: [],
          hasMore: false,
          currentPage: 0,
        );
      }

      final List<Expense> transactions =
          (response as List).map((item) => Expense.fromMap(item)).toList();

      // Check if there are more items by seeing if we got more than limit
      final hasMore = transactions.length > limit;

      // If we have more than limit, remove the extra item
      if (hasMore) {
        transactions.removeLast();
      }

      return PaginatedTransactions(
        transactions: transactions,
        hasMore: hasMore,
        currentPage: page,
      );
    } catch (e, s) {
      debugPrint('Error getting paginated transactions: $e, $s');
      rethrow;
    }
  });
}

// Add expenses
Future<void> addExpense(
    String? amount,
    String? description,
    String? categoryName,
    Map<String, String>? subcategoryAmounts,
    TransactionType? transactionType) {
  return Wrapper.execute(() async {
    final response = await supabase.rpc(
      'add_expenses',
      params: {
        'amount': amount,
        'description': description,
        'category_name': categoryName,
        'tr_type': transactionType?.value ?? TransactionType.expense.value,
        'subcategories_amount': subcategoryAmounts,
      },
    );

    final result = parseRpcAddExpenseResponse(response);

    if (!result.success) {
      throw Exception(result.errorMessage ?? 'Failed to add expense');
    }

    debugPrint("Expense created: ${response.runtimeType} -> $response");
  });
}
