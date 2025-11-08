import 'package:budgets/core/theme.dart';
import 'package:budgets/model/category_model.dart';
import 'package:budgets/features/auth/presentation/pages/sign_up_page.dart';
import 'package:budgets/features/auth/presentation/pages/login_page.dart';
import 'package:budgets/features/auth/presentation/pages/reset_password_page.dart';
import 'package:budgets/features/onboarding/presentation/pages/splash_page.dart';
import 'package:budgets/pages/categories/page/add_category_page.dart';
import 'package:budgets/pages/expenses/page/add_expenses.dart';
import 'package:budgets/pages/expenses/page/view_expense_list.dart';
import 'package:budgets/pages/expenses/page/filter_expenses.dart';
import 'package:budgets/pages/home/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budgets/core/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final supabase = Supabase.instance.client;

Box<dynamic> get storageBox => Hive.box(LocalAppStorage.storageBox);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  // Create router once to prevent resets on rebuilds (e.g., keyboard focus changes)
  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordPage()),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(path: '/add-expense', builder: (context, state) => const ExpenseCreationPage()),
      GoRoute(path: '/filter-expense', builder: (context, state) => const ExpenseFilterPage()),
      GoRoute(path: '/add-category', builder: (context, state) => AddCategoryPage(category: state.extra as Category?)),
      GoRoute(path: '/expense-list', builder: (context, state) => const ExpenseList()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (p0, p1, p2) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Budgets',
          themeMode: ThemeMode.dark,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            textTheme: GoogleFonts.nunitoSansTextTheme(),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.white,
              selectionHandleColor: Color.fromARGB(255, 51, 51, 51),
              selectionColor: Color(0xffDDFFBC),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppTheme.backgroundDark,
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.white,
              selectionHandleColor: Color.fromARGB(255, 183, 183, 183),
              selectionColor: Color.fromARGB(255, 79, 104, 56),
            ),
          ),
          routerConfig: _router,
        );
      },
    );
  }
}
