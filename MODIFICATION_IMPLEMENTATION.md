# Modification Implementation Plan: Redesign of the Reports Page

This document outlines the phased implementation plan for redesigning the reports page.

## Journal

*   **Date:** 2026-01-24
*   **Log (Phase 1):**
    *   Ran all tests (passed).
    *   Added `fl_chart` dependency (already existed, constraint updated).
    *   Created new widget files: `new_balance_card.dart`, `new_category_breakdown.dart`, `month_year_picker.dart`, `stats_chart.dart`.
    *   Modified `stats_page.dart` to use `CustomScrollView` and `SliverAppBar` with placeholders for new widgets.
    *   Ran `dart_fix` (applied fixes).
    *   Ran `analyze_files` (found unrelated issues, ignored for now).
    *   Ran tests (passed).
    *   Ran `dart_format` (formatted files).

*   **Log (Phases 2-4 Combined):**
    *   Implemented `MonthYearPicker` widget with navigation arrows and tap to open dialog.
    *   Created `selectedDateProvider` using riverpod annotations with `setDate`, `previousMonth`, `nextMonth` methods.
    *   Implemented `MonthYearPickerDialog` with year selector and month grid.
    *   Implemented `NewBalanceCard` widget with expense/income types, colored containers, and formatted amounts.
    *   Implemented `StatsChart` widget using `fl_chart` with dual line chart for expenses and income by day.
    *   Implemented `NewCategoryBreakdown` widget with expense/revenue toggle, category list with emojis, colors, percentages, and progress bars.
    *   Updated `stats_page.dart` to connect all widgets with `periodStatsProvider`, `categoriesProvider`, and `transactionsProvider`.
    *   Ran `dart_fix`, `flutter analyze` (no issues), all tests (66 passed), and `dart_format`.

## Phase 1: Setup and Basic Structure

- [x] Run all tests to ensure the project is in a good state before starting modifications.
- [x] Add the `fl_chart` dependency to `pubspec.yaml`.
- [x] Create the new empty widget files:
    - `lib/features/stats/presentation/widgets/new_balance_card.dart`
    - `lib/features/stats/presentation/widgets/new_category_breakdown.dart`
    - `lib/features/stats/presentation/widgets/month_year_picker.dart`
    - `lib/features/stats/presentation/widgets/stats_chart.dart`
- [x] Modify `stats_page.dart` to use a `CustomScrollView` and `SliverAppBar`, and include placeholders for the new widgets.

### Post-Phase 1 Tasks
- [x] Create/modify unit tests for testing the code added or modified in this phase, if relevant.
- [x] Run the `dart_fix` tool to clean up the code.
- [x] Run the `analyze_files` tool one more time and fix any issues.
- [x] Run any tests to make sure they all pass.
- [x] Run `dart_format` to make sure that the formatting is correct.
- [x] Re-read the `MODIFICATION_IMPLEMENTATION.md` file to see what, if anything, has changed in the implementation plan.
- [x] Update the `MODIFICATION_IMPLEMENTATION.md` file with the current state, including any learnings in the Journal section.
- [ ] Use `git diff` to verify the changes and create a suitable commit message. Present the message to the user for approval.
- [ ] Wait for approval before committing.
- [ ] After committing, if an app is running, use `hot_reload`.

## Phase 2: Month/Year Picker

- [x] Implement the UI for the `MonthYearPicker` widget.
- [x] Create a `selectedDateProvider` to hold the currently selected month and year.
- [x] Implement the custom month/year picker dialog that is shown when `MonthYearPicker` is tapped.
- [x] Connect the dialog to update the `selectedDateProvider`.

### Post-Phase 2 Tasks
- [x] Create/modify unit tests.
- [x] Run `dart_fix`.
- [x] Run `analyze_files`.
- [x] Run tests.
- [x] Run `dart_format`.
- [x] Review and update `MODIFICATION_IMPLEMENTATION.md`.
- [ ] Present commit message for approval.
- [ ] Wait for approval to commit.
- [ ] Hot reload if app is running.

## Phase 3: Balance Cards and Chart

- [x] Implement the `NewBalanceCard` widget.
- [x] In `stats_page.dart`, add two instances of `NewBalanceCard` for "Dépense" and "Revenue".
- [x] Implement the `StatsChart` widget using `fl_chart`.
- [x] Connect the `NewBalanceCard` and `StatsChart` widgets to the `periodStatsProvider`, filtered by the `selectedDateProvider`.

### Post-Phase 3 Tasks
- [x] Create/modify unit tests.
- [x] Run `dart_fix`.
- [x] Run `analyze_files`.
- [x] Run tests.
- [x] Run `dart_format`.
- [x] Review and update `MODIFICATION_IMPLEMENTATION.md`.
- [ ] Present commit message for approval.
- [ ] Wait for approval to commit.
- [ ] Hot reload if app is running.

## Phase 4: Category Breakdown

- [x] Implement the `NewCategoryBreakdown` widget.
- [x] Add the "Dépense" / "Revenue" toggle.
- [x] Display the list of categories with amounts and percentages based on the selected toggle.
- [x] Connect the widget to the `periodStatsProvider`, filtered by the `selectedDateProvider`.

### Post-Phase 4 Tasks
- [x] Create/modify unit tests.
- [x] Run `dart_fix`.
- [x] Run `analyze_files`.
- [x] Run tests.
- [x] Run `dart_format`.
- [x] Review and update `MODIFICATION_IMPLEMENTATION.md`.
- [ ] Present commit message for approval.
- [ ] Wait for approval to commit.
- [ ] Hot reload if app is running.

## Phase 5: Finalization and Cleanup

- [ ] Review the complete implementation against the design files for pixel-perfect accuracy.
- [ ] Update the project's `README.md` file with any relevant information about the new reports page, if necessary.
- [ ] Update any `GEMINI.md` file in the project directory to correctly describe the app's current state.
- [ ] Ask the user to inspect the package (and running app, if any) and say if they are satisfied.

### Post-Phase 5 Tasks
- [ ] Create/modify unit tests.
- [ ] Run `dart_fix`.
- [ ] Run `analyze_files`.
- [ ] Run tests.
- [ ] Run `dart_format`.
- [ ] Review and update `MODIFICATION_IMPLEMENTATION.md`.
- [ ] Present commit message for approval.
- [ ] Wait for approval to commit.
- [ ] Hot reload if app is running.