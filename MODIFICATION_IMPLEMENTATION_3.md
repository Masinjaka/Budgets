# Modification Implementation Plan: Display Subcategory Name

This document outlines the phased implementation plan for the "Display Subcategory Name" feature.

## Journal

*   **Phase 1:** Initial setup.

## Phase 1: Update Subcategory Transaction Model and Bottom Sheet

In this phase, we will update the `SubcategoryTransaction` model, the data source, and the bottom sheet to display the subcategory name.

- [ ] Update `lib/features/categories/domain/models/subcategory_transaction.dart` to replace the `subId` field with a `subcategory` field of type `Subcategory?`.
- [ ] Update the `fromJson` and `toJson` methods in the `SubcategoryTransaction` model.
- [ ] Update `lib/features/categories/data/datasource/subcategories_expenses_api.dart` to perform a join with the `subcategories` table.
- [ ] Update `lib/features/transactions/presentation/widgets/transaction_detail_bottom_sheet.dart` to display the subcategory name from the `Subcategory` object.
- [ ] Run `fvm dart fix --apply`.
- [ ] Run `fvm dart analyze` and fix any issues.
- [ ] Run `fvm dart format .`.
- [ ] Update the `MODIFICATION_IMPLEMENTATION_3.md` file with the current state.
- [ ] Use `git diff` to verify the changes and propose a commit message to the user.
- [ ] Wait for approval before committing.

## Phase 2: Finalization

- [ ] Ask the user to inspect the package and say if they are satisfied with the changes.
- [ ] Commit the final changes to the implementation plan.
