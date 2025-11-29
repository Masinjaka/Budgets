# Modification Implementation Plan: Theme Selection

This document outlines the steps to implement the theme selection feature.

## Journal

*No entries yet.*

## Phase 1: Setup and Core Theme Implementation

- [ ] Add the `shared_preferences` dependency to `pubspec.yaml`.
- [ ] Create a new file `lib/features/settings/presentation/providers/theme_provider.dart` to house the `ThemeNotifier` and the `themeProvider`.
- [ ] Update `lib/core/theme.dart` to define the `lightTheme` and `darkTheme` `ThemeData` objects.
- [ ] Modify `main.dart` to use the `themeProvider` and set the default theme to light.
- [ ] Run `fvm dart fix --apply` to clean up the code.
- [ ] Run `fvm dart format .` to make sure that the formatting is correct.
- [ ] Re-read the `MODIFICATION_IMPLEMENTATION.md` file to see what, if anything, has changed in the implementation plan.
- [ ] Update the `MODIFICATION_IMPLEMENTATION.md` file with the current state, including any learnings, surprises, or deviations in the Journal section. Check off any completed checkboxes.
- [ ] Use `git diff` to verify the changes that have been made, and create a suitable commit message for the changes. Present the change message to the user for approval.
- [ ] Wait for approval. Don't commit the changes or move on to the next phase of implementation until the user approves the commit.
- [ ] After committing the change, if an app is running, use the `hot_reload` tool to reload it.

## Phase 2: UI Implementation

- [ ] In `lib/features/settings/presentation/pages/setting_page.dart`, implement the `onTap` callback for the "Apparence" `SettingCard`.
- [ ] Create and show a dialog for theme selection ("Nuit", "Jour", "Système").
- [ ] Connect the dialog to the `themeProvider` to update the theme when an option is selected.
- [ ] Update the `settingChoice` text in the `SettingCard` to reflect the currently selected theme.
- [ ] Run `fvm dart fix --apply` to clean up the code.
- [ ] Run `fvm dart format .` to make sure that the formatting is correct.
- [ ] Re-read the `MODIFICATION_IMPLEMENTATION.md` file to see what, if anything, has changed in the implementation plan.
- [ ] Update the `MODIFICATION_IMPLEMENTATION.md` file with the current state, including any learnings, surprises, or deviations in the Journal section. Check off any completed checkboxes.
- [ ] Use `git diff` to verify the changes that have been made, and create a suitable commit message for the changes. Present the change message to the user for approval.
- [ ] Wait for approval. Don't commit the changes or move on to the next phase of implementation until the user approves the commit.
- [ ] After committing the change, if an app is running, use the `hot_reload` tool to reload it.

## Phase 3: Finalization and Review

- [ ] Update the `README.md` file with any relevant information about the new theme feature (if applicable).
- [ ] Ask the user to inspect the app and say if they are satisfied with it, or if any modifications are needed.
