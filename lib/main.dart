import 'package:budgets/core/navigation/app_navigation.dart';
import 'package:budgets/core/theme.dart';
import 'package:budgets/core/ui/app_responsive_scope.dart';
import 'package:budgets/features/notifications/presentation/services/firebase_messaging_bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get supabase => Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL');
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (url.isEmpty || anonKey.isEmpty) {
    throw StateError(
      'SUPABASE_URL and SUPABASE_ANON_KEY dart defines are required.',
    );
  }
  await FirebaseMessagingBootstrap.initialize();
  await Supabase.initialize(url: url, anonKey: anonKey);
  final navigation = AppNavigation.supabase(Supabase.instance.client);
  runApp(ProviderScope(child: MyApp(navigation: navigation)));
}

class MyApp extends StatefulWidget {
  const MyApp({required this.navigation, super.key});

  final AppNavigation navigation;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    widget.navigation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Drala',
        theme: AppTheme.lightTheme.copyWith(
          scaffoldBackgroundColor: const Color(0xFFFEFEFE),
        ),
        builder: (context, child) => AppResponsiveScope(
          child: child ?? const SizedBox.shrink(),
        ),
        routerConfig: widget.navigation.router,
      ),
    );
  }
}
