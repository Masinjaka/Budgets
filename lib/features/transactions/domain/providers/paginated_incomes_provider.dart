import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/transactions/data/datasource/transaction_api.dart';
import 'package:budgets/features/transactions/domain/model/paginated_transaction_state.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'paginated_incomes_provider.g.dart';

@riverpod
class PaginatedIncomes extends _$PaginatedIncomes {
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

  Future<void> _loadFirstPage() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final result =
          await ref.read(transactionsApiProvider).getTransactionsPaginated(
                page: 0,
                limit: pageSize,
                type: TransactionType.income,
              );
      state = PaginatedTransactionsState(
        transactions: result.transactions,
        hasMore: result.hasMore,
        isLoading: false,
        isLoadingMore: false,
        currentPage: 0,
      );
    } catch (e, s) {
      debugPrint('Error loading first income page: $e, $s');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) {
      return;
    }
    try {
      state = state.copyWith(isLoadingMore: true, errorMessage: null);
      final nextPage = state.currentPage + 1;
      final result =
          await ref.read(transactionsApiProvider).getTransactionsPaginated(
                page: nextPage,
                limit: pageSize,
                type: TransactionType.income,
              );
      state = state.copyWith(
        transactions: [...state.transactions, ...result.transactions],
        hasMore: result.hasMore,
        isLoadingMore: false,
        currentPage: nextPage,
      );
    } catch (e, s) {
      debugPrint('Error loading next income page: $e, $s');
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    try {
      // Keep current list to avoid flicker
      state = state.copyWith(
        isLoading: true,
        isLoadingMore: false,
        currentPage: 0,
        errorMessage: null,
      );
      await _loadFirstPage();
    } catch (e, s) {
      debugPrint('Error refreshing incomes: $e, $s');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}
