# Transaction Fetching Bug Fix Design Document

## 1. Overview

This document outlines the design for fixing a critical bug in the transaction fetching mechanism where expense transactions fail to lazy load correctly when income transactions are also present in the system. The root cause has been identified as an incorrect call to the paginated transaction fetching function, leading to mixed transaction types being retrieved for expense-specific views.

## 2. Detailed Analysis of the Goal/Problem

The application exhibits a bug where, in scenarios with a significant number of both income and expense transactions, the expense tab fails to fully lazy load all expense transactions. Specifically, when the number of income transactions is approximately equal to the number of expense transactions, only a subset of expenses is loaded, and subsequent attempts to lazy load more expenses are unsuccessful. Conversely, if there are no income transactions, all expenses load as expected.

Upon investigation, the problem stems from the `PaginatedExpenses` Riverpod `StateNotifier` provider (`lib/features/transactions/domain/providers/paginated_expenses_provider.dart`). This provider is intended to manage the state and fetching of *expense-only* transactions. However, its call to the `getTransactionsPaginated` function (defined in `lib/features/transactions/data/datasource/transaction_api.dart`) is missing the `type` parameter.

The `getTransactionsPaginated` function in `transaction_api.dart` is designed to accept an optional `TransactionType` parameter to filter results at the data source level. When this parameter is omitted, the function defaults to fetching *all* transaction types.

Consequently, when `PaginatedExpenses` requests a page of transactions without specifying `type: TransactionType.expense`, the `getTransactionsPaginated` function returns a mix of both income and expense transactions (if available) up to the specified `limit`. This means that the paginated list, which should only contain expenses, is being filled with income transactions as well. When the page limit is reached, legitimate expense transactions are effectively "pushed out" by income transactions, and the `hasMore` flag (which determines if more pages can be loaded) is set based on this mixed list, leading to an incomplete display and a failure to lazy load the remaining expenses.

In contrast, the `PaginatedIncomes` provider (`lib/features/transactions/domain/providers/paginated_incomes_provider.dart`) correctly calls `getTransactionsPaginated` with `type: TransactionType.income`, ensuring that only income transactions are fetched for its specific view. This consistency is lacking in the `PaginatedExpenses` provider.

## 3. Alternatives Considered

One might consider filtering the `PaginatedTransactions` list *after* it has been returned from `getTransactionsPaginated` within the domain or presentation layer. However, this approach is highly inefficient and incorrect for the following reasons:
*   **Performance Overhead:** Fetching all transaction types from the database only to discard incomes client-side wastes bandwidth and processing power.
*   **Inaccurate Pagination:** Even if filtered client-side, the pagination logic (e.g., `hasMore` flag) would still be based on the *total* number of fetched items (including incomes), not just the desired type. This would still lead to an incomplete list of expenses and incorrect lazy loading behavior.

Therefore, filtering at the data source is the only correct and efficient approach.

## 4. Detailed Design for the Modification

The modification is highly targeted and involves a single change within the `PaginatedExpenses` provider.

The current call in `lib/features/transactions/domain/providers/paginated_expenses_provider.dart` to `getTransactionsPaginated` resembles:

```dart
// Current (problematic) call in PaginatedExpenses
final result = await getTransactionsPaginated(
  page: state.currentPage + 1,
  limit: _limit,
);
```

The design proposes to modify this call to explicitly include the `TransactionType.expense` parameter:

```dart
// Proposed (corrected) call in PaginatedExpenses
final result = await getTransactionsPaginated(
  page: state.currentPage + 1,
  limit: _limit,
  type: TransactionType.expense, // <-- ADDED THIS LINE
);
```

This change will ensure that `getTransactionsPaginated` only retrieves transactions of type `expense` when called by the `PaginatedExpenses` provider, resolving the issue of mixed transaction types and restoring correct lazy loading behavior for expenses.

## 5. Diagrams

Not applicable for this targeted, single-line code change. The textual description provides sufficient clarity.

## 6. Summary of the Design

The bug preventing proper lazy loading of expense transactions is due to the `PaginatedExpenses` provider failing to specify `TransactionType.expense` when calling `getTransactionsPaginated`. The proposed fix involves adding `type: TransactionType.expense` to this function call, ensuring that the data layer correctly filters transactions before they are returned to the provider. This simple and direct modification aligns with efficient data fetching practices and will resolve the described bug.

## 7. References to Research URLs

No external research URLs were required as the issue was identified through internal codebase investigation.