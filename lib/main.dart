import 'package:budgets/pages/auth/pages/sign_up_page.dart';
import 'package:budgets/pages/auth/pages/login_page.dart';
import 'package:budgets/pages/home/pages/home_page.dart';
import 'package:budgets/pages/splash/page/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budgets/core/constants.dart';

final supabase = Supabase.instance.client;

Box<dynamic> get storageBox => Hive.box(LocalAppStorage.storageBox);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (p0, p1, p2) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Budgets',
            theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            textTheme: GoogleFonts.nunitoSansTextTheme(),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.black,
              selectionHandleColor: Color.fromARGB(255, 51, 51, 51),
              selectionColor: Color(0xffDDFFBC),
            ),
            ),
          routerConfig: router,
        );
      },
    );
  }
}
