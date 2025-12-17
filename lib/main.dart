import 'package:budgets/core/theme.dart';
import 'package:budgets/features/auth/presentation/pages/upload_profile_photo_page.dart';
import 'package:budgets/features/onboarding/presentation/pages/getting_started_page.dart';
import 'package:budgets/features/settings/presentation/pages/edit_password_page.dart';
import 'package:budgets/features/settings/presentation/pages/edit_profile_page.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/auth/presentation/pages/sign_up_page.dart';
import 'package:budgets/features/auth/presentation/pages/login_page.dart';
import 'package:budgets/features/auth/presentation/pages/reset_password_page.dart';
import 'package:budgets/features/onboarding/presentation/pages/splash_page.dart';
import 'package:budgets/features/categories/presentation/pages/add_category_page.dart';
import 'package:budgets/features/transactions/presentation/pages/add_transaction.dart';
import 'package:budgets/features/transactions/presentation/pages/transaction_page.dart';
import 'package:budgets/features/transactions/presentation/pages/filter_transactions_page.dart';
import 'package:budgets/features/navigation/presentation/pages/navigation_page.dart';
import 'package:budgets/features/home/presentation/pages/accueil_page.dart'
    as accueil;
import 'package:budgets/features/settings/presentation/pages/setting_page.dart';
import 'package:budgets/features/categories/presentation/pages/category_page.dart';
import 'package:budgets/features/stats/presentation/pages/stats_page.dart';
import 'package:budgets/features/settings/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budgets/core/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'package:gleap_sdk/gleap_sdk.dart';
import 'package:shake/shake.dart';

final supabase = Supabase.instance.client;

Box<dynamic> get storageBox => Hive.box(LocalAppStorage.storageBox);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize French locale for date formatting
  await initializeDateFormatting('fr_FR', null);

  // Initialize Gleap
  Gleap.initialize(token: 'Qq2gB5CN8MF6U7XdK5xUhETe49WgA0aa');
  Gleap.showFeedbackButton(false);

  // initialize supabase
  await Supabase.initialize(
    url: 'https://fqqpmzurvunhilnnhmtf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxcXBtenVydnVuaGlsbm5obXRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkxOTIxNTcsImV4cCI6MjA2NDc2ODE1N30.ur3oGU8SIjsWZHGQS9Vk8y9Y1UXBJCrEw_KahPCAI_k',
  );

  // initialise hive box
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(LocalAppStorage.storageBox);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late ShakeDetector detector;

  @override
  void initState() {
    super.initState();
    detector = ShakeDetector.waitForStart(
      onPhoneShake: (_) {
        Gleap.open();
      },
      minimumShakeCount: 1,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 2.7,
    );
    detector.startListening();
  }

  @override
  void dispose() {
    detector.stopListening();
    super.dispose();
  }

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
          path: '/settings', builder: (context, state) => const SettingPage()),
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
                path: '/categories',
                builder: (context, state) => const CategoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                builder: (context, state) => const StatsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/add-transaction',
        builder: (context, state) {
          final type = state.uri.queryParameters['type'] ?? 'expense';
          return TransactionCreationPage(transactionType: type);
        },
      ),
      GoRoute(
          path: '/filter-transaction',
          builder: (context, state) => const TransactionFilterPage()),
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
