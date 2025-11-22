import 'package:budgets/features/transactions/domain/model/transaction_model.dart';

/// State class for paginated transactions
class PaginatedTransactionsState {
  final List<TransactionModel> transactions;
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
    List<TransactionModel>? transactions,
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
