import 'package:budgets/features/transactions/data/datasource/expense_api.dart';
import 'package:budgets/features/transactions/domain/model/paginated_transaction_state.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../../../provider/paginated_expenses_provider.g.dart';


@riverpod
class PaginatedExpenses extends _$PaginatedExpenses {
  static const int pageSize = 10;

  @override
  PaginatedTransactionsState build() {
    // Initialize with loading state and auto-load first page
    _loadFirstPage();
    return const PaginatedTransactionsState(
      transactions: [],
      hasMore: true,
      isLoading: true,
      isLoadingMore: false,
      currentPage: 0,
    );
  }

  /// Load the first page of transactions
  Future<void> _loadFirstPage() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final result = await getTransactionsPaginated(page: 0, limit: pageSize);
      
      state = PaginatedTransactionsState(
        transactions: result.transactions,
        hasMore: result.hasMore,
        isLoading: false,
        isLoadingMore: false,
        currentPage: 0,
      );
    } catch (e, s) {
      debugPrint('Error loading first page: $e, $s');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load the next page of transactions
  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) {
      return;
    }

    try {
      state = state.copyWith(isLoadingMore: true, errorMessage: null);
      
      final nextPage = state.currentPage + 1;
      final result = await getTransactionsPaginated(page: nextPage, limit: pageSize);
      
      state = state.copyWith(
        transactions: [...state.transactions, ...result.transactions],
        hasMore: result.hasMore,
        isLoadingMore: false,
        currentPage: nextPage,
      );
    } catch (e, s) {
      debugPrint('Error loading next page: $e, $s');
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh all transactions (reload from beginning)
  Future<void> refresh() async {
    try {
      state = const PaginatedTransactionsState(
        transactions: [],
        hasMore: true,
        isLoading: true,
        isLoadingMore: false,
        currentPage: 0,
      );
      
      await _loadFirstPage();
    } catch (e, s) {
      debugPrint('Error refreshing transactions: $e, $s');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Add a new transaction and refresh the list
  Future<void> addTransactionAndRefresh() async {
    await refresh();
  }
}
