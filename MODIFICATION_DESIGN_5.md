# Modification Design: Fix Infinite Loading After Transaction Add

## 1. Overview

This document outlines the design for fixing a bug where the transaction list enters an infinite loading state after a new transaction is added.

## 2. Detailed Analysis of the Goal

### 2.1. Infinite Loading State

Currently, after a user adds a new transaction (either expense or income), the transaction list displayed in the respective tab (`Dépense` or `Revenu`) remains in a perpetual loading state, indicated by a loading shimmer. This issue is resolved only when the user switches to another tab and then returns to the original tab.

The root cause of this behavior lies in the asynchronous nature of Riverpod's `ref.refresh` combined with immediate invalidation. In `transaction_provider.dart`, the `addUserTransaction` method calls `ref.refresh(paginatedTransactionsProvider)` to update the list of transactions. However, this call is not `await`ed. Immediately after initiating the refresh, `ref.invalidateSelf()` is called.

This sequence of operations creates a race condition:
1.  `ref.refresh(paginatedTransactionsProvider)` starts an asynchronous operation to fetch the latest transactions. During this period, `paginatedTransactionsProvider` is in a loading state.
2.  Before `paginatedTransactionsProvider` completes its refresh and transitions to an `AsyncData` state, `ref.invalidateSelf()` is triggered for `transactionsProvider`.
3.  Any UI widgets observing `transactionsProvider` (which indirectly depends on `paginatedTransactionsProvider`) might receive an `AsyncLoading` state from `paginatedTransactionsProvider` and remain stuck because `transactionsProvider` itself is not correctly reflecting the completion of the underlying refresh.

By `await`ing `ref.refresh(paginatedTransactionsProvider)`, we ensure that `paginatedTransactionsProvider` has fully completed its data fetching and state update before `transactionsProvider` is invalidated. This guarantees that when `transactionsProvider` rebuilds, it observes a consistent and updated state from `paginatedTransactionsProvider`, thus correctly rendering the new list of transactions.

## 3. Alternatives Considered

No other alternatives were considered for this specific bug, as the direct cause and solution involve correctly managing the asynchronous state updates between Riverpod providers.

## 4. Detailed Design

### 4.1. Fix Infinite Loading State

-   **File:** `lib/features/transactions/domain/providers/transaction_provider.dart`
-   **Content:** The `addUserTransaction` method will be updated to `await` the `ref.refresh` call.
-   **Modification:** The line `final paginated = ref.refresh(paginatedTransactionsProvider);` will be changed to `await ref.refresh(paginatedTransactionsProvider);`. This ensures that the `paginatedTransactionsProvider` completes its refresh operation before `transactionsProvider` is invalidated, thus resolving the race condition and ensuring consistent state updates.

### 4.2. Mermaid Diagram

```mermaid
graph TD
    subgraph "Before Fix"
        A[addUserTransaction] -->|calls| B(ref.refresh on PaginatedTransactionsProvider);
        B -- (starts async op) --> C[PaginatedTransactionsProvider (Loading State)];
        B --- D[ref.invalidateSelf on TransactionsProvider];
        D -- (rebuilds immediately) --> E[UI (Stuck in Loading)];
    end

    subgraph "After Fix"
        F[addUserTransaction] -->|calls & awaits| G(ref.refresh on PaginatedTransactionsProvider);
        G -- (waits for completion) --> H[PaginatedTransactionsProvider (AsyncData State)];
        H --> I[ref.invalidateSelf on TransactionsProvider];
        I -- (rebuilds with updated data) --> J[UI (Displays new data)];
    end
```

## 5. Summary of the Design

The proposed fix addresses the infinite loading state by correctly managing the asynchronous flow between dependent Riverpod providers. By awaiting the `ref.refresh` call, we guarantee that the UI observes a fully updated transaction list, eliminating the need for a tab switch to force a state refresh.

## 6. Research URLs

-   [Riverpod Refresh documentation](https://riverpod.dev/docs/concepts/reading#refreshing-a-provider)
-   [AsyncNotifier documentation](https://riverpod.dev/docs/concepts/async_notifier)
