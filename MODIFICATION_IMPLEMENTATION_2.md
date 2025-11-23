# Modification Implementation Plan: Display Subcategory Transactions and Rename Expense Model

This document outlines the phased implementation plan for the "Display Subcategory Transactions and Rename Expense Model" feature.

## Journal

*   **Phase 1:** Renamed `Expense` model to `TransactionModel`, added the `id` field, and updated all files that use the old model. Ran `build_runner`, `dart fix`, `dart analyze`, and `dart format`.
*   **Phase 2:** Updated `transaction_detail_bottom_sheet.dart` to display subcategory transactions.
*   **Phase 3:** Finalization.

## Phase 1: Rename Expense Model and Add ID Field

In this phase, we will rename the `Expense` model to `TransactionModel`, add the `id` field, and update all files that use the old model.

- [x] Rename `lib/features/transactions/domain/model/expense_model.dart` to `lib/features/transactions/domain/model/transaction_model.dart`.
- [x] In the new file, rename the `Expense` class to `TransactionModel` and add the `id` field of type `String`.
- [x] Update the `fromMap`, `copyWith`, and `toMap` methods to include the new `id` field.
- [x] Update all files in the project that use the `Expense` model to use `TransactionModel` instead. This will involve updating imports and type annotations.
- [x] Run `fvm dart fix --apply`.
- [x] Run `fvm dart analyze` and fix any issues.
- [x] Run `fvm dart format .`.
- [x] Update the `MODIFICATION_IMPLEMENTATION_2.md` file with the current state.
- [x] Use `git diff` to verify the changes and propose a commit message to the user.
- [x] Wait for approval before committing.

## Phase 2: Update Transaction Detail Bottom Sheet

In this phase, we will modify the `transaction_detail_bottom_sheet.dart` to display the subcategory transactions.

- [x] Modify `transaction_detail_bottom_sheet.dart` to accept a `TransactionModel` object.
- [x] Remove the `subcategoriesProvider`.
- [x] Use the `subcategoryExpensesProvider` with the `transaction.id` to fetch and display the list of subcategory transactions.
- [x] Run `fvm dart fix --apply`.
- [x] Run `fvm dart analyze` and fix any issues.
- [x] Run `fvm dart format .`.
- [x] Update the `MODIFICATION_IMPLEMENTATION_2.md` file with the current state.
- [x] Use `git diff` to verify the changes and propose a commit message to the user.
- [x] Wait for approval before committing.

## Phase 3: Finalization

- [ ] Ask the user to inspect the package and say if they are satisfied with the changes.
- [ ] Commit the final changes to the implementation plan.