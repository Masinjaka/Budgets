import 'package:budgets/features/transactions/data/datasource/transaction_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:budgets/features/transactions/data/datasource/transaction_api.dart'
    show TransactionsApi, PaginatedTransactions;

part 'transaction_api_provider.g.dart';

@riverpod
TransactionsApi transactionsApi(Ref ref) {
  return TransactionsApi();
}
