import 'package:budgets/core/utils/response_parser.dart';
import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/main.dart'; // For supabase instance
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For SupabaseClient

part 'transaction_api.g.dart';

/// Paginated response model for transactions
class PaginatedTransactions {
  final List<TransactionModel> transactions;
  final bool hasMore;
  final int currentPage;

  const PaginatedTransactions({
    required this.transactions,
    required this.hasMore,
    required this.currentPage,
  });
}

class TransactionsApi {
  final SupabaseClient _supabaseClient;

  TransactionsApi(this._supabaseClient);

  Future<List<TransactionModel>> getTransactions() {
    return Wrapper.execute(() async {
      try {
        final response = await _supabaseClient.from('transaction').select('''
    id,
    title,
    description,
    amount,
    date,
    invoice_file,
    transaction_type,
    categories (id, name, emoji, color)
  ''').order('date', ascending: false);

        if (response.isEmpty) return [];

        List<TransactionModel> transactions = (response as List)
            .map((item) => TransactionModel.fromMap(item))
            .toList();

        return transactions;
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

        var query = _supabaseClient.from('transaction').select('''
            id,
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

        final List<TransactionModel> transactions = (response as List)
            .map((item) => TransactionModel.fromMap(item))
            .toList();

        // Correct pagination: if more than limit, set hasMore and remove last
        final hasMore = transactions.length > limit;
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

  // Add transactions
  Future<void> addTransaction(
      String? amount,
      String? description,
      String? categoryName,
      Map<String, String>? subcategoryAmounts,
      TransactionType? transactionType) {
    return Wrapper.execute(() async {
      // Ensure description is never null, default to empty string
      final validDescription = description?.trim() ?? "";
      
      final response = await _supabaseClient.rpc(
        'add_expenses',
        params: {
          'amount': amount,
          'description': validDescription,
          'category_name': categoryName,
          'tr_type': transactionType?.value ?? TransactionType.expense.value,
          'subcategories_amount': subcategoryAmounts,
        },
      );

      final result = parseRpcAddExpenseResponse(response);

      if (!result.success) {
        throw Exception(result.errorMessage ?? 'Failed to add transaction');
      }

      debugPrint("Transaction created: ${response.runtimeType} -> $response");
    });
  }
}

@riverpod
TransactionsApi transactionsApi(Ref ref) {
  return TransactionsApi(supabase);
}
