import 'package:budgets/model/expense_model.dart';

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