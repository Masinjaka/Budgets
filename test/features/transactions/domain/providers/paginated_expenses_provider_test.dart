import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/transactions/data/datasource/transaction_api.dart';
import 'package:budgets/features/transactions/domain/model/paginated_transaction_state.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_expenses_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'paginated_expenses_provider_test.mocks.dart'; // Generated mock file

@GenerateMocks([TransactionsApi])
void main() {
  group('PaginatedExpenses', () {
    late MockTransactionsApi mockTransactionsApi;
    late ProviderContainer container;

    setUp(() {
      mockTransactionsApi = MockTransactionsApi();
      container = ProviderContainer(
        overrides: [
          transactionsApiProvider.overrideWith((ref) => mockTransactionsApi),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is correct before first load completes', () {
      final paginatedExpenses = container.read(paginatedExpensesProvider);
      expect(paginatedExpenses.transactions, isEmpty);
      expect(paginatedExpenses.hasMore, isTrue);
      expect(paginatedExpenses.isLoading, isTrue); // Should be true initially
      expect(paginatedExpenses.isLoadingMore, isFalse);
      expect(paginatedExpenses.currentPage, 0);
    });

    test('loadFirstPage fetches expenses with correct type and updates state',
        () async {
      final transactions = [
        TransactionModel(
          id: '1',
          title: 'Expense 1',
          description: 'Desc 1',
          amount: 100.0,
          date: DateTime.now(),
          transactionType: TransactionType.expense,
          category: null,
          invoiceFile: null,
        ),
      ];

      // Stub the call BEFORE the provider's build method schedules the microtask
      when(mockTransactionsApi.getTransactionsPaginated(
        page: anyNamed(
            'page'), // Use anyNamed for potentially non-literal arguments
        limit: anyNamed('limit'),
        type: eq(TransactionType.expense), // Use eq for enums
      )).thenAnswer((_) async => PaginatedTransactions(
            transactions: transactions,
            hasMore: true,
            currentPage: 0,
          ));

      // Access the provider to trigger build and initial load
      final paginatedExpensesNotifier =
          container.read(paginatedExpensesProvider.notifier);
      await container.pump(); // Allow Future.microtask to execute

      // The state should update after the initial load
      final state = container.read(paginatedExpensesProvider);
      expect(state.transactions, transactions);
      expect(state.hasMore, isTrue);
      expect(state.isLoading, isFalse); // Should be false after load
      expect(state.currentPage, 0);

      verify(mockTransactionsApi.getTransactionsPaginated(
        page: 0,
        limit: PaginatedExpenses.pageSize,
        type: eq(TransactionType.expense), // Use eq for enums in verify as well
      )).called(1);
    });

    test(
        'loadNextPage fetches more expenses with correct type and appends to state',
        () async {
      // Setup initial state (first page loaded)
      final initialTransactions = [
        TransactionModel(
          id: '1',
          title: 'Expense 1',
          description: 'Desc 1',
          amount: 100.0,
          date: DateTime.now(),
          transactionType: TransactionType.expense,
          category: null,
          invoiceFile: null,
        ),
      ];

      when(mockTransactionsApi.getTransactionsPaginated(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
        type: eq(TransactionType.expense),
      )).thenAnswer((_) async => PaginatedTransactions(
            transactions: initialTransactions,
            hasMore: true,
            currentPage: 0,
          ));

      final paginatedExpensesNotifier =
          container.read(paginatedExpensesProvider.notifier);
      await container.pump(); // Initial load

      // Setup for next page
      final nextTransactions = [
        TransactionModel(
          id: '2',
          title: 'Expense 2',
          description: 'Desc 2',
          amount: 200.0,
          date: DateTime.now(),
          transactionType: TransactionType.expense,
          category: null,
          invoiceFile: null,
        ),
      ];

      when(mockTransactionsApi.getTransactionsPaginated(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
        type: eq(TransactionType.expense),
      )).thenAnswer((_) async => PaginatedTransactions(
            transactions: nextTransactions,
            hasMore: false,
            currentPage: 1,
          ));

      await paginatedExpensesNotifier.loadNextPage();

      final state = container.read(paginatedExpensesProvider);
      expect(state.transactions, [...initialTransactions, ...nextTransactions]);
      expect(state.hasMore, isFalse);
      expect(state.isLoadingMore, isFalse);
      expect(state.currentPage, 1);

      verify(mockTransactionsApi.getTransactionsPaginated(
        page: 1,
        limit: PaginatedExpenses.pageSize,
        type: eq(TransactionType.expense),
      )).called(1);
    });

    test('loadNextPage does nothing if hasMore is false', () async {
      // Setup initial state with hasMore: false
      when(mockTransactionsApi.getTransactionsPaginated(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
        type: eq(TransactionType.expense),
      )).thenAnswer((_) async => const PaginatedTransactions(
            transactions: [],
            hasMore: false,
            currentPage: 0,
          ));

      final paginatedExpensesNotifier =
          container.read(paginatedExpensesProvider.notifier);
      await container.pump(); // Initial load

      // Try to load next page
      await paginatedExpensesNotifier.loadNextPage();

      // Verify getTransactionsPaginated was only called once (for initial load)
      verify(mockTransactionsApi.getTransactionsPaginated(
        page: 0,
        limit: PaginatedExpenses.pageSize,
        type: eq(TransactionType.expense),
      )).called(1);
      verifyNoMoreInteractions(mockTransactionsApi);

      final state = container.read(paginatedExpensesProvider);
      expect(state.hasMore, isFalse);
      expect(state.isLoadingMore, isFalse);
    });

    test('loadNextPage does nothing if isLoadingMore is true', () async {
      // Setup initial state first
      final initialTransactions = [
        TransactionModel(
          id: '1',
          title: 'Expense 1',
          description: 'Desc 1',
          amount: 100.0,
          date: DateTime.now(),
          transactionType: TransactionType.expense,
          category: null,
          invoiceFile: null,
        ),
      ];
      when(mockTransactionsApi.getTransactionsPaginated(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
        type: eq(TransactionType.expense),
      )).thenAnswer((_) async => PaginatedTransactions(
            transactions: initialTransactions,
            hasMore: true,
            currentPage: 0,
          ));
      final paginatedExpensesNotifier =
          container.read(paginatedExpensesProvider.notifier);
      await container.pump(); // Initial load

      // Manually set state to isLoadingMore: true
      paginatedExpensesNotifier.state =
          paginatedExpensesNotifier.state.copyWith(isLoadingMore: true);

      // Try to load next page
      await paginatedExpensesNotifier.loadNextPage();

      // Verify that getTransactionsPaginated was not called again (only once for initial load)
      verify(mockTransactionsApi.getTransactionsPaginated(
        page: 0,
        limit: PaginatedExpenses.pageSize,
        type: eq(TransactionType.expense),
      )).called(1);
      verifyNoMoreInteractions(
          mockTransactionsApi); // No more interactions than initial load

      final state = container.read(paginatedExpensesProvider);
      expect(state.isLoadingMore,
          isTrue); // Should remain true as no new load happened
    });
  });
}
