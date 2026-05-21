# Drala

Drala is a Flutter mobile app for personal finance tracking. It lets users record expenses and income, organize categories, plan budgets and savings goals, view monthly reports, and keep working offline while data syncs back when connectivity returns.

## What the app does

- Track expenses and income
- Organize transactions with categories and subcategories
- Manage budgets and savings goals
- View monthly reports and chart-based summaries
- Choose a display currency using synced exchange rates
- Receive budget warnings and daily reminder notifications
- Continue using the app offline with local caching and deferred sync

## Stack at a glance

- Frontend: Flutter 3.38.7, Dart, Material UI
- State management: Riverpod with code generation
- Navigation: GoRouter
- Backend: Supabase
- Offline sync: PowerSync
- Push notifications: Firebase Cloud Messaging
- Local notifications: `flutter_local_notifications`
- Local persistence: Hive and SharedPreferences
- Monitoring: Sentry

## Supported platforms

The checked-in configuration is set up for Android and iOS.

There is a `web/` directory in the repo, but the current Firebase configuration in [`lib/firebase_options.dart`](/home/masy/project/Budgets/lib/firebase_options.dart:1) is not configured for web, so web should be treated as unfinished unless you add your own Firebase setup.

## Core features

- Authentication with sign up, login, password reset, and account profile management
- Home dashboard with recent activity, sync status, and quick summary widgets
- Transaction management for expenses and income
- Category and subcategory management
- Planning flows for budgets and goals
- Reports and charts for monthly performance
- Notification preferences for reminders and budget warnings
- Profile photo upload with retry support when offline

## Project structure

The app is organized feature-first under [`lib/features`](/home/masy/project/Budgets/lib/features).

```text
lib/
  core/              Shared infrastructure and app-wide utilities
  features/
    auth/
    categories/
    home/
    navigation/
    notifications/
    onboarding/
    planning/
    profile/
    settings/
    stats/
    transactions/
    user/
  widgets/           Reusable shared widgets
  main.dart          App entrypoint, initialization, routing
```

Most features follow the same layering:

- `presentation/`: pages, widgets, controllers
- `domain/`: models, providers, interfaces
- `data/`: datasources and repository implementations

## Architecture

### 1. App startup

The app bootstraps services in [`lib/main.dart`](/home/masy/project/Budgets/lib/main.dart:1) in this order:

1. Sentry binding
2. Firebase initialization
3. FCM background message handler registration
4. Foreground/local notification setup
5. French locale initialization
6. Supabase initialization
7. Hive initialization
8. PowerSync database initialization
9. Offline image upload queue initialization
10. `runApp` wrapped in Riverpod `ProviderScope`

### 2. UI and navigation

- Routing is defined in [`lib/main.dart`](/home/masy/project/Budgets/lib/main.dart:1) with GoRouter.
- The main authenticated shell uses `StatefulShellRoute.indexedStack` so tab state is preserved.
- Main sections are Home, Transactions, Planning, and Settings.
- Reports, category management, auth flows, and profile flows are exposed as regular routes outside the shell.

### 3. State management

- Riverpod is used across the app for async state and mutations.
- Providers are declared with `@riverpod` / `@Riverpod` annotations.
- Generated `*.g.dart` files are required for the app to compile.

Representative provider files:

- [`lib/features/transactions/domain/providers/transaction_provider.dart`](/home/masy/project/Budgets/lib/features/transactions/domain/providers/transaction_provider.dart:1)
- [`lib/features/categories/domain/providers/category_provider.dart`](/home/masy/project/Budgets/lib/features/categories/domain/providers/category_provider.dart:1)
- [`lib/core/currency/currency_provider.dart`](/home/masy/project/Budgets/lib/core/currency/currency_provider.dart:1)

### 4. Data flow

The app is built around an offline-first flow:

1. UI triggers actions through Riverpod providers/controllers
2. Providers call datasources or repositories
3. Most business data is read from and written to the local PowerSync database
4. PowerSync syncs local changes to Supabase when the user is online
5. Some direct Supabase SDK usage is still used for auth, storage, and service-specific operations

Example:

- Transactions are queried from the local PowerSync database in [`lib/features/transactions/data/datasource/transaction_api.dart`](/home/masy/project/Budgets/lib/features/transactions/data/datasource/transaction_api.dart:1)
- Auth uses Supabase in [`lib/features/auth/data/repository/supabase_auth_repository.dart`](/home/masy/project/Budgets/lib/features/auth/data/repository/supabase_auth_repository.dart:1)
- Offline image uploads are queued in [`lib/core/offline/image_upload_queue.dart`](/home/masy/project/Budgets/lib/core/offline/image_upload_queue.dart:1)

## Services used

### Supabase

Supabase is the main backend for:

- Authentication
- Database access
- Storage uploads
- RPCs such as account deletion

Relevant code:

- [`lib/features/auth/data/repository/supabase_auth_repository.dart`](/home/masy/project/Budgets/lib/features/auth/data/repository/supabase_auth_repository.dart:1)
- [`lib/features/profile/data/datasources/supabase_profile_datasource.dart`](/home/masy/project/Budgets/lib/features/profile/data/datasources/supabase_profile_datasource.dart:1)

### PowerSync

PowerSync provides the offline-first local database and synchronization layer between the app and Supabase.

- Database bootstrap: [`lib/core/powersync/powersync.dart`](/home/masy/project/Budgets/lib/core/powersync/powersync.dart:1)
- Sync schema: [`lib/core/powersync/schema.dart`](/home/masy/project/Budgets/lib/core/powersync/schema.dart:1)
- Supabase connector: [`lib/core/powersync/supabase_connector.dart`](/home/masy/project/Budgets/lib/core/powersync/supabase_connector.dart:1)

### Firebase

Firebase is used for push messaging and distribution.

- Client setup: [`lib/firebase_options.dart`](/home/masy/project/Budgets/lib/firebase_options.dart:1)
- FCM bootstrap: [`lib/features/notifications/presentation/services/notification_service.dart`](/home/masy/project/Budgets/lib/features/notifications/presentation/services/notification_service.dart:1)
- GitHub Actions distribution: [`.github/workflows/firebase-distribution.yml`](/home/masy/project/Budgets/.github/workflows/firebase-distribution.yml:1)

### Supabase Edge Functions for notifications

This repo includes two edge functions that send push messages through Firebase HTTP v1:

- Daily reminders: [`supabase/functions/notifications-reminder/index.ts`](/home/masy/project/Budgets/supabase/functions/notifications-reminder/index.ts:1)
- Budget warnings: [`supabase/functions/notifications-warning/index.ts`](/home/masy/project/Budgets/supabase/functions/notifications-warning/index.ts:1)

They expect backend environment variables such as:

- `FIREBASE_PROJECT_ID`
- `FIREBASE_CLIENT_EMAIL`
- `FIREBASE_PRIVATE_KEY`
- `CRON_SECRET`

### Sentry

Sentry is initialized at startup for crash and performance monitoring using the `SENTRY_DSN` dart define.

### Local storage

- Hive stores app-local persistent data
- SharedPreferences stores user preferences such as theme mode

## Environment configuration

The app uses compile-time dart defines.

Copy [`.env.example`](/home/masy/project/Budgets/.env.example:1) to `.env` and fill in:

```env
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
SENTRY_DSN=...
```

## How to run

### Prerequisites

- Flutter 3.38.7
- Dart SDK compatible with the repo
- Android Studio and/or Xcode set up for Flutter development
- A working Supabase project
- A working Firebase project for mobile notifications
- A PowerSync instance reachable by the app

This repo uses FVM, so using `fvm` is the safest option.

### Install dependencies

```bash
fvm flutter pub get
```

### Generate Riverpod files

The generated provider files are not checked into this repo, so you need to run code generation before the first build:

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

### Run the app

Using a local `.env` file:

```bash
fvm flutter run --dart-define-from-file=.env
```

Or by passing values directly:

```bash
fvm flutter run \
  --dart-define=SUPABASE_URL=your-url \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=SENTRY_DSN=your-sentry-dsn
```

### Run tests

```bash
fvm flutter test
```

### Analyze

```bash
fvm flutter analyze
```

## Backend notes

This repo contains client code plus a small amount of backend support code, but not a full infrastructure bootstrap.

To make the app work end-to-end you will need:

- Supabase tables and policies that match the PowerSync schema
- A deployed PowerSync instance
- Firebase mobile app configuration
- Deployed notification edge functions if you want reminder/warning pushes

There is also a SQL helper in [`db-functions/update_budget_spent.sql`](/home/masy/project/Budgets/db-functions/update_budget_spent.sql:1).

## CI/CD

GitHub Actions currently builds the Android release APK and distributes it through Firebase App Distribution on pushes to `main`.

See [`.github/workflows/firebase-distribution.yml`](/home/masy/project/Budgets/.github/workflows/firebase-distribution.yml:1).

## Notes for contributors

- Keep feature code inside the relevant `lib/features/<feature>` folder
- Put shared infrastructure in `lib/core`
- Put reusable cross-feature widgets in `lib/widgets`
- If you add or change Riverpod annotated providers, rerun `build_runner`
