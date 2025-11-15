import 'package:budgets/api/expense_api.dart';
import 'package:budgets/model/expense_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State class for paginated transactions
class PaginatedTransactionsState {
  final List<Expense> transactions;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int currentPage;

  const PaginatedTransactionsState({
    required this.transactions,
    required this.hasMore,
    required this.isLoading,
    required this.isLoadingMore,
    this.errorMessage,
    required this.currentPage,
  });

  PaginatedTransactionsState copyWith({
    List<Expense>? transactions,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    int? currentPage,
  }) {
    return PaginatedTransactionsState(
      transactions: transactions ?? this.transactions,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class PaginatedExpensesNotifier extends StateNotifier<PaginatedTransactionsState> {
  static const int pageSize = 10;

  PaginatedExpensesNotifier() : super(const PaginatedTransactionsState(
    transactions: [],
    hasMore: true,
    isLoading: true,
    isLoadingMore: false,
    currentPage: 0,
  )) {
    // Auto-load first page
    _loadFirstPage();
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

/// Provider for paginated transactions
final paginatedExpensesProvider = StateNotifierProvider<PaginatedExpensesNotifier, PaginatedTransactionsState>((ref) {
  return PaginatedExpensesNotifier();
});
