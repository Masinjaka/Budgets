import 'package:budgets/core/theme.dart';
import 'package:budgets/features/auth/presentation/pages/upload_profile_photo_page.dart';
import 'package:budgets/features/onboarding/presentation/pages/getting_started_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:budgets/features/settings/presentation/pages/edit_password_page.dart';
import 'package:budgets/features/settings/presentation/pages/edit_profile_page.dart';
import 'package:budgets/features/settings/presentation/pages/currency_selection_page.dart';
import 'package:budgets/features/notifications/presentation/pages/notification_settings_page.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/auth/presentation/pages/sign_up_page.dart';
import 'package:budgets/features/auth/presentation/pages/login_page.dart';
import 'package:budgets/features/auth/presentation/pages/reset_password_page.dart';
import 'package:budgets/features/auth/presentation/pages/verify_reset_code_page.dart';
import 'package:budgets/features/onboarding/presentation/pages/splash_page.dart';
import 'package:budgets/features/categories/presentation/pages/add_category_page.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/presentation/pages/add_transaction.dart';
import 'package:budgets/features/transactions/presentation/pages/transaction_page.dart';
import 'package:budgets/features/transactions/presentation/pages/filter_transactions_page.dart';
import 'package:budgets/features/transactions/presentation/pages/transaction_search_page.dart';
import 'package:budgets/features/navigation/presentation/pages/navigation_page.dart';
import 'package:budgets/features/home/presentation/pages/accueil_page.dart'
    as accueil;
import 'package:budgets/features/settings/presentation/pages/setting_page.dart';
import 'package:budgets/features/categories/presentation/pages/category_page.dart';
import 'package:budgets/features/stats/presentation/pages/stats_page.dart';
import 'package:budgets/features/planning/presentation/pages/planning_page.dart';
import 'package:budgets/features/settings/domain/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budgets/core/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:budgets/features/notifications/presentation/services/foreground_notification_service.dart';
import 'package:budgets/core/powersync/powersync.dart' as powersync;
import 'package:budgets/core/offline/image_upload_queue.dart';

// Environment variables injected via --dart-define
const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

final supabase = Supabase.instance.client;

Box<dynamic> get storageBox => Hive.box(LocalAppStorage.storageBox);

/// Top-level function for handling background FCM messages.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Background message received - system will display notification automatically
  // if it contains a 'notification' payload
  debugPrint('🔔 [Background] FCM message received:');
  debugPrint('   Message ID: ${message.messageId}');
  debugPrint('   Title: ${message.notification?.title}');
  debugPrint('   Body: ${message.notification?.body}');
  debugPrint('   Data: ${message.data}');
}

void main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  // Initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background message handler - must be before runApp()
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await ForegroundNotificationService(
    FlutterLocalNotificationsPlugin(),
  ).init();

  // Initialize French locale for date formatting
  await initializeDateFormatting('fr_FR', null);

  // initialize supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // initialise hive box
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(LocalAppStorage.storageBox);

  // Initialize PowerSync (after Supabase)
  await powersync.openPowerSyncDatabase(LocalAppStorage.powersyncUrl);

  // Initialize the offline image upload queue
  await ImageUploadQueue.instance.init();

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
      options.environment = 'production';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
      // Enable screenshots for error reports
      options.attachScreenshot = true;
      options.debug = false;
    },
    appRunner: () async {
      runApp(ProviderScope(child: SentryScreenshotWidget(child: MyApp())));
    },
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(
          path: '/getting-started',
          builder: (context, state) => const GettingStartedPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
      GoRoute(
          path: '/upload-profile-photo',
          builder: (context, state) => const UploadProfilePhotoPage()),
      GoRoute(
          path: '/reset-password',
          builder: (context, state) => const ResetPasswordPage()),
      GoRoute(
          path: '/verify-reset-code',
          builder: (context, state) =>
              VerifyResetCodePage(email: state.extra as String)),
      GoRoute(
          path: '/currency-selection',
          builder: (context, state) => const CurrencySelectionPage()),
      GoRoute(
          path: '/notification-settings',
          builder: (context, state) => const NotificationSettingsPage()),
      GoRoute(
          path: '/settings/reports',
          builder: (context, state) => const StatsPage()),
      // Shell with IndexedStack to preserve state across tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            NavigatorPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const accueil.HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transaction-list',
                builder: (context, state) => const TransactionPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/planning',
                builder: (context, state) => const PlanningPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/edit-transaction',
        builder: (context, state) {
          final type = state.uri.queryParameters['type'] ?? 'expense';
          final transaction = state.extra as TransactionModel?;
          return TransactionCreationPage(
            transactionType: type,
            transaction: transaction,
          );
        },
      ),
      GoRoute(
          path: '/filter-transaction',
          builder: (context, state) => const TransactionFilterPage()),
      GoRoute(
        path: '/transaction-search',
        builder: (context, state) {
          final type = state.uri.queryParameters['type'] ?? 'expense';
          return TransactionSearchPage(transactionType: type);
        },
      ),
      GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoryPage()),
      GoRoute(
        path: '/add-category',
        builder: (context, state) {
          final type = state.uri.queryParameters['type'] ?? 'expense';
          return AddCategoryPage(
            category: state.extra as Category?,
            transactionType: type,
          );
        },
      ),
      GoRoute(
          path: '/edit-profile',
          builder: (context, state) => const EditProfilePage()),
      GoRoute(
          path: '/edit-password',
          builder: (context, state) => const EditPasswordPage()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    return ResponsiveSizer(
      builder: (p0, p1, p2) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Budgets',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: _router,
        );
      },
    );
  }
}
