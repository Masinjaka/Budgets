# Modification Implementation Plan: Theme Selection

This document outlines the steps to implement the theme selection feature.

## Journal

- **Phase 1:** Created the `ThemeNotifier` and `themeProvider` to manage theme state. Integrated `shared_preferences` to persist the selected theme. Defined `lightTheme` and `darkTheme` in `lib/core/theme.dart` and updated `main.dart` to use the new theme provider. The default theme is now light.
- **Phase 2:** Implemented the theme selection dialog in the settings page. The dialog allows the user to choose between light, dark, and system themes. The selected theme is saved to `shared_preferences` and the UI is updated to reflect the change.

## Phase 1: Setup and Core Theme Implementation

- [x] Add the `shared_preferences` dependency to `pubspec.yaml`.
- [x] Create a new file `lib/features/settings/presentation/providers/theme_provider.dart` to house the `ThemeNotifier` and the `themeProvider`.
- [x] Update `lib/core/theme.dart` to define the `lightTheme` and `darkTheme` `ThemeData` objects.
- [x] Modify `main.dart` to use the `themeProvider` and set the default theme to light.
- [x] Run `fvm dart fix --apply` to clean up the code.
- [x] Run `fvm dart format .` to make sure that the formatting is correct.
- [x] Re-read the `MODIFICATION_IMPLEMENTATION.md` file to see what, if anything, has changed in the implementation plan.
- [x] Update the `MODIFICATION_IMPLEMENTATION.md` file with the current state, including any learnings, surprises, or deviations in the Journal section. Check off any completed checkboxes.
- [ ] Use `git diff` to verify the changes that have been made, and create a suitable commit message for the changes. Present the change message to the user for approval.
- [ ] Wait for approval. Don't commit the changes or move on to the next phase of implementation until the user approves the commit.
- [ ] After committing the change, if an app is running, use the `hot_reload` tool to reload it.

## Phase 2: UI Implementation

- [x] In `lib/features/settings/presentation/pages/setting_page.dart`, implement the `onTap` callback for the "Apparence" `SettingCard`.
- [x] Create and show a dialog for theme selection ("Nuit", "Jour", "Système").
- [x] Connect the dialog to the `themeProvider` to update the theme when an option is selected.
- [x] Update the `settingChoice` text in the `SettingCard` to reflect the currently selected theme.
- [x] Run `fvm dart fix --apply` to clean up the code.
- [x] Run `fvm dart format .` to make sure that the formatting is correct.
- [x] Re-read the `MODIFICATION_IMPLEMENTATION.md` file to see what, if anything, has changed in the implementation plan.
- [x] Update the `MODIFICATION_IMPLEMENTATION.md` file with the current state, including any learnings, surprises, or deviations in the Journal section. Check off any completed checkboxes.
- [ ] Use `git diff` to verify the changes that have been made, and create a suitable commit message for the changes. Present the change message to the user for approval.
- [ ] Wait for approval. Don't commit the changes or move on to the next phase of implementation until the user approves the commit.
- [ ] After committing the change, if an app is running, use the `hot_reload` tool to reload it.

## Phase 3: Finalization and Review

- [x] Update the `README.md` file with any relevant information about the new theme feature (if applicable).
- [x] Ask the user to inspect the app and say if they are satisfied with it, or if any modifications are needed.