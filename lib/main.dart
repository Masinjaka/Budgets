import 'package:budgets/core/navigation/app_navigation.dart';
import 'package:budgets/core/monitoring/sentry_bootstrap.dart';
import 'package:budgets/core/theme.dart';
import 'package:budgets/core/ui/amount_visibility_controller.dart';
import 'package:budgets/core/ui/amount_visibility_scope.dart';
import 'package:budgets/core/ui/app_responsive_scope.dart';
import 'package:budgets/features/feedback/presentation/widgets/app_feedback.dart';
import 'package:budgets/features/notifications/presentation/services/firebase_messaging_bootstrap.dart';
import 'package:budgets/features/settings/domain/providers/locale_provider.dart';
import 'package:budgets/features/settings/domain/providers/theme_provider.dart';
import 'package:budgets/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get supabase => Supabase.instance.client;

Future<void> main() async {
  await SentryBootstrap.run(_startApplication);
}

Future<void> _startApplication() async {
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
  runApp(
    SentryWidget(
      child: ProviderScope(child: MyApp(navigation: navigation)),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({required this.navigation, super.key});

  final AppNavigation navigation;

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _amountVisibilityController = AmountVisibilityController();

  @override
  void dispose() {
    _amountVisibilityController.dispose();
    widget.navigation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);
    return AppFeedback(
      themeMode: themeMode,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        builder: (context, child) => AmountVisibilityScope(
          controller: _amountVisibilityController,
          child: AppResponsiveScope(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
        routerConfig: widget.navigation.router,
      ),
    );
  }
}
