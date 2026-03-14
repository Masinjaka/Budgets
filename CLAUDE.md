# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run app (inject env vars via dart-define)
flutter run --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key> --dart-define=SENTRY_DSN=<dsn>

# Run tests
flutter test
flutter test test/path/to/specific_test.dart

# Code generation (Riverpod providers, freezed models)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs

# Lint
flutter analyze

# Build release APK
flutter build apk --release --dart-define=...
```

## Architecture

Clean architecture per feature under `lib/features/<feature>/`:
- `domain/` — models, provider definitions, repository interfaces
- `data/` — Supabase implementations (datasources, repositories)
- `presentation/` — pages, widgets, controllers

Shared UI components live in `lib/widgets/`. Cross-cutting utilities (formatters, enums, theme, constants) live in `lib/core/`.

## State Management: Riverpod with Code Generation

All providers use `@riverpod` / `@Riverpod(keepAlive: true)` annotations. Never write providers by hand — always use annotations and run build_runner. Generated files end in `.g.dart` and must not be edited manually.

Key providers:
- `authStateProvider` — streams Supabase auth state; gates all authenticated routes
- `themeProvider` (keepAlive) — persisted theme mode via SharedPreferences
- `transactionProvider` / `paginatedExpensesProvider` / `paginatedIncomesProvider` — transaction data
- `currencyProvider` — exchange rates and selected currency
- `budgetsProvider` / `goalsProvider` — planning data

## Navigation: GoRouter

Router is defined in `MyApp` in `lib/main.dart`. The main shell uses `StatefulShellRoute` with `IndexedStack` to preserve tab state across 5 branches: home, transaction-list, stats, planning, settings.

Auth redirect is handled via `authStateProvider` — unauthenticated users are redirected to `/login`. Deep link for password reset: `io.supabase.budgets://reset-callback`.

## Backend: Supabase

All data operations go through Supabase. Mutations use RPC functions (`add_expense_with_budget_check`, `delete_expense`, `edit_expense`, `delete_user`) rather than direct table writes. Pagination is offset-based with 10 items per page and a `hasMore` flag.

## Local Storage

- **Hive** (`budgets_storage` box) — persistent app data
- **SharedPreferences** — theme preference (`globalTheme` key)

Storage key constants are defined in `LocalAppStorage` in `lib/core/constants.dart`.

## Environment Variables

Injected at build time via `--dart-define`. Required vars: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SENTRY_DSN`. See `.env.example` and `.vscode/launch.json` for reference.

## Initialization Order (main.dart)

Sentry → Firebase → FCM background handler → French locale → Supabase → Hive → app launch. The app is wrapped in `SentryScreenshotWidget` for error capture.

## Theme & Localization

- Primary color: `#10B981` (green), font: Outfit (Google Fonts)
- Dark background: `#0A0C10`
- App uses French locale (`intl` package); string `"Épargne"` is the savings category name constant
- Theme defined in `lib/core/theme.dart`

## CI/CD

GitHub Actions (`.github/workflows/firebase-distribution.yml`) builds on push to `main` and distributes to Firebase App Distribution. Secrets: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SENTRY_DSN`, Firebase service account.
