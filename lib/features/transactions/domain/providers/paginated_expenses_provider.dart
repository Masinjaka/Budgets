import 'package:budgets/features/transactions/domain/model/paginated_transaction_state.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_api_provider.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'paginated_expenses_provider.g.dart';

@riverpod
class PaginatedExpenses extends _$PaginatedExpenses {
  static const int pageSize = 10;

  // Ensures we don't schedule the initial load multiple times
  bool _initialLoadScheduled = false;

  @override
  PaginatedTransactionsState build() {
    // Set the initial state synchronously
    const initialState = PaginatedTransactionsState(
      transactions: [],
      hasMore: true,
      isLoading: true,
      isLoadingMore: false,
      currentPage: 0,
    );

    // Schedule the first page load after the initial state is set
    if (!_initialLoadScheduled) {
      _initialLoadScheduled = true;
      Future.microtask(_loadFirstPage);
    }

    return initialState;
  }

  /// Load the first page of transactions
  Future<void> _loadFirstPage() async {
    if (!ref.mounted) return;
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final result =
          await ref.read(transactionsApiProvider).getTransactionsPaginated(
                page: 0,
                limit: pageSize,
                type: TransactionType.expense,
              );
      if (!ref.mounted) return;

      state = PaginatedTransactionsState(
        transactions: result.transactions,
        hasMore: result.hasMore,
        isLoading: false,
        isLoadingMore: false,
        currentPage: 0,
      );
    } catch (e, s) {
      debugPrint('Error loading first page: $e, $s');
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load the next page of transactions
  Future<void> loadNextPage() async {
    if (!ref.mounted ||
        state.isLoadingMore ||
        !state.hasMore ||
        state.isLoading) {
      return;
    }

    try {
      state = state.copyWith(isLoadingMore: true, errorMessage: null);

      final nextPage = state.currentPage + 1;
      final result =
          await ref.read(transactionsApiProvider).getTransactionsPaginated(
                page: nextPage,
                limit: pageSize,
                type: TransactionType.expense,
              );
      if (!ref.mounted) return;

      state = state.copyWith(
        transactions: [...state.transactions, ...result.transactions],
        hasMore: result.hasMore,
        isLoadingMore: false,
        currentPage: nextPage,
      );
    } catch (e, s) {
      debugPrint('Error loading next page: $e, $s');
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh all transactions (reload from beginning)
  Future<void> refresh() async {
    if (!ref.mounted) return;
    try {
      // Keep existing items to avoid showing empty state during refresh
      state = state.copyWith(
        isLoading: true,
        isLoadingMore: false,
        currentPage: 0,
        errorMessage: null,
      );

      await _loadFirstPage();
    } catch (e, s) {
      debugPrint('Error refreshing transactions: $e, $s');
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Optimistically remove a transaction by ID from the current state.
  void removeTransaction(String id) {
    final updated =
        state.transactions.where((t) => t.id != id).toList();
    state = state.copyWith(transactions: updated);
  }

  /// Add a new transaction and refresh the list
  Future<void> addTransactionAndRefresh() async {
    await refresh();
  }
}
