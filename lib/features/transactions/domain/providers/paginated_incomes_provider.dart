import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/transactions/data/datasource/expense_api.dart';
import 'package:budgets/features/transactions/domain/model/paginated_transaction_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginatedIncomes extends StateNotifier<PaginatedTransactionsState> {
  PaginatedIncomes()
      : super(const PaginatedTransactionsState(
          transactions: [],
          hasMore: true,
          isLoading: true,
          isLoadingMore: false,
          currentPage: 0,
        )) {
    // Defer first load so provider is fully mounted
    Future.microtask(_loadFirstPage);
  }

  static const int pageSize = 10;
  bool _loadingNext = false;

  Future<void> _loadFirstPage() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final result = await getTransactionsPaginated(
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
    if (_loadingNext ||
        state.isLoadingMore ||
        !state.hasMore ||
        state.isLoading) return;
    _loadingNext = true;
    try {
      state = state.copyWith(isLoadingMore: true, errorMessage: null);
      final nextPage = state.currentPage + 1;
      final result = await getTransactionsPaginated(
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
    } finally {
      _loadingNext = false;
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

final paginatedIncomesProvider = StateNotifierProvider.autoDispose<
    PaginatedIncomes, PaginatedTransactionsState>((ref) {
  return PaginatedIncomes();
});
