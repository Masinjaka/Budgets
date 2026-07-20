import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/features/transactions/data/datasource/transaction_mapper.dart';
import 'package:budgets/features/transactions/data/datasource/transaction_mutation_service.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _transactionSelect =
    'id, title, description, amount, date, invoice_file, transaction_type, '
    'category:categories!expenses_category_id_fkey(id, name, emoji, color)';

class PaginatedTransactions {
  const PaginatedTransactions({
    required this.transactions,
    required this.hasMore,
    required this.currentPage,
  });

  final List<TransactionModel> transactions;
  final bool hasMore;
  final int currentPage;
}

class TransactionsApi {
  TransactionsApi()
      : _client = Supabase.instance.client,
        _mapper = const TransactionMapper();

  final SupabaseClient _client;
  final TransactionMapper _mapper;

  Future<List<TransactionModel>> getTransactions() {
    return Wrapper.execute(() async {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];
      final rows = await _client
          .from('transaction')
          .select(_transactionSelect)
          .eq('user_id', userId)
          .order('date', ascending: false);
      return rows.map(_mapper.fromSupabase).toList();
    });
  }

  Future<PaginatedTransactions> getTransactionsPaginated({
    int page = 0,
    int limit = 10,
    TransactionType? type,
  }) {
    return Wrapper.execute(() async {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const PaginatedTransactions(
          transactions: [],
          hasMore: false,
          currentPage: 0,
        );
      }
      var query = _client
          .from('transaction')
          .select(_transactionSelect)
          .eq('user_id', userId);
      if (type != null) query = query.eq('transaction_type', type.value);
      final offset = page * limit;
      final rows = await query
          .order('date', ascending: false)
          .range(offset, offset + limit);
      final transactions = rows.map(_mapper.fromSupabase).toList();
      final hasMore = transactions.length > limit;
      if (hasMore) transactions.removeLast();
      return PaginatedTransactions(
        transactions: transactions,
        hasMore: hasMore,
        currentPage: page,
      );
    });
  }

  Future<void> addTransaction(
    String? amount,
    String? description,
    String? categoryName,
    Map<String, String>? subcategoryAmounts,
    TransactionType? transactionType,
  ) {
    return Wrapper.execute(() {
      return _mutations.add(
        amount: _required(amount, 'Amount'),
        description: description?.trim() ?? '',
        categoryName: _required(categoryName, 'Category'),
        subcategoryAmounts: subcategoryAmounts,
        type: transactionType ?? TransactionType.expense,
      );
    });
  }

  Future<void> deleteTransaction(String transactionId) {
    return Wrapper.execute(() => _mutations.delete(transactionId));
  }

  Future<void> editTransaction(
    String transactionId,
    String? amount,
    String? description,
    String? categoryName,
    Map<String, String>? subcategoryAmounts,
    TransactionType? transactionType,
    DateTime? date,
  ) {
    return Wrapper.execute(() {
      return _mutations.edit(
        transactionId: transactionId,
        amount: _required(amount, 'Amount'),
        description: description?.trim() ?? '',
        categoryName: _required(categoryName, 'Category'),
        subcategoryAmounts: subcategoryAmounts,
        type: transactionType ?? TransactionType.expense,
        date: date,
      );
    });
  }

  TransactionMutationService get _mutations =>
      TransactionMutationService(_client);

  String _required(String? value, String name) {
    if (value == null || value.trim().isEmpty) {
      throw ArgumentError('$name cannot be empty');
    }
    return value.trim();
  }
}
